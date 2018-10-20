import inspect
from flask import Blueprint, request, jsonify, abort
from model import User, UserShift, Shift, ShiftCategory, ShiftTable, Follow, ColorScheme
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

    shift_category_results = session.query(ShiftCategory).filter(
        ShiftCategory.company_id == access_user.company_id).order_by(ShiftCategory.id.asc()).all()

    # アクセスしたユーザがカラー設定を全て行なっているかを判定
    is_all_color_setting = False
    if follow:
        access_user_color_results = session.query(ColorScheme).filter(ColorScheme.user_id == access_user.id).all()
        is_all_color_setting = True if len(shift_category_results) == len(access_user_color_results) else False

    if not (follow and is_all_color_setting):
        current_user_color_results = session.query(ColorScheme).filter(ColorScheme.user_id == current_user.id).all()
    else:
        current_user_color_results = access_user_color_results


    results = []

    for table in tables:
        user_shift_category = session.query(UserShift, ShiftCategory).join(ShiftTable, Shift, ShiftCategory).filter(
            UserShift.user_id == current_user.id,
            ShiftTable.id == table.id
        ).all()

        counter_dict = dict(collections.Counter([user_shift_category[1].id for user_shift_category in user_shift_category]))
        categories = []

        for shift_category in shift_category_results:
            # ループの対象となっているカテゴリーidと一致するcolorを検索
            color_scheme_search_results = [color_scheme for color_scheme in current_user_color_results if color_scheme.shift_category_id == shift_category.id]
            hex = None if len(color_scheme_search_results) == 0 else color_scheme_search_results[0].hex

            if shift_category.id in counter_dict.keys():
                categories.append({'count': counter_dict[shift_category.id], 'name': shift_category.name, 'hex': hex})
            else:
                categories.append({'count': 0, 'name': shift_category.name, 'hex': hex})

        results.append({
            'category': categories,
            'title': table.title,
            'start': str(table.start),
            'end': str(table.end)
        })

    session.close()
    return jsonify({'results': {'table': results, 'follow': follow[1].name if follow else ''}}), 200
