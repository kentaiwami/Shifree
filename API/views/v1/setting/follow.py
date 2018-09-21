import inspect
from flask import Blueprint, request, jsonify, abort
from jsonschema import validate, ValidationError
from model import User, Follow
from database import session
from basic_auth import api_basic_auth
from config import demo_company


app = Blueprint('setting_follow_bp', __name__)


@app.route('/api/v1/setting/follow', methods=['GET'])
@api_basic_auth.login_required
def get():
    access_user = session.query(User).filter(User.code == api_basic_auth.username()).one()

    company_users = session.query(User)\
        .filter(User.company_id == access_user.company_id, User.id != access_user.id).all()
    results = []

    for user in company_users:
        results.append(user.name)

    session.close()
    return jsonify({'results': results}), 200
