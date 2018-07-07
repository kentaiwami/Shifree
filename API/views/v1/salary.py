import inspect
from flask import Blueprint, jsonify, abort
from model import User, Salary, ShiftTable, Shift, UserShift
from database import session
from views.v1.response import response_msg_404
from basic_auth import api_basic_auth
from .table import get_salary

app = Blueprint('salary_bp', __name__)


@app.route('/api/v1/salary', methods=['GET'])
@api_basic_auth.login_required
def get():
    user = session.query(User).filter(User.code == api_basic_auth.username()).one_or_none()

    if user is None:
        session.close()
        frame = inspect.currentframe()
        abort(404, {'code': frame.f_lineno, 'msg': response_msg_404(), 'param': None})

    salary_tables_results = session.query(Salary, ShiftTable)\
        .join(ShiftTable)\
        .filter(Salary.user_id == user.id)\
        .order_by(Salary.created_at.desc())\
        .all()

    results = []
    for salary, table in salary_tables_results:
        results.append({'pay': salary.pay, 'title': table.title})

    return jsonify({'results': results}), 200


@app.route('/api/v1/salary', methods=['PUT'])
@api_basic_auth.login_required
def update():
    user = session.query(User).filter(User.code == api_basic_auth.username()).one_or_none()

    if user is None:
        session.close()
        frame = inspect.currentframe()
        abort(404, {'code': frame.f_lineno, 'msg': response_msg_404(), 'param': None})

    table_usershift_results = session.query(ShiftTable, UserShift, Shift)\
        .join(UserShift, ShiftTable.id == UserShift.shift_table_id)\
        .join(Shift, UserShift.shift_id == Shift.id)\
        .filter(UserShift.user_id == user.id)\
        .all()

    if table_usershift_results is None:
        session.close()
        frame = inspect.currentframe()
        abort(404, {'code': frame.f_lineno, 'msg': response_msg_404(), 'param': None})

    current_table_id = table_usershift_results[0][0].id
    tmp_salary = 0

    for table, user_shift, shift in table_usershift_results:
        if current_table_id == table.id:
            tmp_salary += get_salary(user, shift)
        else:
            salary = session.query(Salary).filter(Salary.user_id == user.id, Salary.shifttable_id == current_table_id).one_or_none()

            if salary is None:
                new_salary = Salary(pay=tmp_salary, user_id=user.id, shifttable_id=current_table_id)
                session.add(new_salary)
            else:
                salary.pay = tmp_salary

            current_table_id = table.id
            tmp_salary = 0

    salary = session.query(Salary).filter(Salary.user_id == user.id, Salary.shifttable_id == current_table_id).one_or_none()

    if salary is None:
        new_salary = Salary(pay=tmp_salary, user_id=user.id, shifttable_id=current_table_id)
        session.add(new_salary)
    else:
        salary.pay = tmp_salary

    session.commit()

    salary_tables_results = session.query(Salary, ShiftTable)\
        .join(ShiftTable)\
        .filter(Salary.user_id == user.id)\
        .order_by(Salary.created_at.desc())\
        .all()

    results = []
    for salary, table in salary_tables_results:
        results.append({'pay': salary.pay, 'title': table.title})
    session.close()

    return jsonify({'results': results}), 200
