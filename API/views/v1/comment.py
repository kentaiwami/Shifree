from flask import Blueprint, jsonify, request
from jsonschema import validate, ValidationError
from model import User, Comment, ShiftTable
from database import session
from views.v1.response import response_msg_404, response_msg_403, response_msg_200
from basic_auth import api_basic_auth

app = Blueprint('comment_bp', __name__)


@app.route('/api/v1/comment', methods=['POST'])
@api_basic_auth.login_required
def add():
    schema = {'type': 'object',
              'properties':
                  {'table_id': {'type': 'integer', 'minimum': 0},
                   'text': {'type': 'string', 'minLength': 1}
                   },
              'required': ['table_id', 'text']
              }

    try:
        validate(request.json, schema)
    except ValidationError as e:
        return jsonify({'msg': e.message}), 400

    user = session.query(User).filter(User.code == api_basic_auth.username()).one()
    table = session.query(ShiftTable).filter(ShiftTable.id == request.json['table_id']).one_or_none()

    if table is None:
        session.close()
        return jsonify({'msg': response_msg_404()}), 404

    if table.company_id != user.company_id:
        session.close()
        return jsonify({'msg': response_msg_403()}), 403

    comment = Comment(text=request.json['text'], user_id=user.id, shifttable_id=table.id)
    session.add(comment)
    session.commit()
    session.close()

    return jsonify({'results': {'text': request.json['text'], 'id': comment.id}}), 200


@app.route('/api/v1/comment/<comment_id>', methods=['PUT'])
@api_basic_auth.login_required
def update(comment_id):
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
    comment = session.query(Comment).filter(Comment.id == comment_id).one_or_none()

    if comment is None:
        session.close()
        return jsonify({'msg': response_msg_404()}), 404

    if comment.user_id != user.id:
        session.close()
        return jsonify({'msg': response_msg_403()}), 403

    comment.text = request.json['text']
    session.commit()
    session.close()
    return jsonify({'results': {'text': request.json['text'], 'comment_id': comment.id}}), 200


@app.route('/api/v1/comment/<comment_id>', methods=['DELETE'])
@api_basic_auth.login_required
def delete(comment_id):
    user = session.query(User).filter(User.code == api_basic_auth.username()).one()
    comment = session.query(Comment).filter(Comment.id == comment_id).one_or_none()

    if comment is None:
        session.close()
        return jsonify({'msg': response_msg_404()}), 404

    if comment.user_id != user.id:
        session.close()
        return jsonify({'msg': response_msg_403()}), 403

    session.delete(comment)
    session.commit()
    session.close()
    return jsonify({'msg': response_msg_200()}), 200
