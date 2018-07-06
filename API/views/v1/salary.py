import inspect
from flask import Blueprint, jsonify, abort
from model import User, Salary, ShiftTable
from database import session
from views.v1.response import response_msg_404
from basic_auth import api_basic_auth

app = Blueprint('salary_bp', __name__)


@app.route('/api/v1/salary', methods=['GET'])
@api_basic_auth.login_required
def get():
    user = session.query(User).filter(User.code == api_basic_auth.username()).one_or_none()

    if user is None:
        session.close()
        frame = inspect.currentframe()
        abort(404, {'code': frame.f_lineno, 'msg': response_msg_404(), 'param': None})

    salary_tables = session.query(Salary, ShiftTable).join(ShiftTable).filter(Salary.user_id == user.id).order_by(
        Salary.created_at.desc()).all()

    results = []
    for salary_table in salary_tables:
        results.append({'pay': salary_table[0].pay, 'title': salary_table[1].title})

    return jsonify({'results': results}), 200


@app.route('/api/v1/salary', methods=['PUT'])
@api_basic_auth.login_required
def update():
    return jsonify({'results': [{'pay': 100, 'title': 'UNKO'}]}), 200