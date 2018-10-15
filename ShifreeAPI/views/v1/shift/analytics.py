import inspect
from flask import Blueprint, request, jsonify, abort
from model import User, UserShift, Shift, ShiftCategory, ShiftTable, Follow
from database import session
from basic_auth import api_basic_auth
import collections


app = Blueprint('user_shift_analytics_bp', __name__)


@app.route('/api/v1/usershift/analytics', methods=['GET'])
@api_basic_auth.login_required
def get():
    range = request.args.get('range', default='', type=str)
    access_user = session.query(User).filter(User.code == api_basic_auth.username()).one()

    follow = session.query(Follow, User) \
        .join(User, Follow.follow_id == User.id) \
        .filter(Follow.user_id == access_user.id) \
        .one_or_none()

    if follow:
        current_user = session.query(User).filter(User.id == follow[1].id).one()
    else:
        current_user = access_user

    if range == 'latest':
        offset = 0
        limit = 1
    elif range == 'prev':
        offset = 0
        limit = 2
    elif range == 'all':
        offset = request.args.get('offset', default=0, type=int)
        limit = 5
    else:
        session.close()
        frame = inspect.currentframe()
        abort(400, {'code': frame.f_lineno, 'msg': '範囲の指定方法が間違っています', 'param': None})


    tables = session.query(ShiftTable).filter(
        ShiftTable.company_id == current_user.company_id
    ).order_by(ShiftTable.start.desc()).limit(limit).offset(offset).all()

    results = []

    for table in tables:
        user_shift_category = session.query(UserShift, ShiftCategory).join(ShiftTable, Shift, ShiftCategory).filter(
            UserShift.user_id == current_user.id,
            ShiftTable.id == table.id
        ).all()

        counter_dict = dict(
            collections.Counter([user_shift_category[1].name for user_shift_category in user_shift_category]))
        count_sum = 0
        categories = []

        for key in sorted(counter_dict, key=counter_dict.get, reverse=True):
            categories.append({'count': counter_dict[key], 'name': key})
            count_sum += counter_dict[key]

        results.append({
            'sum': count_sum,
            'category': categories,
            'title': table.title,
            'start': str(table.start),
            'end': str(table.end)
        })

    session.close()
    return jsonify({'results': {'table': results, 'follow': True if follow else False}}), 200
