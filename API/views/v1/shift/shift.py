import inspect
from flask import Blueprint, request, jsonify, abort
from jsonschema import validate, ValidationError
from model import User, Role, Company, Shift, ShiftCategory
from database import session
from views.v1.response import response_msg_404, response_msg_403, response_msg_200
from basic_auth import api_basic_auth


app = Blueprint('shift_bp', __name__)


@app.route('/api/v1/shift', methods=['GET'])
@api_basic_auth.login_required
def get():
    user = session.query(User).filter(User.code == api_basic_auth.username()).one()
    shift_category_list = session.query(Shift, ShiftCategory).join(ShiftCategory, Company).filter(ShiftCategory.company_id == user.company_id).order_by(ShiftCategory.id.asc()).all()

    results = []
    current_category = shift_category_list[0][1]
    tmp_shifts = []

    for shift_category in shift_category_list:
        if current_category == shift_category[1]:
            tmp_shifts.append({
                'id': shift_category[0].id,
                'name': shift_category[0].name,
                'start': None if shift_category[0].start is None else shift_category[0].start.strftime("%H:%M"),
                'end': None if shift_category[0].end is None else shift_category[0].end.strftime("%H:%M")
            })
        else:
            results.append({'category_name': current_category.name, 'category_id': current_category.id, 'shifts': tmp_shifts})
            tmp_shifts = [{
                'id': shift_category[0].id,
                'name': shift_category[0].name,
                'start': None if shift_category[0].start is None else shift_category[0].start.strftime("%H:%M"),
                'end': None if shift_category[0].end is None else shift_category[0].end.strftime("%H:%M")
            }]
            current_category = shift_category[1]

    session.close()
    return jsonify({'results': results}), 200


@app.route('/api/v1/shift', methods=['PUT'])
@api_basic_auth.login_required
def add_update_delete():
    schema = {'type': 'object',
              'properties':
                  {'adds': {'type': 'array',
                            'items': {'type': 'object',
                                      'properties': {'category_id': {'type': 'integer', 'minimum': 0},
                                                     'start': {'type': 'string', 'pattern': '^[0-9]{2}:[0-9]{2}$'},
                                                     'end': {'type': 'string', 'pattern': '^[0-9]{2}:[0-9]{2}$'},
                                                     'name': {'type': 'string', 'minLength': 1}
                                                     },
                                      'required': ['category_id', 'start', 'end', 'name']
                                      }
                            },
                   'updates': {'type': 'array',
                               'items': {'type': 'object',
                                         'properties': {'id': {'type': 'integer', 'minimum': 0},
                                                        'category_id': {'type': 'integer', 'minimum': 0},
                                                        'start': {'type': 'string', 'pattern': '^[0-9]{2}:[0-9]{2}$'},
                                                        'end': {'type': 'string', 'pattern': '^[0-9]{2}:[0-9]{2}$'},
                                                        'name': {'type': 'string', 'minLength': 1}
                                                        },
                                         'required': ['id', 'category_id', 'start', 'end', 'name']
                                         }
                               },
                   'deletes': {'type': 'array', 'items': {'type': 'integer'}}},
              'required': ['adds', 'updates', 'deletes']
              }

    try:
        validate(request.json, schema)
    except ValidationError as e:
        frame = inspect.currentframe()
        abort(400, {'code': frame.f_lineno, 'msg': e.message, 'param': None})

    admin_user = session.query(User).filter(User.code == api_basic_auth.username()).one_or_none()

    if admin_user.role.name != 'admin':
        session.close()
        frame = inspect.currentframe()
        abort(403, {'code': frame.f_lineno, 'msg': response_msg_403(), 'param': None})

    for shift_id in request.json['deletes']:
        shift_company = session.query(Shift, Company).join(ShiftCategory, Company).filter(Shift.id == shift_id).one_or_none()

        if shift_company is None:
            session.close()
            frame = inspect.currentframe()
            abort(404, {'code': frame.f_lineno, 'msg': response_msg_404(), 'param': None})

        if admin_user.company_id != shift_company[1].id:
            frame = inspect.currentframe()
            abort(403, {'code': frame.f_lineno, 'msg': response_msg_403(), 'param': None})

        session.delete(shift_company[0])


    for shift_obj in request.json['updates']:
        shift_company = session.query(Shift, Company).join(ShiftCategory, Company).filter(Shift.id == shift_obj['id']).one_or_none()

        if shift_company is None:
            session.close()
            frame = inspect.currentframe()
            abort(404, {'code': frame.f_lineno, 'msg': response_msg_404(), 'param': None})

        if admin_user.company_id != shift_company[1].id:
            frame = inspect.currentframe()
            abort(403, {'code': frame.f_lineno, 'msg': response_msg_403(), 'param': None})

        shift_category = session.query(ShiftCategory).filter(ShiftCategory.id == shift_obj['category_id']).one_or_none()

        if shift_category is None:
            session.close()
            frame = inspect.currentframe()
            abort(404, {'code': frame.f_lineno, 'msg': response_msg_404(), 'param': None})

        shift_company[0].name = shift_obj['name']
        shift_company[0].shift_category_id = shift_category.id
        shift_company[0].start = shift_obj['start']
        shift_company[0].end = shift_obj['end']

        session.commit()


    # session.commit()
    session.close()
    return jsonify({'a': 10}), 200