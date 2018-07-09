import inspect
from flask import Blueprint, request, jsonify, abort
from jsonschema import validate, ValidationError
from model import User, ShiftCategory, Company
from database import session
from views.v1.response import response_msg_404, response_msg_403, response_msg_409, response_msg_200
from basic_auth import api_basic_auth

app = Blueprint('setting_shitcategory_bp', __name__)


@app.route('/api/v1/setting/shiftcategory', methods=['GET'])
@api_basic_auth.login_required
def get():
    user = session.query(User).filter(User.code == api_basic_auth.username()).one()
    shift_categories = session.query(ShiftCategory).join(Company).filter(ShiftCategory.company_id == user.company_id).all()

    results = []

    for category in shift_categories:
        results.append({'category_id': category.id, 'category_name': category.name})

    session.close()
    return jsonify({'results': results}), 200


@app.route('/api/v1/setting/shiftcategory', methods=['PUT'])
@api_basic_auth.login_required
def add_update_delete():
    schema = {'type': 'object',
              'properties':
                  {'adds': {'type': 'array', 'items': {'type': 'string'}},
                   'updates': {'type': 'array',
                               'items': {'type': 'object',
                                         'properties': {'id': {'type': 'number'}, 'name': {'type': 'string'}},
                                         'required': ['id', 'name']
                                         }
                               },
                   'deletes': {'type': 'array', 'items': {'type': 'number'}}},
              'required': ['adds', 'updates', 'deletes']
              }

    try:
        validate(request.json, schema)
    except ValidationError as e:
        frame = inspect.currentframe()
        abort(400, {'code': frame.f_lineno, 'msg': e.message, 'param': None})

    admin_user = session.query(User).filter(User.code == api_basic_auth.username()).one()

    if admin_user.role.name != 'admin':
        session.close()
        frame = inspect.currentframe()
        abort(403, {'code': frame.f_lineno, 'msg': response_msg_403(), 'param': None})


    for delete_id in request.json['deletes']:
        category = session.query(ShiftCategory).filter(ShiftCategory.id == delete_id).one_or_none()

        if not category:
            session.close()
            frame = inspect.currentframe()
            abort(404, {'code': frame.f_lineno, 'msg': response_msg_404(), 'param': None})

        if admin_user.company_id != category.company_id:
            session.close()
            frame = inspect.currentframe()
            abort(403, {'code': frame.f_lineno, 'msg': response_msg_403(), 'param': None})

        session.delete(category)

    session.commit()

    for new_name in request.json['adds']:
        category = session.query(ShiftCategory).filter(ShiftCategory.name == new_name, ShiftCategory.company_id == admin_user.company_id).one_or_none()

        if category:
            session.close()
            frame = inspect.currentframe()
            abort(409, {'code': frame.f_lineno, 'msg': response_msg_409(), 'param': None})
        else:
            new_category = ShiftCategory(name=new_name, company_id=admin_user.company_id)
            session.add(new_category)


    for update_shift_category in request.json['updates']:
        category = session.query(ShiftCategory).filter(ShiftCategory.id == update_shift_category['id']).one_or_none()

        if not category:
            session.close()
            frame = inspect.currentframe()
            abort(404, {'code': frame.f_lineno, 'msg': response_msg_404(), 'param': None})

        if admin_user.company_id != category.company_id:
            session.close()
            frame = inspect.currentframe()
            abort(403, {'code': frame.f_lineno, 'msg': response_msg_403(), 'param': None})

        category.name = update_shift_category['name']

        session.add(category)

    session.commit()
    session.close()

    return jsonify({'results': response_msg_200()}), 200
