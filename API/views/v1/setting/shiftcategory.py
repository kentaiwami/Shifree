from flask import Blueprint, request, jsonify
from jsonschema import validate, ValidationError
from model import User, ShiftCategory, Company
from database import session
from views.v1.response import response_msg_404, response_msg_403, response_msg_200
from basic_auth import api_basic_auth

app = Blueprint('setting_shitcategory_bp', __name__)


@app.route('/api/v1/setting/shiftcategory', methods=['POST'])
@api_basic_auth.login_required
def add():
    schema = {'type': 'object',
              'properties':
                  {'name': {'type': 'string', 'minLength': 1}},
              'required': ['name']
              }

    try:
        validate(request.json, schema)
    except ValidationError as e:
        return jsonify({'msg': e.message}), 400

    admin_user = session.query(User).filter(User.code == api_basic_auth.username()).one()

    if admin_user.role.name != 'admin':
        session.close()
        return jsonify({'msg': response_msg_403()}), 403

    new_category = ShiftCategory(name=request.json['name'], company_id=admin_user.company_id)

    session.add(new_category)
    session.commit()
    session.close()

    return jsonify({'results': {'category_id': new_category.id, 'category_name': new_category.name}}), 200


@app.route('/api/v1/setting/shiftcategory', methods=['GET'])
@api_basic_auth.login_required
def get():
    user = session.query(User).filter(User.code == api_basic_auth.username()).one()
    company = session.query(Company).filter(Company.id == user.company_id).one()
    shift_categories = session.query(ShiftCategory).join(Company).filter(ShiftCategory.company_id == company.id).all()

    results = []

    for category in shift_categories:
        results.append({'category_id': category.id, 'category_name': category.name})

    session.close()
    return jsonify({'results': results}), 200


@app.route('/api/v1/setting/shiftcategory/<category_id>', methods=['PUT'])
@api_basic_auth.login_required
def update(category_id):
    schema = {'type': 'object',
              'properties':
                  {'category_name': {'type': 'string', 'minLength': 1}},
              'required': ['category_name']
              }

    try:
        validate(request.json, schema)
    except ValidationError as e:
        return jsonify({'msg': e.message}), 400

    admin_user = session.query(User).filter(User.code == api_basic_auth.username()).one()

    if admin_user.role.name != 'admin':
        session.close()
        return jsonify({'msg': '権限がありません'}), 403

    category = session.query(ShiftCategory).filter(ShiftCategory.id == category_id).one_or_none()

    if not category:
        session.close()
        return jsonify({'msg': response_msg_404()}), 404

    if admin_user.company_id != category.company_id:
        session.close()
        return jsonify({'msg': response_msg_403()}), 403

    category.name = request.json['category_name']

    session.add(category)
    session.commit()

    session.close()
    return jsonify({'results': {'category_id': category_id, 'category_name': request.json['category_name']}}), 200


@app.route('/api/v1/setting/shiftcategory/<category_id>', methods=['DELETE'])
@api_basic_auth.login_required
def delete(category_id):
    admin_user = session.query(User).filter(User.code == api_basic_auth.username()).one()

    if admin_user.role.name != 'admin':
        session.close()
        return jsonify({'msg': '権限がありません'}), 403

    category = session.query(ShiftCategory).filter(ShiftCategory.id == category_id).one_or_none()

    if not category:
        session.close()
        return jsonify({'msg': response_msg_404()}), 404

    if admin_user.company_id != category.company_id:
        session.close()
        return jsonify({'msg': response_msg_403()}), 403

    session.delete(category)
    session.commit()
    session.close()

    return jsonify({'msg': response_msg_200()}), 200
