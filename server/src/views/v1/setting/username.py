import inspect
from flask import Blueprint, request, jsonify, abort
from jsonschema import validate, ValidationError
from model import User
from database import session
from basic_auth import api_basic_auth
from config import demo_general_user, demo_admin_user

app = Blueprint('setting_username_bp', __name__)


@app.route('/api/v1/setting/username', methods=['PUT'])
@api_basic_auth.login_required
def update():
    schema = {'type': 'object',
              'properties':
                  {'username': {'type': 'string', 'minLength': 1}},
              'required': ['username']
              }

    try:
        validate(request.json, schema)
    except ValidationError as e:
        session.close()
        frame = inspect.currentframe()
        abort(400, {'code': frame.f_lineno, 'msg': e.message, 'param': None})

    user = session.query(User).filter(User.code == api_basic_auth.username()).one()


    if user.code == demo_admin_user['code'] or user.code == demo_general_user['code']:
        session.close()
        return jsonify({'name': user.name}), 200


    user.name = request.json['username']

    session.commit()
    session.close()
    return jsonify({'name': request.json['username']}), 200
