from flask import Blueprint, request, jsonify
from jsonschema import validate, ValidationError
from werkzeug.security import generate_password_hash
from model import User, Company
from database import session
from views.v1.response import response_msg_404

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
        return jsonify({'msg': e.message}), 400

    user = session.query(User).join(Company.users)\
        .filter(Company.code == request.json['company_code'],
                User.name == request.json['username'],
                User.code == request.json['user_code'],
                User.password == request.json['password']).one_or_none()

    if user is None:
        session.close()
        return jsonify({'msg': response_msg_404()}), 404
    else:
        user.password = generate_password_hash(request.json['password'])
        session.commit()
        user_id = user.id
        session.close()
        return jsonify({'results': user_id}), 200
