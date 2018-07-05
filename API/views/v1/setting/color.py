import inspect
from flask import Blueprint, request, jsonify, abort
from jsonschema import validate, ValidationError
from model import User, ShiftCategory, ColorScheme
from database import session
from views.v1.response import response_msg_404, response_msg_403, response_msg_200
from basic_auth import api_basic_auth

app = Blueprint('setting_color_bp', __name__)


@app.route('/api/v1/setting/color', methods=['PUT'])
@api_basic_auth.login_required
def create_or_update():
    schema = {'type': 'object',
              'properties':
                  {'schemas': {'type': 'array',
                               'items': {'type': 'object',
                                         'properties': {
                                             'category_id': {'type': 'integer', 'minimum': 0},
                                             'hex': {'type': 'string', 'pattern': '^#([0-9]|[A-F]){6}$'}
                                         },
                                         'required': ['category_id', 'hex']
                                         }
                               },
                   },
              'required': ['schemas']
              }

    try:
        validate(request.json, schema)
    except ValidationError as e:
        frame = inspect.currentframe()
        abort(400, {'code': frame.f_lineno, 'msg': e.message, 'param': None})


    user = session.query(User).filter(User.code == api_basic_auth.username()).one()

    for schema in request.json['schemas']:
        category = session.query(ShiftCategory).filter(ShiftCategory.id == schema['category_id']).one_or_none()

        if not category:
            session.close()
            frame = inspect.currentframe()
            abort(404, {'code': frame.f_lineno, 'msg': response_msg_404(), 'param': None})

        if category.company_id != user.company_id:
            session.close()
            frame = inspect.currentframe()
            abort(403, {'code': frame.f_lineno, 'msg': response_msg_403(), 'param': None})

        color = session.query(ColorScheme).filter(ColorScheme.user_id == user.id, ColorScheme.shift_category_id == category.id).one_or_none()

        if color is None:
            new_color = ColorScheme(hex=schema['hex'], user_id=user.id, shift_category_id=category.id)
            session.add(new_color)
        else:
            color.hex = schema['hex']

        session.commit()

    session.close()
    return jsonify({'results': response_msg_200()}), 200


@app.route('/api/v1/setting/color', methods=['GET'])
@api_basic_auth.login_required
def get():
    user = session.query(User).filter(User.code == api_basic_auth.username()).one()
    category_colorschemes = session.query(ShiftCategory, ColorScheme).outerjoin(ColorScheme).filter(ShiftCategory.company_id == user.company_id, ColorScheme.user_id == user.id).order_by('id').all()
    session.close()

    results = []

    for category_colorscheme in category_colorschemes:
        hex = None
        color_scheme_id = None

        if category_colorscheme[1] is not None:
            hex = category_colorscheme[1].hex
            color_scheme_id = category_colorscheme[1].id

        results.append({
            'category_id': category_colorscheme[0].id,
            'category_name': category_colorscheme[0].name,
            'hex': hex,
            'color_scheme_id': color_scheme_id
        })

    return jsonify({'results': results}), 200
