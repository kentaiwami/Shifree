import random
import string
import os
from database import db, session
from datetime import datetime
from sqlalchemy import event
from config import demo_company


def code_generator():
    return ''.join(random.choice(string.digits) for _ in range(7))


def password_generator():
    return ''.join(random.choice(string.ascii_uppercase + string.digits) for _ in range(7))


class Company(db.Model):
    __tablename__ = 'company'

    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(255), nullable=False, unique=True)
    code = db.Column(db.String(255), nullable=False, unique=True, default=code_generator)
    default_same_line_threshold = db.Column(db.Float, db.ColumnDefault(3.0))
    default_username_threshold = db.Column(db.Float, db.ColumnDefault(10.0))
    default_join_threshold = db.Column(db.Float, db.ColumnDefault(8.0))
    default_day_shift_threshold = db.Column(db.Float, db.ColumnDefault(9.0))
    created_at = db.Column(db.DateTime, nullable=False, default=datetime.now)
    updated_at = db.Column(db.DateTime, nullable=False, default=datetime.now, onupdate=datetime.now)

    users = db.relationship('User', backref='company', cascade='all, delete-orphan')
    shift_tables = db.relationship('ShiftTable', backref='company', cascade='all, delete-orphan')
    shift_categories = db.relationship('ShiftCategory', backref='company', cascade='all, delete-orphan')

    def __repr__(self):
        return '{}({})'.format(self.name, self.code)


class User(db.Model):
    __tablename__ = 'user'

    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(255), nullable=False)
    code = db.Column(db.String(255), nullable=False, unique=True, default=code_generator)
    order = db.Column(db.Integer, nullable=False)
    password = db.Column(db.String(255), nullable=False, default=password_generator)
    daytime_start = db.Column(db.Time, nullable=True)
    daytime_end = db.Column(db.Time, nullable=True)
    daytime_wage = db.Column(db.Integer, nullable=True)
    night_start = db.Column(db.Time, nullable=True)
    night_end = db.Column(db.Time, nullable=True)
    night_wage = db.Column(db.Integer, nullable=True)
    is_authed = db.Column(db.Boolean, default=False)
    is_shift_import_notification = db.Column(db.Boolean, default=True)
    is_comment_notification = db.Column(db.Boolean, default=True)
    is_update_shift_notification = db.Column(db.Boolean, default=True)
    token = db.Column(db.String(255), nullable=True)
    company_id = db.Column(db.Integer, db.ForeignKey('company.id'), nullable=False)
    role_id = db.Column(db.Integer, db.ForeignKey('role.id'), nullable=False)
    created_at = db.Column(db.DateTime, nullable=False, default=datetime.now)
    updated_at = db.Column(db.DateTime, nullable=False, default=datetime.now, onupdate=datetime.now)

    salaries = db.relationship('Salary', backref='user', cascade='all, delete-orphan')
    color_schemes = db.relationship('ColorScheme', backref='user', cascade='all, delete-orphan')
    user_shifts = db.relationship('UserShift', backref='user', cascade='all, delete-orphan')
    comments = db.relationship('Comment', backref='user', cascade='all, delete-orphan')

    def __repr__(self):
        company = session.query(Company).filter(Company.id == self.company_id).one_or_none()
        return '{}({})({})'.format(self.name, self.code, company.name)


class Follow(db.Model):
    __tablename__ = 'follow'

    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=True, default=None, unique=True)
    follow_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=True, default=None)
    user = db.relationship("User", foreign_keys=[user_id])
    follow = db.relationship("User", foreign_keys=[follow_id])

    __table_args__ = (db.UniqueConstraint('user_id', 'follow_id', name='_user_follow_uc'),)


class Role(db.Model):
    __tablename__ = 'role'

    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(255), nullable=False, unique=True)
    created_at = db.Column(db.DateTime, nullable=False, default=datetime.now)
    updated_at = db.Column(db.DateTime, nullable=False, default=datetime.now, onupdate=datetime.now)

    users = db.relationship('User', backref='role', cascade='all, delete-orphan')

    def __repr__(self):
        return self.name


class ShiftTable(db.Model):
    __tablename__ = 'shifttable'

    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(255), nullable=False)
    origin_path = db.Column(db.String(255), nullable=True)
    thumbnail_path = db.Column(db.String(255), nullable=True)
    start = db.Column(db.Date, nullable=True)
    end = db.Column(db.Date, nullable=True)
    company_id = db.Column(db.Integer, db.ForeignKey('company.id'), nullable=False)
    created_at = db.Column(db.DateTime, nullable=False, default=datetime.now)
    updated_at = db.Column(db.DateTime, nullable=False, default=datetime.now, onupdate=datetime.now)

    salaries = db.relationship('Salary', backref='shifttable', cascade='all, delete-orphan')
    users_shifts = db.relationship('UserShift', backref='shifttable', cascade='all, delete-orphan')
    comments = db.relationship('Comment', backref='shifttable', cascade='all, delete-orphan')

    def __repr__(self):
        company = session.query(Company).filter(Company.id == self.company_id).one_or_none()
        return '{}({})'.format(self.title, company.name)


class Comment(db.Model):
    __tablename__ = 'comment'

    id = db.Column(db.Integer, primary_key=True)
    text = db.Column(db.String(255), nullable=False)
    created_at = db.Column(db.DateTime, nullable=False, default=datetime.now)
    updated_at = db.Column(db.DateTime, nullable=False, default=datetime.now, onupdate=datetime.now)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    shifttable_id = db.Column(db.Integer, db.ForeignKey('shifttable.id'), nullable=False)

    def __repr__(self):
        user = session.query(User).filter(User.id == self.user_id).one_or_none()
        shifttable = session.query(ShiftTable).filter(ShiftTable.id == self.shifttable_id).one_or_none()
        return '{}({})({})'.format(self.text, user.name, shifttable.title)


class Salary(db.Model):
    __tablename__ = 'salary'

    id = db.Column(db.Integer, primary_key=True)
    pay = db.Column(db.Integer, nullable=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    shifttable_id = db.Column(db.Integer, db.ForeignKey('shifttable.id'), nullable=False)
    created_at = db.Column(db.DateTime, nullable=False, default=datetime.now)
    updated_at = db.Column(db.DateTime, nullable=False, default=datetime.now, onupdate=datetime.now)

    def __repr__(self):
        user = session.query(User).filter(User.id == self.user_id).one_or_none()
        return '¥{}({})'.format(self.pay, user.name)


class ShiftCategory(db.Model):
    __tablename__ = 'shiftcategory'

    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(255), nullable=False)
    company_id = db.Column(db.Integer, db.ForeignKey('company.id'), nullable=False)
    created_at = db.Column(db.DateTime, nullable=False, default=datetime.now)
    updated_at = db.Column(db.DateTime, nullable=False, default=datetime.now, onupdate=datetime.now)

    shifts = db.relationship('Shift', backref='shiftcategory', cascade='all, delete-orphan')
    colors = db.relationship('ColorScheme', backref='shiftcategory', cascade='all, delete-orphan')

    def __repr__(self):
        company = session.query(Company).filter(Company.id == self.company_id).one_or_none()
        return '{}({})'.format(self.name, company.name)


class Shift(db.Model):
    __tablename__ = 'shift'

    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(255), nullable=False)
    shift_category_id = db.Column(db.Integer, db.ForeignKey('shiftcategory.id'), nullable=False)
    start = db.Column(db.Time, nullable=True)
    end = db.Column(db.Time, nullable=True)
    created_at = db.Column(db.DateTime, nullable=False, default=datetime.now)
    updated_at = db.Column(db.DateTime, nullable=False, default=datetime.now, onupdate=datetime.now)

    user_shifts = db.relationship('UserShift', backref='shift', cascade='all, delete-orphan')

    def __repr__(self):
        shiftcategory = session.query(ShiftCategory).filter(ShiftCategory.id == self.shift_category_id).one_or_none()
        company = session.query(Company).filter(Company.id == shiftcategory.company_id).one_or_none()

        return '{}({})({})'.format(self.name, shiftcategory.name, company.code)


class UserShift(db.Model):
    __tablename__ = 'usershift'

    id = db.Column(db.Integer, primary_key=True)
    date = db.Column(db.Date, nullable=False)
    memo = db.Column(db.String(255), nullable=True)
    shift_id = db.Column(db.Integer, db.ForeignKey('shift.id'), nullable=False)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    shift_table_id = db.Column(db.Integer, db.ForeignKey('shifttable.id'), nullable=False)
    created_at = db.Column(db.DateTime, nullable=False, default=datetime.now)
    updated_at = db.Column(db.DateTime, nullable=False, default=datetime.now, onupdate=datetime.now)

    def __repr__(self):
        user = session.query(User).filter(User.id == self.user_id).one_or_none()
        shift = session.query(Shift).filter(Shift.id == self.shift_id).one_or_none()
        shifttable = session.query(ShiftTable).filter(ShiftTable.id == self.shift_table_id).one_or_none()
        return '{}({})({})({})'.format(user.name, str(self.date), shift.name, shifttable.title)


class ColorScheme(db.Model):
    __tablename__ = 'colorscheme'

    id = db.Column(db.Integer, primary_key=True)
    hex = db.Column(db.String(255), nullable=False)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    shift_category_id = db.Column(db.Integer, db.ForeignKey('shiftcategory.id'), nullable=False)
    created_at = db.Column(db.DateTime, nullable=False, default=datetime.now)
    updated_at = db.Column(db.DateTime, nullable=False, default=datetime.now, onupdate=datetime.now)

    __table_args__ = (db.UniqueConstraint('user_id', 'shift_category_id', name='_user_color_scheme_uc'),)

    def __repr__(self):
        user = session.query(User).filter(User.id == self.user_id).one_or_none()
        shiftcategory = session.query(ShiftCategory).filter(ShiftCategory.id == self.shift_category_id).one_or_none()
        return '{}({})({})'.format(self.hex, user.name, shiftcategory.name)


@event.listens_for(Company, 'after_insert')
def receive_after_insert(_mapper, connection, company):
    shiftcategory_table = ShiftCategory.__table__
    ins = shiftcategory_table.insert().values(name='unknown', company_id=company.id)
    result = connection.execute(ins)

    shift_table = Shift.__table__
    ins = shift_table.insert().values(name='unknown', shift_category_id=result.inserted_primary_key[0])
    connection.execute(ins)


@event.listens_for(ShiftTable, 'after_delete')
def receive_after_insert(_mapper, _connection, shift_table):
    try:
        if shift_table.company_id != demo_company['id']:
            os.remove(shift_table.origin_path)
            os.remove(shift_table.thumbnail_path)
    except FileNotFoundError:
        pass
