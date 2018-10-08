import inspect
from flask import Blueprint, request, jsonify, abort
from model import User, Follow, ShiftTable, UserShift, Shift
from database import session
from basic_auth import api_basic_auth


app = Blueprint('setting_export_bp', __name__)


@app.route('/api/v1/setting/export/init', methods=['GET'])
@api_basic_auth.login_required
def get_export_init():
    access_user = session.query(User).filter(User.code == api_basic_auth.username()).one()

    company_users = session.query(User).filter(
        User.company_id == access_user.company_id
    ).all()

    follow = session.query(Follow, User) \
        .join(User, Follow.follow_id == User.id) \
        .filter(Follow.user_id == access_user.id) \
        .one_or_none()

    if follow:
        follow_user = {'id': follow[1].id, 'name': follow[1].name}
    else:
        follow_user = None

    company_tables = session.query(ShiftTable).filter(ShiftTable.company_id == access_user.company_id).all()

    session.close()
    return jsonify({
        'you': {'id': access_user.id, 'name': access_user.name},
        'follow': follow_user,
        'users': [{'name': user.name, 'id': user.id} for user in company_users],
        'tables': [{'id': table.id, 'title': table.title} for table in company_tables]
    }), 200


@app.route('/api/v1/setting/export/shift', methods=['GET'])
@api_basic_auth.login_required
def get_user_shift():
    user_id = request.args.get('user_id', default=-1, type=int)
    table_id = request.args.get('table_id', default=-1, type=int)

    if user_id == -1 or table_id == -1:
        session.close()
        frame = inspect.currentframe()
        abort(400, {'code': frame.f_lineno, 'msg': 'IDの指定方法が間違っています', 'param': None})

    shifts = session.query(UserShift, Shift).join(Shift).filter(
        UserShift.user_id == user_id,
        UserShift.shift_table_id == table_id
    ).all()

    shift_results = []
    for shift in shifts:
        shift_results.append({
            'user': shift[0].user.name,
            'shift': shift[1].name,
            'date': str(shift[0].date),
            'start': None if shift[1].start is None else str(shift[1].start),
            'end': None if shift[1].end is None else str(shift[1].end)
        })

    session.close()
    return jsonify({'results': shift_results}), 200
