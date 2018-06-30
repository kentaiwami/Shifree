import inspect
from flask import Blueprint, request, jsonify, abort
from jsonschema import validate, ValidationError
from model import User, UserShift
from database import session
from views.v1.response import response_msg_404, response_msg_403
from basic_auth import api_basic_auth

app = Blueprint('user_shift_memo_bp', __name__)


@app.route('/api/v1/usershift/memo/<usershift_id>', methods=['PUT'])
@api_basic_auth.login_required
def update(usershift_id):
    schema = {'type': 'object',
              'properties':
                  {'text': {'type': 'string'}},
              'required': ['text']
              }

    try:
        validate(request.json, schema)
    except ValidationError as e:
        frame = inspect.currentframe()
        abort(400, {'code': frame.f_lineno, 'msg': e.message, 'param': None})

    user = session.query(User).filter(User.code == api_basic_auth.username()).one()
    user_shift = session.query(UserShift).filter(UserShift.id == usershift_id).one_or_none()

    if user_shift is None:
        session.close()
        frame = inspect.currentframe()
        abort(404, {'code': frame.f_lineno, 'msg': response_msg_404(), 'param': None})

    if user_shift.user_id != user.id:
        session.close()
        frame = inspect.currentframe()
        abort(403, {'code': frame.f_lineno, 'msg': response_msg_403(), 'param': None})

    user_shift.memo = request.json['text']
    session.commit()
    session.close()

    return jsonify({'results': {
        'usershift_id': user_shift.id,
        'date': str(user_shift.date),
        'user_id': user_shift.user_id,
        'memo': user_shift.memo
    }}), 200
