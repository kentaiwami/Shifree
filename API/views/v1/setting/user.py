import inspect
from flask import Blueprint, request, jsonify, abort
from jsonschema import validate, ValidationError
from model import User, Role, Company
from database import session
from views.v1.response import response_msg_404, response_msg_403, response_msg_200
from basic_auth import api_basic_auth

app = Blueprint('setting_user_bp', __name__)


@app.route('/api/v1/setting/users', methods=['PUT'])
@api_basic_auth.login_required
def add_update_delete():
    schema = {'type': 'object',
              'properties':
                  {'adds': {'type': 'array',
                               'items': {'type': 'object',
                                         'properties': {'name': {'type': 'string'}, 'role': {'type': 'string', 'enum': ['admin', 'general']}, 'order': {'type': 'integer', 'minimum': 1}},
                                         'required': ['name', 'role', 'order']
                                         }
                               },
                   'updates': {'type': 'array',
                               'items': {'type': 'object',
                                         'properties': {'user_code': {'type': 'string'}, 'role': {'type': 'string', 'enum': ['admin', 'general']}, 'order': {'type': 'integer', 'minimum': 1}},
                                         'required': ['user_code', 'role', 'order']
                                         }
                               },
                   'deletes': {'type': 'array', 'items': {'type': 'string'}}},
              'required': ['adds', 'updates', 'deletes']
              }

    try:
        validate(request.json, schema)
    except ValidationError as e:
        frame = inspect.currentframe()
        abort(400, {'code': frame.f_lineno, 'msg': e.message, 'param': None})


    admin_user = session.query(User).filter(User.code == api_basic_auth.username()).one_or_none()

    if admin_user.role.name != 'admin':
        session.close()
        frame = inspect.currentframe()
        abort(403, {'code': frame.f_lineno, 'msg': response_msg_403(), 'param': None})

    for user_code in request.json['deletes']:
        user = session.query(User).filter(User.code == user_code).one_or_none()

        if user is None:
            session.close()
            frame = inspect.currentframe()
            abort(404, {'code': frame.f_lineno, 'msg': response_msg_404(), 'param': None})

        if admin_user.company_id != user.company_id:
            frame = inspect.currentframe()
            abort(403, {'code': frame.f_lineno, 'msg': response_msg_403(), 'param': None})

        session.delete(user)


    for request_user_obj in request.json['updates']:
        user = session.query(User).filter(User.code == request_user_obj['user_code']).one_or_none()

        if user is None:
            session.close()
            frame = inspect.currentframe()
            abort(404, {'code': frame.f_lineno, 'msg': response_msg_404(), 'param': None})

        if admin_user.company_id != user.company_id:
            session.close()
            frame = inspect.currentframe()
            abort(403, {'code': frame.f_lineno, 'msg': response_msg_403(), 'param': None})

        role = session.query(Role).filter(Role.name == request_user_obj['role']).one()
        user.order = request_user_obj['order']
        user.role_id = role.id

        session.commit()


    for request_user_obj in request.json['adds']:
        role = session.query(Role).filter(Role.name == request_user_obj['role']).one()
        new_user = User(
            name=request_user_obj['name'],
            role_id=role.id,
            company_id=admin_user.company_id,
            order=request_user_obj['order']
        )

        session.add(new_user)

    session.commit()
    session.close()
    return jsonify({'msg': response_msg_200()}), 200


@app.route('/api/v1/setting/users', methods=['GET'])
@api_basic_auth.login_required
def get():
    admin_user = session.query(User).filter(User.code == api_basic_auth.username()).one()

    if admin_user.role.name != 'admin':
        session.close()
        frame = inspect.currentframe()
        abort(403, {'code': frame.f_lineno, 'msg': response_msg_403(), 'param': None})

    users_role = session.query(User, Role).join(Role).filter(User.company_id == admin_user.company_id).order_by(User.order.asc()).all()
    company = session.query(Company).filter(Company.id == admin_user.company_id).one()

    users = []
    for user, role in users_role:
        users.append({
            'name': user.name,
            'code': user.code,
            'order': user.order,
            'role': role.name,
            'password': '*******' if user.is_authed else user.password
        })

    session.close()
    return jsonify({'results': {'users': users, 'company': company.code}}), 200
