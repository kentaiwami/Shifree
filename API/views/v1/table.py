import inspect
from flask import Blueprint, jsonify, request, abort
from model import *
from database import session
from basic_auth import api_basic_auth
from jsonschema import validate, ValidationError
from views.v1.response import response_msg_400, response_msg_403, response_msg_404, response_msg_200, response_msg_409
import subprocess
import os
import unicodedata
from datetime import datetime as DT
from sqlalchemy.sql import exists
import datetime

app = Blueprint('table_bp', __name__)
ALLOWED_EXTENSIONS = {'pdf'}


def allowed_file(filename):
    return '.' in filename and \
           filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS


def format_text(text):
    text = unicodedata.normalize('NFKC', text)
    table = str.maketrans('', '', string.punctuation + '「」、。・')
    text = text.translate(table)

    return text


def get_salary(user, shift):
    if user.daytime_start is None or user.daytime_end is None or user.daytime_wage is None or user.daytime_wage == 0 or\
        user.night_start is None or user.night_end is None or user.night_wage is None or user.night_wage == 0 or \
        shift.start is None or shift.end is None:
        return 0

    year = datetime.datetime.now().year
    month = datetime.datetime.now().month
    day = datetime.datetime.now().day

    user_daytime_start = datetime.datetime(year=year, month=month, day=day, hour=user.daytime_start.hour,
                                           minute=user.daytime_start.minute)
    user_daytime_end = user_daytime_start
    user_night_start = datetime.datetime(year=year, month=month, day=day, hour=user.night_start.hour,
                                           minute=user.night_start.minute)
    user_night_end = user_night_start

    while True:
        if user_daytime_end.hour == user.daytime_end.hour and user_daytime_end.minute == user.daytime_end.minute:
            break

        user_daytime_end += datetime.timedelta(minutes=30)

    while True:
        if user_night_end.hour == user.night_end.hour and user_night_end.minute == user.night_end.minute:
            break

        user_night_end += datetime.timedelta(minutes=30)


    shift_start = datetime.datetime(year=year, month=month, day=day,
                                    hour=shift.start.hour,
                                    minute=shift.start.minute)
    shift_end = shift_start

    while True:
        if shift_end.hour == shift.end.hour and shift_end.minute == shift.end.minute:
            break
        shift_end += datetime.timedelta(minutes=30)


    shift_now = shift_start + datetime.timedelta(minutes=30)
    daytime_count = 0.0
    night_count = 0.0

    while shift_now <= shift_end:
        if user_daytime_start <= shift_now <= user_daytime_end:
            daytime_count += 0.5
        else:
            night_count += 0.5

        shift_now += datetime.timedelta(minutes=30)

    return user.daytime_wage * daytime_count + user.night_wage * night_count


@app.route('/api/v1/table', methods=['POST'])
@api_basic_auth.login_required
def import_shift():
    from app import app

    schema = {'type': 'object',
              'properties':
                  {'number': {'type': 'string', 'minimum': 1},
                   'start': {'type': 'string', 'pattern': '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'},
                   'end': {'type': 'string', 'pattern': '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'},
                   'title': {'type': 'string', 'minLength': 1},
                   'same_line_threshold': {'type': 'string', 'minLength': 1},
                   'username_threshold': {'type': 'string', 'minLength': 1},
                   'join_threshold': {'type': 'string', 'minLength': 1},
                   'day_shift_threshold': {'type': 'string', 'minLength': 1},
                   },
              'required': [
                  'number',
                  'start',
                  'end',
                  'title',
                  'same_line_threshold',
                  'username_threshold',
                  'join_threshold',
                  'day_shift_threshold'
              ]
              }

    try:
        validate(request.form, schema)
    except ValidationError as e:
        session.close()
        frame = inspect.currentframe()
        abort(400, {'code': frame.f_lineno, 'msg': e.message, 'param': None})

    try:
        number = int(request.form['number'])
        same_line_threshold = float(request.form['same_line_threshold'])
        username_threshold = float(request.form['username_threshold'])
        join_threshold = float(request.form['join_threshold'])
        day_shift_threshold = float(request.form['day_shift_threshold'])
    except ValueError:
        session.close()
        frame = inspect.currentframe()
        abort(400, {'code': frame.f_lineno, 'msg': '閾値の設定値は数字にする必要があります', 'param': None})

    start_date = DT.strptime(request.form['start'], '%Y-%m-%d')
    end_date = DT.strptime(request.form['end'], '%Y-%m-%d')

    if start_date >= end_date:
        session.close()
        frame = inspect.currentframe()
        abort(400, {'code': frame.f_lineno, 'msg': '開始日付は終了日付よりも前にする必要があります', 'param': None})

    user = session.query(User).filter(User.code == api_basic_auth.username()).one()

    if user.role.name != 'admin':
        session.close()
        frame = inspect.currentframe()
        abort(403, {'code': frame.f_lineno, 'msg': response_msg_403(), 'param': None})

    if 'file' not in request.files:
        session.close()
        frame = inspect.currentframe()
        abort(400, {'code': frame.f_lineno, 'msg': response_msg_400(), 'param': None})

    file = request.files['file']

    if not (file and allowed_file(file.filename)):
        session.close()
        frame = inspect.currentframe()
        abort(400, {'code': frame.f_lineno, 'msg': response_msg_400(), 'param': None})

    company = session.query(Company).filter(Company.id == user.company_id).one()

    secure_title = format_text(request.form['title'])

    _, file_ext = os.path.splitext(file.filename)
    saved_file_fullname = company.code + '_' + secure_title

    origin_file_path = os.path.join(app.config['UPLOAD_FOLDER'], 'origin', saved_file_fullname + file_ext)
    thumbnail_file_path = os.path.join(app.config['UPLOAD_FOLDER'], 'thumbnail', saved_file_fullname + '.jpg')

    if os.path.exists(origin_file_path):
        session.close()
        frame = inspect.currentframe()
        abort(409, {'code': frame.f_lineno, 'msg': response_msg_409(), 'param': None})

    # 企業ごとの解析プログラムを実行
    try:
        exec('from analyze.company{} import create_main'.format(company.id))
        user_results = eval('create_main({},{},\'{}\',\'{}\', {}, {}, {}, {}, file, origin_file_path)'.format(
            company.id,
            number,
            request.form['start'],
            request.form['end'],
            same_line_threshold,
            username_threshold,
            join_threshold,
            day_shift_threshold
        ))
    except ValueError:
        session.close()
        frame = inspect.currentframe()
        abort(400, {'code': frame.f_lineno, 'msg': response_msg_400(), 'param': None})

    flatten_user_shifts = [item for sublist in user_results.shifts for item in sublist]
    shift_types = list(set(flatten_user_shifts))

    if None in shift_types:
        shift_types.remove(None)

    unknown_shift_types = []

    for shift in shift_types:
        if not session.query(exists().where(Shift.name == shift)).scalar():
            unknown_shift_types.append(shift)

    # swift側で未登録のシフトを扱うために200で返す
    if len(unknown_shift_types) != 0:
        os.remove(origin_file_path)
        session.close()
        frame = inspect.currentframe()
        return jsonify({
            'code': frame.f_lineno,
            'msg': '未登録のシフトがあるため、処理を完了できませんでした。',
            'param': unknown_shift_types
        }), 200

    shift_table = ShiftTable(
        title=secure_title,
        origin_path=origin_file_path,
        thumbnail_path=thumbnail_file_path,
        company_id=company.id
    )

    session.add(shift_table)
    session.commit()

    start_date = DT.strptime(request.form['start'], '%Y-%m-%d')
    users = session.query(User).filter(User.company_id == company.id).order_by('order').all()

    user_shift_objects = []
    salary_objects = []
    unknown = {}

    for shifts, username in zip(user_results.shifts, user_results.names):
        tmp_unknown_dates = []
        tmp_salary = 0
        user = [user for user in users if user.name == username][0]

        for i, shift_name in enumerate(shifts):
            date = (start_date + datetime.timedelta(days=i))

            if shift_name is None:
                shift_name = 'unknown'
                tmp_unknown_dates.append(date.strftime('%Y-%m-%d'))

            shift = session.query(Shift)\
                .join(ShiftCategory, Shift.shift_category_id == ShiftCategory.id)\
                .filter(Shift.name == shift_name, user.company_id == ShiftCategory.company_id).one()

            same_user_shift = session.query(UserShift).filter(UserShift.date == date, UserShift.user_id == user.id).one_or_none()

            if same_user_shift is not None:
                session.delete(shift_table)
                session.commit()
                session.close()
                frame = inspect.currentframe()
                abort(409, {'code': frame.f_lineno, 'msg': response_msg_409(), 'param': None})

            user_shift = UserShift(date=date, shift_id=shift.id, user_id=user.id, shift_table_id=shift_table.id)
            user_shift_objects.append(user_shift)

            tmp_salary += get_salary(user, shift)


        new_salary = Salary(pay=tmp_salary, user_id=user.id, shifttable_id=shift_table.id)
        salary_objects.append(new_salary)


        if len(tmp_unknown_dates) != 0:
            unknown[user.code] = {'name': username, 'date': tmp_unknown_dates, 'order': user.order}

        users.remove(user)

    session.bulk_save_objects(user_shift_objects)
    session.bulk_save_objects(salary_objects)
    session.commit()
    session.close()

    params = ['convert', '-density', '600', origin_file_path + '[0]', thumbnail_file_path]
    subprocess.check_call(params)

    return jsonify({'results': {
        'table_title': shift_table.title,
        'table_id': shift_table.id,
        'unknown': unknown
    }}), 200


@app.route('/api/v1/tables', methods=['GET'])
@api_basic_auth.login_required
def get_all():
    offset = request.args.get('offset', default=0, type=int)

    user = session.query(User).filter(User.code == api_basic_auth.username()).one()
    tables = session.query(ShiftTable).filter(ShiftTable.company_id == user.company_id).limit(10).offset(offset).all()

    results = []
    for table in tables:
        results.append({
            'table_id': table.id,
            'title': table.title,
            'origin': table.origin_path,
            'thumbnail': table.thumbnail_path
        })

    return jsonify({'results': results}), 200


@app.route('/api/v1/tables/<table_id>', methods=['GET'])
@api_basic_auth.login_required
def get_detail(table_id):
    table = session.query(ShiftTable).filter(ShiftTable.id == table_id).one_or_none()

    if table is None:
        session.close()
        frame = inspect.currentframe()
        abort(404, {'code': frame.f_lineno, 'msg': response_msg_404(), 'param': None})

    user = session.query(User).filter(User.code == api_basic_auth.username()).one()

    if user.company_id != table.company_id:
        session.close()
        frame = inspect.currentframe()
        abort(403, {'code': frame.f_lineno, 'msg': response_msg_403(), 'param': None})

    comment_user = session.query(Comment, User)\
        .join(User).\
        filter(Comment.shifttable_id == table.id)\
        .order_by(Comment.created_at.desc())\
        .all()

    comment_list = []
    for comment, user in comment_user:
        comment_list.append({
            'text': comment.text,
            'id': comment.id,
            'user_id': user.id,
            'user': user.name,
            'created_at': comment.created_at.strftime('%Y-%m-%d %H:%M')
        })

    results = {
        'table_id': table.id,
        'title': table.title,
        'origin': table.origin_path,
        'comment': comment_list
    }

    session.close()
    return jsonify({'results': results}), 200


@app.route('/api/v1/tables/<table_id>', methods=['DELETE'])
@api_basic_auth.login_required
def delete(table_id):
    user = session.query(User).filter(User.code == api_basic_auth.username()).one()

    if user.role.name != 'admin':
        session.close()
        frame = inspect.currentframe()
        abort(403, {'code': frame.f_lineno, 'msg': response_msg_403(), 'param': None})

    table = session.query(ShiftTable).filter(ShiftTable.id == table_id).one_or_none()

    if table is None:
        session.close()
        frame = inspect.currentframe()
        abort(404, {'code': frame.f_lineno, 'msg': response_msg_404(), 'param': None})

    if table.company_id != user.company_id:
        session.close()
        frame = inspect.currentframe()
        abort(403, {'code': frame.f_lineno, 'msg': response_msg_403(), 'param': None})

    os.remove(table.origin_path)
    os.remove(table.thumbnail_path)
    session.delete(table)
    session.commit()
    session.close()
    return jsonify({'msg': response_msg_200()}), 200
