import inspect
from flask import Blueprint, request, jsonify, abort
from jsonschema import validate, ValidationError
from model import User, UserShift, Shift, ShiftCategory, Company, ColorScheme
from database import session
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
        abort(400, {'code': frame.f_lineno, 'msg': '開始日と終了日の指定方法が間違っています', 'param': None})

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

    session.close()
    return jsonify({'results': {'shift': shit_results}}), 200



@app.route('/api/v1/usershift', methods=['PUT'])
@api_basic_auth.login_required
def update():
    from app import client

    schema = {'type': 'object',
              'properties':
                  {'shifts': {'type': 'array', 'minItems': 1, 'items': [{'type': 'object'}]}},
              'required': ['shifts']
              }

    try:
        validate(request.json, schema)
    except ValidationError as e:
        session.close()
        frame = inspect.currentframe()
        abort(400, {'code': frame.f_lineno, 'msg': e.message, 'param': None})

    admin_user = session.query(User).filter(User.code == api_basic_auth.username()).one()

    if admin_user.role.name != 'admin':
        session.close()
        frame = inspect.currentframe()
        abort(403, {'code': frame.f_lineno, 'msg': '権限がありません', 'param': None})


    results = []
    alert_tokens = []

    for shift in request.json['shifts']:
        user_shift = session.query(UserShift).filter(UserShift.id == shift['id']).one_or_none()

        if user_shift is None:
            session.close()
            frame = inspect.currentframe()
            abort(404, {'code': frame.f_lineno, 'msg': '変更対象のシフトが見つかりませんでした', 'param': None})

        old_shift_name = user_shift.shift.name

        user = session.query(User).filter(User.id == user_shift.user_id).one()

        if user.company_id != admin_user.company_id:
            session.close()
            frame = inspect.currentframe()
            abort(403, {'code': frame.f_lineno, 'msg': '権限がありません', 'param': None})

        shift = session.query(Shift).join(ShiftCategory).filter(Shift.name == shift['name'], ShiftCategory.company_id == admin_user.company_id).one_or_none()

        if shift is None:
            session.close()
            frame = inspect.currentframe()
            abort(404, {'code': frame.f_lineno, 'msg': '変更対象のシフトが見つかりませんでした', 'param': None})

        user_shift.shift_id = shift.id
        session.commit()

        results.append({
            'usershift_id': user_shift.id,
            'date': str(user_shift.date),
            'shift': shift.name,
            'user_id': user_shift.user_id,
            'shift_table_id': user_shift.shift_table_id
        })

        if user.is_update_shift_notification is True and user.token is not None and user.id != admin_user.id:
            alert = '{}が{}のシフトを{}から{}へ変更しました'.format(admin_user.name, str(user_shift.date), old_shift_name, shift.name)
            alert_tokens.append({'alert': alert, 'token': user.token})

    session.close()

    for alert_token in alert_tokens:
        res = client.send(alert_token['token'], alert_token['alert'], sound='default', badge=1)
        print('***************Update UserShift*****************')
        print(res.errors)
        print(res.token_errors)
        print('***************Update UserShift*****************')

    return jsonify({'results': results}), 200


@app.route('/api/v1/usershift/unknowns', methods=['PUT'])
@api_basic_auth.login_required
def unknown_update():
    from app import client

    schema = {'type': 'object',
              'properties':
                  {'updates': {'type': 'array',
                               'items': {'type': 'object',
                                         'properties': {'code': {'type': 'string', 'pattern': '^[0-9]{7}$'},
                                                        'date': {'type': 'string', 'pattern': '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'},
                                                        'name': {'type': 'string', 'minLength': 1}
                                                        }
                                         }
                               }
                   },
              'required': ['updates']
              }

    try:
        validate(request.json, schema)
    except ValidationError as e:
        session.close()
        frame = inspect.currentframe()
        abort(400, {'code': frame.f_lineno, 'msg': e.message, 'param': None})

    admin_user = session.query(User).filter(User.code == api_basic_auth.username()).one()

    if admin_user.role.name != 'admin':
        session.close()
        frame = inspect.currentframe()
        abort(403, {'code': frame.f_lineno, 'msg': '権限がありません', 'param': None})

    alert_tokens = []

    for new_shift in request.json['updates']:
        shift = session.query(Shift).filter(Shift.name == new_shift['name']).one_or_none()
        user = session.query(User).filter(User.code == new_shift['code']).one_or_none()

        if shift is None or user is None:
            session.close()
            frame = inspect.currentframe()
            abort(404, {'code': frame.f_lineno, 'msg': '変更対象のシフトが見つかりませんでした', 'param': None})

        user_shift_result = session.query(UserShift)\
            .filter(UserShift.user_id == user.id,
                    UserShift.date == new_shift['date']
                    ).one_or_none()

        if user_shift_result is None:
            session.close()
            frame = inspect.currentframe()
            abort(404, {'code': frame.f_lineno, 'msg': '変更対象のシフトが見つかりませんでした', 'param': None})

        old_shift_name = user_shift_result.shift.name
        user_shift_result.shift_id = shift.id

        session.commit()

        if user.is_update_shift_notification is True and user.token is not None and user.id != admin_user.id:
            alert = '{}が{}のシフトを{}から{}へ変更しました'.format(admin_user.name, str(user_shift_result.date), old_shift_name, shift.name)
            alert_tokens.append({'alert': alert, 'token': user.token})

    session.close()

    for alert_token in alert_tokens:
        res = client.send(alert_token['token'], alert_token['alert'], sound='default', badge=1)
        print('***************Update UserShift*****************')
        print(res.errors)
        print(res.token_errors)
        print('***************Update UserShift*****************')

    return jsonify({'msg': 'OK'}), 200
