from flask import Blueprint, request, jsonify
from jsonschema import validate, ValidationError
from model import User, UserShift, Shift, ShiftCategory, Company
from database import session
from views.v1.response import response_msg_404, response_msg_403, response_msg_200, response_msg_400
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
        return jsonify({'msg': response_msg_400()}), 400

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

        # シフトカテゴリのidでグルーピング
        date_group = list(date_group)
        date_group.sort(key=lambda tmp_user_shift: tmp_user_shift[2].id)
        for shift_category, shift_category_group in groupby(date_group, key=lambda tmp_user_shift: tmp_user_shift[2].name):

            users_shift = []

            for shift in shift_category_group:
                if shift[3].code == api_basic_auth.username():
                    memo = shift[0].memo

                users_shift.append({
                    'user': shift[3].name,
                    'shift_id': shift[0].id,
                    'shift_name': shift[1].name
                })

            tmp_shift_group.append({shift_category: users_shift})

        shit_results.append({
            'date': str(date),
            'shift_group': tmp_shift_group,
            'memo': memo
        })

    if user.role.name != 'admin':
        session.close()
        return jsonify({'results': {'shift': shit_results}}), 200

    '''
    シフト名の抽出
    '''
    shift_name_results = []
    shift_shift_categories = session.query(Shift, ShiftCategory).join(ShiftCategory, Company).filter(Company.id == user.company_id).order_by(Shift.id.asc()).all()
    shift_shift_categories.sort(key=lambda m: m[1].id)
    for key, group in groupby(shift_shift_categories, key=lambda m: m[1]):
        tmp_shift_names = []
        for q_results in group:
            tmp_shift_names.append(q_results[0].name)

        shift_name_results.append({key.name: tmp_shift_names})

    session.close()
    return jsonify({'results': {'shift_category': shift_name_results, 'shift': shit_results}}), 200


@app.route('/api/v1/usershift/<usershift_id>', methods=['PUT'])
@api_basic_auth.login_required
def update(usershift_id):
    schema = {'type': 'object',
              'properties':
                  {'shift_name': {'type': 'string', 'minLength': 1}},
              'required': ['shift_name']
              }

    try:
        validate(request.json, schema)
    except ValidationError as e:
        return jsonify({'msg': e.message}), 400

    admin_user = session.query(User).filter(User.code == api_basic_auth.username()).one()

    if admin_user.role.name != 'admin':
        session.close()
        return jsonify({'msg': response_msg_403()}), 403

    user_shift = session.query(UserShift).filter(UserShift.id == usershift_id).one_or_none()

    if user_shift is None:
        session.close()
        return jsonify({'msg': response_msg_404()}), 404

    user = session.query(User).filter(User.id == user_shift.user_id).one()

    if user.company_id != admin_user.company_id:
        session.close()
        return jsonify({'msg': response_msg_403()}), 403

    shift = session.query(Shift).join(ShiftCategory).filter(Shift.name == request.json['shift_name'], ShiftCategory.company_id == admin_user.company_id).one_or_none()

    if shift is None:
        session.close()
        return jsonify({'msg': response_msg_404()}), 404

    user_shift.shift_id = shift.id
    session.commit()
    session.close()

    return jsonify({'results': {
        'usershift_id': user_shift.id,
        'date': str(user_shift.date),
        'shift': shift.name,
        'user_id': user_shift.user_id,
        'shift_table_id': user_shift.shift_table_id
    }}), 200


@app.route('/api/v1/usershift/<usershift_id>', methods=['DELETE'])
@api_basic_auth.login_required
def delete(usershift_id):
    admin_user = session.query(User).filter(User.code == api_basic_auth.username()).one()

    if admin_user.role.name != 'admin':
        session.close()
        return jsonify({'msg': response_msg_403()}), 403

    user_shift = session.query(UserShift).filter(UserShift.id == usershift_id).one_or_none()

    if user_shift is None:
        session.close()
        return jsonify({'msg': response_msg_404()}), 404

    user = session.query(User).filter(User.id == user_shift.user_id).one()

    if user.company_id != admin_user.company_id:
        session.close()
        return jsonify({'msg': response_msg_403()}), 403

    session.delete(user_shift)
    session.commit()
    session.close()

    return jsonify({'msg': response_msg_200()}), 200
