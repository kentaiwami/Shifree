import inspect
from flask import Blueprint, request, jsonify, abort
from model import User, UserShift, Shift, ShiftCategory
from database import session
from basic_auth import api_basic_auth
from datetime import date

app = Blueprint('user_shift_analytics_bp', __name__)


@app.route('/api/v1/usershift/analytics', methods=['GET'])
@api_basic_auth.login_required
def get():
    range = request.args.get('range', default='', type=str)

    if range == 'now':
        pass
    elif range == 'prev':
        pass
    elif range == 'all':
        pass
    else:
        session.close()
        frame = inspect.currentframe()
        abort(400, {'code': frame.f_lineno, 'msg': '範囲の指定方法が間違っています', 'param': None})

    access_user = session.query(User).filter(User.code == api_basic_auth.username()).one()

    tmp = session.query(UserShift).filter(
        UserShift.user_id == access_user.id,
        UserShift.date == date.today()
    ).one_or_none()

    # hoge = session.query(UserShift).join(Shift, ShiftCategory).filter(
    #     UserShift.user_id == access_user.id
    # ).all()

    print('**********************')
    print(tmp.shift_table_id)
    print(date.today())
    print('**********************')

    session.close()

    return jsonify({'results': {
        'hoge': range

    }}), 200
