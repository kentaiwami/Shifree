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
                   },
              'required': ['number', 'start', 'end', 'title']
              }

    try:
        validate(request.form, schema)
    except ValidationError as e:
        session.close()
        frame = inspect.currentframe()
        abort(400, {'code': frame.f_lineno, 'msg': e.message, 'param': None})

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
    thumbnail_file_path = os.path.join(app.config['UPLOAD_FOLDER'], 'thumbnail', saved_file_fullname+'.jpg')

    if os.path.exists(origin_file_path):
        session.close()
        frame = inspect.currentframe()
        abort(409, {'code': frame.f_lineno, 'msg': response_msg_409(), 'param': None})

    # 企業ごとの解析プログラムを実行
    try:
        exec('from analyze.company{} import create_main'.format(company.id))
        user_results = eval('create_main({},{},\'{}\',\'{}\', file, origin_file_path)'.format(company.id, request.form['number'], request.form['start'], request.form['end']))
    except ValueError:
        frame = inspect.currentframe()
        abort(400, {'code': frame.f_lineno, 'msg': response_msg_400(), 'param': None})

    flatten_user_shifts = [item for sublist in user_results.shifts for item in sublist]
    shift_types = list(set(flatten_user_shifts))
    shift_types.remove(None)
    unknown_shift_types = []

    for shift in shift_types:
        if not session.query(exists().where(Shift.name == shift)).scalar():
            unknown_shift_types.append(shift)

    if len(unknown_shift_types) != 0:
        session.close()
        frame = inspect.currentframe()
        abort(500, {'code': frame.f_lineno, 'msg': '未登録のシフトがあるため、処理を完了できませんでした。', 'param': unknown_shift_types})

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

    for shifts, username in zip(user_results.shifts, user_results.names):
        user = [user for user in users if user.name == username][0]

        for i, shift_name in enumerate(shifts):
            if shift_name is None:
                shift_name = 'unknown'

            shift = session.query(Shift).filter(Shift.name == shift_name).one()

            date = (start_date + datetime.timedelta(days=i))
            user_shift = UserShift(date=date, shift_id=shift.id, user_id=user.id, shift_table_id=shift_table.id)

            user_shift_objects.append(user_shift)

        users.remove(user)

    session.bulk_save_objects(user_shift_objects)
    session.commit()

    params = ['convert', '-density', '600', origin_file_path + '[0]', thumbnail_file_path]
    subprocess.check_call(params)

    session.close()

    return jsonify({'results': {
        'table_title': shift_table.title,
        'table_id': shift_table.id
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

    comment_users = session.query(Comment, User).join(User).filter(Comment.shifttable_id == table.id).order_by(Comment.created_at.desc()).all()

    comment_list = []
    for comment_user in comment_users:
        if comment_user[0].user_id == user.id:
            comment_list.append({
                'text': comment_user[0].text,
                'id': comment_user[0].id,
                'created_at': str(comment_user[0].created_at)
            })
        else:
            comment_list.append({
                'text': comment_user[0].text,
                'created_at': str(comment_user[0].created_at)
            })

    results = {
        'table_id': table.id,
        'title': table.title,
        'origin': table.origin_path,
        'comment': comment_list
    }

    session.close()
    return jsonify({'results': results}), 200


@app.route('/api/v1/tables/<table_id>', methods=['PUT'])
@api_basic_auth.login_required
def update(table_id):
    from app import app

    schema = {'type': 'object',
              'properties':
                  {'number': {'type': 'string', 'minimum': 1},
                   'start': {'type': 'string', 'pattern': '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'},
                   'end': {'type': 'string', 'pattern': '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'},
                   'title': {'type': 'string', 'minLength': 1},
                   },
              'required': ['number', 'start', 'end', 'title']
              }

    try:
        validate(request.form, schema)
    except ValidationError as e:
        session.close()
        frame = inspect.currentframe()
        abort(400, {'code': frame.f_lineno, 'msg': e.message, 'param': None})

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

    table = session.query(ShiftTable).filter(ShiftTable.id == table_id).one_or_none()

    if table is None:
        session.close()
        frame = inspect.currentframe()
        abort(404, {'code': frame.f_lineno, 'msg': response_msg_404(), 'param': None})

    company = session.query(Company).filter(Company.id == user.company_id).one()

    # 企業ごとの解析プログラムを実行
    try:
        exec('from analyze.company' + str(company.id) + ' import update_main')
        old_file_path = eval('update_main('+str(table.id)+')')
    except ValueError:
        frame = inspect.currentframe()
        abort(400, {'code': frame.f_lineno, 'msg': response_msg_400(), 'param': None})

    os.remove(old_file_path['origin'])
    os.remove(old_file_path['thumbnail'])

    secure_title = format_text(request.form['title'])
    new_file_fullname = company.code + '_' + secure_title
    _, file_ext = os.path.splitext(file.filename)
    new_origin_file_path = os.path.join(app.config['UPLOAD_FOLDER'], 'origin', new_file_fullname+file_ext)
    new_thumbnail_file_path = os.path.join(app.config['UPLOAD_FOLDER'], 'thumbnail', new_file_fullname+'.jpg')

    file.save(new_origin_file_path)
    params = ['convert', new_origin_file_path + '[0]', new_thumbnail_file_path]
    subprocess.check_call(params)

    table.title = secure_title
    table.origin_path = new_origin_file_path
    table.thumbnail_path = new_thumbnail_file_path
    session.commit()
    session.close()

    return jsonify({'results': {
        'table_title': table.title,
        'table_id': table.id
    }}), 200


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
