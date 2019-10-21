import inspect
from flask import Blueprint, request, jsonify, abort
from jsonschema import validate, ValidationError
from werkzeug.security import generate_password_hash, check_password_hash
from model import User, Company
from database import session
from config import demo_admin_user, demo_general_user

app = Blueprint('auth_bp', __name__)


@app.route('/api/v1/auth', methods=['POST'])
def auth():
    schema = {'type': 'object',
              'properties':
                  {'company_code': {'type': 'string', 'minLength': 7, 'maxLength': 7},
                   'user_code': {'type': 'string', 'minLength': 7, 'maxLength': 7},
                   'username': {'type': 'string', 'minLength': 1},
                   'password': {'type': 'string', 'minLength': 7}
                   },
              'required': ['company_code', 'user_code', 'username', 'password']
              }

    try:
        validate(request.json, schema)
    except ValidationError as e:
        session.close()
        frame = inspect.currentframe()
        abort(400, {'code': frame.f_lineno, 'msg': e.message, 'param': None})

    user = session.query(User).join(Company.users) \
        .filter(Company.code == request.json['company_code'],
                User.name == request.json['username'],
                User.code == request.json['user_code']).one_or_none()

    if user is None:
        session.close()
        frame = inspect.currentframe()
        abort(404, {'code': frame.f_lineno, 'msg': '指定したユーザは存在しません', 'param': None})


    if user.code == demo_admin_user['code'] or user.code == demo_general_user['code']:
        session.close()
        return jsonify({'user_id': user.id}), 200


    if user.is_authed:
        user = session.query(User).join(Company.users)\
            .filter(Company.code == request.json['company_code'],
                    User.name == request.json['username'],
                    User.code == request.json['user_code'],
                    check_password_hash(user.password, request.json['password'])).one_or_none()
    else:
        user = session.query(User).join(Company.users) \
            .filter(Company.code == request.json['company_code'],
                    User.name == request.json['username'],
                    User.code == request.json['user_code'],
                    User.password == request.json['password']).one_or_none()

    if user is None:
        session.close()
        frame = inspect.currentframe()
        abort(404, {'code': frame.f_lineno, 'msg': '指定したユーザは存在しません', 'param': None})

    user.password = generate_password_hash(request.json['password'])
    user.is_authed = True
    session.commit()
    session.close()
    return jsonify({'user_id': user.id}), 200
