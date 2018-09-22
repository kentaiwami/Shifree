import inspect
from flask import Blueprint, request, jsonify, abort
from jsonschema import validate, ValidationError
from model import User, Follow
from database import session
from basic_auth import api_basic_auth
from config import demo_admin_user, demo_general_user


app = Blueprint('setting_follow_bp', __name__)


@app.route('/api/v1/setting/follow', methods=['PUT'])
@api_basic_auth.login_required
def create_or_update_or_delete():
    schema = {'type': 'object',
              'properties':
                  {'username': {'type': 'string'}},
              'required': ['username']
              }

    try:
        validate(request.json, schema)
    except ValidationError as e:
        session.close()
        frame = inspect.currentframe()
        abort(400, {'code': frame.f_lineno, 'msg': e.message, 'param': None})



    access_user = session.query(User).filter(User.code == api_basic_auth.username()).one()

    if access_user.code == demo_admin_user['code'] or access_user.code == demo_general_user['code']:
        session.close()
        return jsonify({'name': request.json['username']}), 200



    follow = session.query(Follow).filter(Follow.user_id == access_user.id).one_or_none()
    new_follow_user = session.query(User).filter(
        User.name == request.json['username'],
        User.id != access_user.id,
        User.company_id == access_user.company_id
    ).one_or_none()

    if len(request.json['username']) == 0:
        if follow:
            session.delete(follow)
    else:
        if not new_follow_user:
            session.close()
            frame = inspect.currentframe()
            abort(404, {'code': frame.f_lineno, 'msg': '対象ユーザが見つかりませんでした', 'param': None})

        if follow:
            follow.follow_id = new_follow_user.id
        else:
            new_follow = Follow(user_id=access_user.id, follow_id=new_follow_user.id)
            session.add(new_follow)

    session.commit()
    session.close()
    return jsonify({'name': request.json['username']}), 200


@app.route('/api/v1/setting/follow', methods=['GET'])
@api_basic_auth.login_required
def get():
    users = []
    access_user = session.query(User).filter(User.code == api_basic_auth.username()).one()

    company_users = session.query(User).filter(
        User.company_id == access_user.company_id,
        User.id != access_user.id
    ).all()

    for user in company_users:
        users.append(user.name)

    follow = session.query(Follow, User)\
        .join(User, Follow.follow_id == User.id)\
        .filter(Follow.user_id == access_user.id)\
        .one_or_none()

    if follow:
        follow_name = follow[1].name
    else:
        follow_name = None

    session.close()
    return jsonify({'results': {'users': users, 'follow': follow_name}}), 200
