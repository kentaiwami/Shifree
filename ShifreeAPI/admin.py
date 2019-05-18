from flask import Response, redirect, request, abort
from config import ACCEPTED_IP
from flask_admin.contrib import sqla
from werkzeug.exceptions import HTTPException
from flask_admin import Admin
from model import db, User, Company, Role, Salary, Shift, ShiftCategory, ShiftTable, UserShift, Comment, ColorScheme, Follow


class AuthException(HTTPException):
    def __init__(self, message):
        super().__init__(message, Response(
            message, 401,
            {'WWW-Authenticate': 'Basic realm="Login Required"'}
        ))


class ModelView(sqla.ModelView):

    column_display_pk = True

    def is_accessible(self):
        from app import admin_basic_auth

        if request.remote_addr not in ACCEPTED_IP:
            return abort(403, {'code': None, 'msg': None, 'param': None})

        if not admin_basic_auth.authenticate():
            raise AuthException('Not authenticated. Refresh the page.')
        else:
            return True

    def inaccessible_callback(self, name, **kwargs):
        from app import admin_basic_auth

        return redirect(admin_basic_auth.challenge())


class CompanyView(ModelView):
    form_excluded_columns = ['users', 'shift_tables', 'shift_categories']


class UserView(ModelView):
    form_excluded_columns = ['salaries', 'color_schemes', 'user_shifts', 'comments']


class RoleView(ModelView):
    form_choices = {
        'name': [
            ('admin', 'admin'),
            ('general', 'general')
        ]
    }

    form_excluded_columns = ['users']


class ShiftView(ModelView):
    form_excluded_columns = ['user_shifts']


class ShiftCategoryView(ModelView):
    form_excluded_columns = ['shifts', 'colors']


class ShiftTableView(ModelView):
    form_excluded_columns = ['salaries', 'users_shifts', 'comments']


def init_admin(app_obj):
    admin = Admin(app_obj, name='Shifree', template_mode='bootstrap3')
    admin.add_view(CompanyView(Company, db.session))

    admin.add_view(UserView(User, db.session, category='User'))
    admin.add_view(ModelView(Follow, db.session, category='User'))
    admin.add_view(RoleView(Role, db.session, category='User'))
    admin.add_view(ModelView(Salary, db.session, category='User'))

    admin.add_view(ShiftView(Shift, db.session, category='Shift'))
    admin.add_view(ShiftCategoryView(ShiftCategory, db.session, category='Shift'))
    admin.add_view(ShiftTableView(ShiftTable, db.session, category='Shift'))
    admin.add_view(ModelView(UserShift, db.session, category='Shift'))

    admin.add_view(ModelView(Comment, db.session))
    admin.add_view(ModelView(ColorScheme, db.session))
