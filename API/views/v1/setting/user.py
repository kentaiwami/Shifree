from flask import Blueprint, request, jsonify
from jsonschema import validate, ValidationError
from model import User, Role
from database import session
from views.v1.response import response_msg_404, response_msg_403, response_msg_200
from basic_auth import api_basic_auth

app = Blueprint('setting_user_bp', __name__)


@app.route('/api/v1/setting/user', methods=['POST'])
@api_basic_auth.login_required
def add():
    schema = {'type': 'object',
              'properties':
                  {'name': {'type': 'string', 'minLength': 1},
                   'role': {'type': 'string', 'enum': ['admin', 'general']},
                   'order': {'type': 'integer', 'minimum': 1},
                   },
              'required': ['name', 'role', 'order']
              }

    try:
        validate(request.json, schema)
    except ValidationError as e:
        return jsonify({'msg': e.message}), 400

    admin_user = session.query(User).filter(User.code == api_basic_auth.username()).one()

    if admin_user.role.name != 'admin':
        session.close()
        return jsonify({'msg': response_msg_403()}), 403

    role = session.query(Role).filter(Role.name == request.json['role']).one()
    new_user = User(
        name=request.json['name'],
        role_id=role.id,
        company_id=admin_user.company_id,
        order=request.json['order']
    )

    session.add(new_user)
    session.commit()
    session.close()

    return jsonify({'results': {
        'name': new_user.name,
        'code': new_user.code,
        'password': new_user.password,
        'order': new_user.order
    }}), 200


@app.route('/api/v1/setting/users', methods=['GET'])
@api_basic_auth.login_required
def get():
    admin_user = session.query(User).filter(User.code == api_basic_auth.username()).one()

    if admin_user.role.name != 'admin':
        session.close()
        return jsonify({'msg': response_msg_403()}), 403

    users = session.query(User).filter(User.company_id == admin_user.company_id).all()

    results = []
    for user in users:
        is_active = False
        if len(user.password) != 7:
            is_active = True

        results.append({
            'name': user.name,
            'code': user.code,
            'order': user.order,
            'active': is_active
        })

    session.close()
    return jsonify({'results': results}), 200


@app.route('/api/v1/setting/users/<user_code>', methods=['PUT'])
@api_basic_auth.login_required
def update(user_code):
    schema = {'type': 'object',
              'properties':
                  {'name': {'type': 'string', 'minLength': 1},
                   'role': {'type': 'string', 'enum': ['admin', 'general']},
                   'order': {'type': 'integer', 'minimum': 1},
                   },
              'required': ['name', 'role', 'order']
              }

    try:
        validate(request.json, schema)
    except ValidationError as e:
        return jsonify({'msg': e.message}), 400

    admin_user = session.query(User).filter(User.code == api_basic_auth.username()).one()

    if admin_user.role.name != 'admin':
        session.close()
        return jsonify({'msg': response_msg_403()}), 403

    user = session.query(User).filter(User.code == user_code).one_or_none()

    if user is None:
        session.close()
        return jsonify({'msg': response_msg_404()}), 404

    if admin_user.company_id != user.company_id:
        session.close()
        return jsonify({'msg': response_msg_403()}), 403

    role = session.query(Role).filter(Role.name == request.json['role']).one()
    user.name = request.json['name']
    user.order = request.json['order']
    user.role_id = role.id

    session.commit()
    session.close()

    return jsonify({'results': {
        'name': user.name,
        'role': role.name,
        'order': user.order
    }}), 200


@app.route('/api/v1/setting/users/<user_code>', methods=['DELETE'])
@api_basic_auth.login_required
def delete(user_code):
    admin_user = session.query(User).filter(User.code == api_basic_auth.username()).one_or_none()

    if admin_user.role.name != 'admin':
        session.close()
        return jsonify({'msg': response_msg_403()}), 403

    user = session.query(User).filter(User.code == user_code).one_or_none()

    if user is None:
        session.close()
        return jsonify({'msg': response_msg_404()}), 404

    if admin_user.company_id != user.company_id:
        return jsonify({'msg': response_msg_403()}), 403

    session.delete(user)
    session.commit()
    session.close()

    return jsonify({'msg': response_msg_200()}), 200
