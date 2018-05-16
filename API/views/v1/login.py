from flask import Blueprint, jsonify
from model import User, Role
from database import session
from views.v1.response import response_msg_404
from basic_auth import api_basic_auth

app = Blueprint('login_bp', __name__)


@app.route('/api/v1/login', methods=['GET'])
@api_basic_auth.login_required
def login():
    user_role = session.query(User, Role).join(Role).filter(User.code == api_basic_auth.username()).one_or_none()
    session.close()

    if user_role is not None:
        return jsonify({'results': {'user_code': user_role[0].code, 'role': user_role[1].name}}), 200
    else:
        return jsonify({'msg': response_msg_404()}), 404
