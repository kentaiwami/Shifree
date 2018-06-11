from flask import Blueprint, request, jsonify
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
                  {'text': {'type': 'string', 'minLength': 1}},
              'required': ['text']
              }

    try:
        validate(request.json, schema)
    except ValidationError as e:
        return jsonify({'msg': e.message}), 400

    user = session.query(User).filter(User.code == api_basic_auth.username()).one()
    user_shift = session.query(UserShift).filter(UserShift.id == usershift_id).one_or_none()

    if user_shift is None:
        session.close()
        return jsonify({'msg': response_msg_404()}), 404

    if user_shift.user_id != user.id:
        session.close()
        return jsonify({'msg': response_msg_403()}), 403

    user_shift.memo = request.json['text']
    session.commit()
    session.close()

    return jsonify({'results': {
        'usershift_id': user_shift.id,
        'date': str(user_shift.date),
        'user_id': user_shift.user_id,
        'memo': user_shift.memo
    }}), 200


@app.route('/api/v1/usershift/memo/<usershift_id>', methods=['DELETE'])
@api_basic_auth.login_required
def delete(usershift_id):
    user = session.query(User).filter(User.code == api_basic_auth.username()).one()
    user_shift = session.query(UserShift).filter(UserShift.id == usershift_id).one_or_none()

    if user_shift is None:
        session.close()
        return jsonify({'msg': response_msg_404()}), 404

    if user_shift.user_id != user.id:
        session.close()
        return jsonify({'msg': response_msg_403()}), 403

    user_shift.memo = ''
    session.commit()
    session.close()

    return jsonify({'results': {
        'usershift_id': user_shift.id,
        'date': str(user_shift.date),
        'user_id': user_shift.user_id,
        'memo': user_shift.memo
    }}), 200