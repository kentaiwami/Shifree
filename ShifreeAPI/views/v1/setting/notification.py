import inspect
from flask import Blueprint, request, jsonify, abort
from jsonschema import validate, ValidationError
from model import User
from database import session
from basic_auth import api_basic_auth

app = Blueprint('setting_notification_bp', __name__)


@app.route('/api/v1/setting/notification', methods=['PUT'])
@api_basic_auth.login_required
def update():
    schema = {'type': 'object',
              'properties':
                  {'is_shift_import': {'type': 'boolean'},
                   'is_comment': {'type': 'boolean'},
                   'is_update_shift': {'type': 'boolean'},
                   },
              'required': ['is_shift_import', 'is_comment', 'is_update_shift']
              }

    try:
        validate(request.json, schema)
    except ValidationError as e:
        session.close()
        frame = inspect.currentframe()
        abort(400, {'code': frame.f_lineno, 'msg': e.message, 'param': None})

    user = session.query(User).filter(User.code == api_basic_auth.username()).one()

    user.is_shift_import_notification = request.json['is_shift_import']
    user.is_comment_notification = request.json['is_comment']
    user.is_update_shift_notification = request.json['is_update_shift']

    session.commit()
    session.close()
    return jsonify({
        'is_shift_import': user.is_shift_import_notification,
        'is_comment': user.is_comment_notification,
        'is_update_shift': user.is_update_shift_notification
    }), 200


@app.route('/api/v1/setting/notification', methods=['GET'])
@api_basic_auth.login_required
def get():
    user = session.query(User).filter(User.code == api_basic_auth.username()).one_or_none()
    session.close()

    return jsonify({
        'is_shift_import': user.is_shift_import_notification,
        'is_comment': user.is_comment_notification,
        'is_update_shift': user.is_update_shift_notification
    }), 200
