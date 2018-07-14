import inspect
from flask import Blueprint, jsonify, request, abort
from jsonschema import validate, ValidationError
from model import User, Comment, ShiftTable
from database import session
from views.v1.response import response_msg_404, response_msg_403
from basic_auth import api_basic_auth

app = Blueprint('comment_bp', __name__)


@app.route('/api/v1/comment', methods=['POST'])
@api_basic_auth.login_required
def add():
    from app import client

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
        frame = inspect.currentframe()
        abort(400, {'code': frame.f_lineno, 'msg': e.message, 'param': None})

    user = session.query(User).filter(User.code == api_basic_auth.username()).one()
    table = session.query(ShiftTable).filter(ShiftTable.id == request.json['table_id']).one_or_none()

    if table is None:
        session.close()
        frame = inspect.currentframe()
        abort(404, {'code': frame.f_lineno, 'msg': response_msg_404(), 'param': None})

    if table.company_id != user.company_id:
        session.close()
        frame = inspect.currentframe()
        abort(403, {'code': frame.f_lineno, 'msg': response_msg_403(), 'param': None})

    comment = Comment(text=request.json['text'], user_id=user.id, shifttable_id=table.id)
    session.add(comment)
    session.commit()


    company_users = session.query(User)\
        .filter(User.company_id == user.company_id,
                User.token is not None,
                User.id != user.id,
                User.is_comment_notification == True
                )\
        .all()

    if len(company_users) != 0:
        tokens = [user.token for user in company_users]
        alert = '「{}」が「{}」にコメントを追加しました'.format(user.name, table.title)
        res = client.send(tokens, alert, sound='default', badge=1)
        print('***************Add Comment*****************')
        print(res.errors)
        print(res.token_errors)
        print('***************Add Comment*****************')

    session.close()

    return jsonify({'results': {'text': request.json['text'], 'id': comment.id}}), 200


@app.route('/api/v1/comment/<comment_id>', methods=['PUT'])
@api_basic_auth.login_required
def update_or_delete(comment_id):
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
    comment = session.query(Comment).filter(Comment.id == comment_id).one_or_none()

    if comment is None:
        session.close()
        frame = inspect.currentframe()
        abort(404, {'code': frame.f_lineno, 'msg': response_msg_404(), 'param': None})

    if comment.user_id != user.id:
        session.close()
        frame = inspect.currentframe()
        abort(403, {'code': frame.f_lineno, 'msg': response_msg_403(), 'param': None})

    if len(request.json['text']) == 0:
        session.delete(comment)
    else:
        comment.text = request.json['text']

    session.commit()
    session.close()
    return jsonify({'results': {'text': request.json['text'], 'comment_id': comment.id}}), 200
