import inspect
from flask import Blueprint, request, jsonify, abort
from jsonschema import validate, ValidationError
from werkzeug.security import generate_password_hash
from model import User
from database import session
from views.v1.response import response_msg_200
from basic_auth import api_basic_auth

app = Blueprint('setting_password_bp', __name__)


@app.route('/api/v1/setting/password', methods=['PUT'])
@api_basic_auth.login_required
def update():
    schema = {'type': 'object',
              'properties':
                  {'new_password': {'type': 'string', 'minLength': 7}},
              'required': ['new_password']
              }

    try:
        validate(request.json, schema)
    except ValidationError as e:
        session.close()
        frame = inspect.currentframe()
        abort(400, {'code': frame.f_lineno, 'msg': e.message, 'param': None})

    user = session.query(User).filter(User.code == api_basic_auth.username()).one()
    user.password = generate_password_hash(request.json['new_password'])

    session.commit()
    session.close()
    return jsonify({'msg': response_msg_200()}), 200
