import inspect
from flask import Blueprint, jsonify, abort
from model import User, Company
from database import session
from basic_auth import api_basic_auth

app = Blueprint('company_bp', __name__)


@app.route('/api/v1/company', methods=['GET'])
@api_basic_auth.login_required
def get():
    user = session.query(User).filter(User.code == api_basic_auth.username()).one_or_none()

    if user is None:
        session.close()
        frame = inspect.currentframe()
        abort(404, {'code': frame.f_lineno, 'msg': '指定された企業情報が見つかりませんでした', 'param': None})

    company = session.query(Company).filter(Company.id == user.company_id).one()

    session.close()

    return jsonify({
        'same_line_threshold': company.default_same_line_threshold,
        'username_threshold': company.default_username_threshold,
        'join_threshold': company.default_join_threshold,
        'day_shift_threshold': company.default_day_shift_threshold
    }), 200
