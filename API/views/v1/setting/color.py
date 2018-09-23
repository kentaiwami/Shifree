import inspect
from flask import Blueprint, request, jsonify, abort
from jsonschema import validate, ValidationError
from model import User, ShiftCategory, ColorScheme
from database import session
from basic_auth import api_basic_auth


app = Blueprint('setting_color_bp', __name__)


@app.route('/api/v1/setting/color', methods=['PUT'])
@api_basic_auth.login_required
def create_or_update_or_delete():
    schema = {'type': 'object',
              'properties':
                  {'schemes': {'type': 'array',
                               'items': {'type': 'object',
                                         'properties': {
                                             'category_id': {'type': 'integer', 'minimum': 0},
                                             'hex': {'type': 'string', 'pattern': '^#([0-9]|[A-F]){6}$'}
                                         },
                                         'required': ['category_id', 'hex']
                                         }
                               },
                   },
              'required': ['schemes']
              }

    try:
        validate(request.json, schema)
    except ValidationError as e:
        session.close()
        frame = inspect.currentframe()
        abort(400, {'code': frame.f_lineno, 'msg': e.message, 'param': None})


    user = session.query(User).filter(User.code == api_basic_auth.username()).one()

    for schema in request.json['schemes']:
        category = session.query(ShiftCategory).filter(ShiftCategory.id == schema['category_id']).one_or_none()

        if not category:
            session.close()
            frame = inspect.currentframe()
            abort(404, {'code': frame.f_lineno, 'msg': '対応するシフトカテゴリがありません', 'param': None})

        if category.company_id != user.company_id:
            session.close()
            frame = inspect.currentframe()
            abort(403, {'code': frame.f_lineno, 'msg': '権限がありません', 'param': None})

        color = session.query(ColorScheme).filter(ColorScheme.user_id == user.id, ColorScheme.shift_category_id == category.id).one_or_none()

        if color is None:
            if schema['hex'] != '#FFFFFF':
                new_color = ColorScheme(hex=schema['hex'], user_id=user.id, shift_category_id=category.id)
                session.add(new_color)
        else:
            if schema['hex'] == '#FFFFFF':
                session.delete(color)
            else:
                color.hex = schema['hex']

        session.commit()

    session.close()
    return jsonify({'results': 'OK'}), 200


@app.route('/api/v1/setting/color', methods=['GET'])
@api_basic_auth.login_required
def get():
    user = session.query(User).filter(User.code == api_basic_auth.username()).one()
    category_results = session.query(ShiftCategory).filter(ShiftCategory.company_id == user.company_id).all()
    scheme_results = session.query(ColorScheme).filter(ColorScheme.user_id == user.id).all()

    results = []

    for category in category_results:
        scheme_category_match_result = [x for x in scheme_results if x.shift_category_id == category.id]
        tmp = {'category_id': category.id, 'category_name': category.name}

        if len(scheme_category_match_result) == 0:
            tmp['hex'] = None
            tmp['color_scheme_id'] = None
        else:
            tmp['hex'] = scheme_category_match_result[0].hex
            tmp['color_scheme_id'] = scheme_category_match_result[0].id

        results.append(tmp)

    session.close()
    return jsonify({'results': results}), 200
