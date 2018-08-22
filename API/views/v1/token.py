import inspect
from flask import Blueprint, jsonify, request, abort
from jsonschema import validate, ValidationError
from model import User
from database import session
from basic_auth import api_basic_auth

app = Blueprint('token_bp', __name__)


@app.route('/api/v1/token', methods=['PUT'])
@api_basic_auth.login_required
def update_token():
    schema = {'type': 'object',
              'properties':
                  {'token': {'type': 'string', 'minLength': 64, 'maxLength': 64}
                   },
              'required': ['token']
              }

    try:
        validate(request.json, schema)
    except ValidationError as e:
        session.close()
        frame = inspect.currentframe()
        abort(400, {'code': frame.f_lineno, 'msg': e.message, 'param': None})

    user = session.query(User).filter(User.code == api_basic_auth.username()).one()
    user.token = request.json['token']

    session.commit()
    session.close()

    return jsonify({'msg': 'OK'}), 200
