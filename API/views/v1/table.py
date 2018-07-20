import inspect
from flask import Blueprint, jsonify, request, abort
from model import *
from database import session
from basic_auth import api_basic_auth
from jsonschema import validate, ValidationError
import subprocess
import os
import unicodedata
from datetime import datetime as DT
from sqlalchemy.sql import exists
import datetime
from config import demo_admin_user
from utility import get_salary

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


@app.route('/api/v1/table', methods=['POST'])
@api_basic_auth.login_required
def import_shift():
    from app import app
    from app import client

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

    admin_user = session.query(User).filter(User.code == api_basic_auth.username()).one()

    if admin_user.role.name != 'admin':
        session.close()
        frame = inspect.currentframe()
        abort(403, {'code': frame.f_lineno, 'msg': '権限がありません', 'param': None})

    if 'file' not in request.files:
        session.close()
        frame = inspect.currentframe()
        abort(400, {'code': frame.f_lineno, 'msg': 'ファイルが添付されていません', 'param': None})

    file = request.files['file']

    if not (file and allowed_file(file.filename)):
        session.close()
        frame = inspect.currentframe()
        abort(400, {'code': frame.f_lineno, 'msg': 'PDF以外のファイルは対象外です', 'param': None})

    company = session.query(Company).filter(Company.id == admin_user.company_id).one()

    secure_title = format_text(request.form['title'])

    _, file_ext = os.path.splitext(file.filename)
    saved_file_fullname = company.code + '_' + secure_title

    origin_file_path = os.path.join(app.config['UPLOAD_FOLDER'], 'origin', saved_file_fullname + file_ext)
    thumbnail_file_path = os.path.join(app.config['UPLOAD_FOLDER'], 'thumbnail', saved_file_fullname + '.jpg')

    if os.path.exists(origin_file_path):
        session.close()
        frame = inspect.currentframe()
        abort(409, {'code': frame.f_lineno, 'msg': '既に同じタイトルでシフトを取り込んでいます', 'param': None})

    # Demo
    if admin_user.code == demo_admin_user['code']:
        from analyze.demo import create_main
        table_title, table_id = create_main()
        session.close()
        return jsonify({'results': {
            'table_title': table_title,
            'table_id': table_id,
            'unknown': {}
        }}), 200

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
        abort(400, {'code': frame.f_lineno, 'msg': 'シフトの解析に失敗しました', 'param': None})

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
                abort(409, {'code': frame.f_lineno, 'msg': '既に同じ日付でシフトが取り込まれています', 'param': None})

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

    params = ['convert', '-resize', '50%', '-density', '50', '-alpha', 'remove', origin_file_path+'[0]', thumbnail_file_path]
    subprocess.check_call(params)


    company_users = session.query(User) \
        .filter(User.company_id == admin_user.company_id,
                User.token != None,
                User.id != admin_user.id,
                User.is_shift_import_notification == True
                ) \
        .all()

    if len(company_users) != 0:
        tokens = [user.token for user in company_users]
        alert = '「{}」が「{}」を取り込みました'.format(admin_user.name, shift_table.title)
        res = client.send(tokens, alert, sound='default', badge=1)
        print('***************Add Comment*****************')
        print(res.errors)
        print(res.token_errors)
        print('***************Add Comment*****************')

    session.close()

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

    session.close()
    return jsonify({'results': results}), 200


@app.route('/api/v1/tables/<table_id>', methods=['GET'])
@api_basic_auth.login_required
def get_detail(table_id):
    table = session.query(ShiftTable).filter(ShiftTable.id == table_id).one_or_none()

    if table is None:
        session.close()
        frame = inspect.currentframe()
        abort(404, {'code': frame.f_lineno, 'msg': '指定された取り込み済みのシフトはありません', 'param': None})

    user = session.query(User).filter(User.code == api_basic_auth.username()).one()

    if user.company_id != table.company_id:
        session.close()
        frame = inspect.currentframe()
        abort(403, {'code': frame.f_lineno, 'msg': '権限がありません', 'param': None})

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
        abort(403, {'code': frame.f_lineno, 'msg': '権限がありません', 'param': None})

    table = session.query(ShiftTable).filter(ShiftTable.id == table_id).one_or_none()

    if table is None:
        session.close()
        frame = inspect.currentframe()
        abort(404, {'code': frame.f_lineno, 'msg': '指定された取り込み済みのシフトはありません', 'param': None})

    if table.company_id != user.company_id:
        session.close()
        frame = inspect.currentframe()
        abort(403, {'code': frame.f_lineno, 'msg': '権限がありません', 'param': None})

    if user.code != demo_admin_user['code']:
        os.remove(table.origin_path)
        os.remove(table.thumbnail_path)

    session.delete(table)
    session.commit()
    session.close()
    return jsonify({'msg': 'OK'}), 200
