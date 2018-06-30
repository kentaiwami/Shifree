import inspect
from flask import Blueprint, request, jsonify, abort
from jsonschema import validate, ValidationError
from model import User, UserShift, Shift, ShiftCategory, Company, ColorScheme
from database import session
from views.v1.response import response_msg_404, response_msg_403, response_msg_400
from basic_auth import api_basic_auth
from itertools import groupby
from datetime import datetime

app = Blueprint('user_shift_bp', __name__)


@app.route('/api/v1/usershift', methods=['GET'])
@api_basic_auth.login_required
def get():
    user = session.query(User).filter(User.code == api_basic_auth.username()).one()

    shit_results = []
    start = request.args.get('start', default='', type=str)
    end = request.args.get('end', default='', type=str)

    try:
        start = datetime.strptime(start, '%Y%m%d')
        end = datetime.strptime(end, '%Y%m%d')
    except ValidationError:
        session.close()
        frame = inspect.currentframe()
        abort(400, {'code': frame.f_lineno, 'msg': response_msg_400(), 'param': None})

    start.isoformat()
    start.isoformat()
    end.isoformat()
    end.isoformat()
    start = start.date()
    end = end.date()

    '''
    指定範囲のシフト情報を抽出
    '''
    user_shift = session.query(UserShift, Shift, ShiftCategory, User).join(User, Company, Shift, ShiftCategory).filter(UserShift.date.between(start, end), User.company_id == user.company_id).all()

    # 日付でグルーピング
    user_shift.sort(key=lambda tmp_user_shift: tmp_user_shift[0].date)
    for date, date_group in groupby(user_shift, key=lambda tmp_user_shift: tmp_user_shift[0].date):

        tmp_shift_group = []
        memo = None
        access_user_shift = None

        # シフトカテゴリのidでグルーピング
        date_group = list(date_group)
        date_group.sort(key=lambda tmp_user_shift: tmp_user_shift[2].id)
        for shift_category, shift_category_group in groupby(date_group, key=lambda tmp_user_shift: tmp_user_shift[2].name):

            users_shift = []

            for shift in shift_category_group:
                if shift[3].code == api_basic_auth.username():
                    color_scheme = session.query(ColorScheme).filter(ColorScheme.user_id == shift[3].id, ColorScheme.shift_category_id == shift[2].id).one_or_none()
                    hex = None
                    if color_scheme is not None:
                        hex = color_scheme.hex

                    memo = shift[0].memo
                    access_user_shift = {
                        'user': shift[3].name,
                        'shift_id': shift[0].id,
                        'shift_name': shift[1].name,
                        'color': hex
                    }

                users_shift.append({
                    'user': shift[3].name,
                    'shift_id': shift[0].id,
                    'shift_name': shift[1].name
                })

            tmp_shift_group.append({shift_category: users_shift})

        shit_results.append({
            'date': str(date),
            'shift_group': tmp_shift_group,
            'user_shift': access_user_shift,
            'memo': memo
        })


    '''
        シフトカテゴリの抽出
    '''
    shift_category_results = []
    shift_category_color_list = session.query(ShiftCategory, ColorScheme).join(ColorScheme).filter(ShiftCategory.company_id == user.company_id, ColorScheme.user_id == user.id).order_by(ShiftCategory.id.asc()).all()

    for shift_category_color in shift_category_color_list:
        shift_category_results.append({
            'name': shift_category_color[0].name,
            'hex': shift_category_color[1].hex
        })

    session.close()
    return jsonify({'results': {'shift': shit_results, 'shift_category': shift_category_results}}), 200



@app.route('/api/v1/usershift', methods=['PUT'])
@api_basic_auth.login_required
def update():
    schema = {'type': 'object',
              'properties':
                  {'shifts': {'type': 'array', 'minItems': 1, 'items': [{'type': 'object'}]}},
              'required': ['shifts']
              }

    try:
        validate(request.json, schema)
    except ValidationError as e:
        frame = inspect.currentframe()
        abort(400, {'code': frame.f_lineno, 'msg': e.message, 'param': None})

    admin_user = session.query(User).filter(User.code == api_basic_auth.username()).one()

    if admin_user.role.name != 'admin':
        session.close()
        frame = inspect.currentframe()
        abort(403, {'code': frame.f_lineno, 'msg': response_msg_403(), 'param': None})


    results = []

    for shift in request.json['shifts']:
        user_shift = session.query(UserShift).filter(UserShift.id == shift['id']).one_or_none()

        if user_shift is None:
            session.close()
            frame = inspect.currentframe()
            abort(404, {'code': frame.f_lineno, 'msg': response_msg_404(), 'param': None})

        user = session.query(User).filter(User.id == user_shift.user_id).one()

        if user.company_id != admin_user.company_id:
            session.close()
            frame = inspect.currentframe()
            abort(403, {'code': frame.f_lineno, 'msg': response_msg_403(), 'param': None})

        shift = session.query(Shift).join(ShiftCategory).filter(Shift.name == shift['name'], ShiftCategory.company_id == admin_user.company_id).one_or_none()

        if shift is None:
            session.close()
            frame = inspect.currentframe()
            abort(404, {'code': frame.f_lineno, 'msg': response_msg_404(), 'param': None})

        user_shift.shift_id = shift.id
        session.commit()

        results.append({
            'usershift_id': user_shift.id,
            'date': str(user_shift.date),
            'shift': shift.name,
            'user_id': user_shift.user_id,
            'shift_table_id': user_shift.shift_table_id
        })

    session.close()

    return jsonify({'results': results}), 200
