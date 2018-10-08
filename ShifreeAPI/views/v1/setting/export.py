import inspect
from flask import Blueprint, request, jsonify, abort
from model import User, Follow
from database import session
from basic_auth import api_basic_auth


app = Blueprint('setting_export_bp', __name__)


@app.route('/api/v1/setting/export', methods=['GET'])
@api_basic_auth.login_required
def get_export_init():
    users = []

    access_user = session.query(User).filter(User.code == api_basic_auth.username()).one()

    company_users = session.query(User).filter(
        User.company_id == access_user.company_id
    ).all()

    for user in company_users:
        users.append({'name': user.name, 'id': user.id})

    follow = session.query(Follow, User) \
        .join(User, Follow.follow_id == User.id) \
        .filter(Follow.user_id == access_user.id) \
        .one_or_none()

    if follow:
        follow_name = follow[1].name
    else:
        follow_name = None

    return jsonify({
        'username': access_user.name,
        'follow': follow_name,
        'users': users
    }), 200


@app.route('/api/v1/setting/export/user/<id>', methods=['GET'])
@api_basic_auth.login_required
def get_user_shift(id):
    # 対象のシフトを返す
    return jsonify({'results': ''}), 200