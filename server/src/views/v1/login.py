import inspect
from flask import Blueprint, jsonify, abort
from model import User, Role
from database import session
from basic_auth import api_basic_auth

app = Blueprint('login_bp', __name__)


@app.route('/api/v1/login', methods=['GET'])
@api_basic_auth.login_required
def login():
    user_role_results = session.query(User, Role).join(Role).filter(User.code == api_basic_auth.username()).one_or_none()
    session.close()

    if user_role_results is not None:
        return jsonify({'user_code': user_role_results[0].code, 'role': user_role_results[1].name}), 200
    else:
        frame = inspect.currentframe()
        abort(404, {'code': frame.f_lineno, 'msg': 'ログインに失敗しました。ログイン情報を再確認してください。', 'param': None})
