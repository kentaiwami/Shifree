from flask import Blueprint, request, jsonify
from jsonschema import validate, ValidationError
from model import User
from database import session
from basic_auth import api_basic_auth

app = Blueprint('setting_wage_bp', __name__)


@app.route('/api/v1/setting/wage', methods=['PUT'])
@api_basic_auth.login_required
def update():
    schema = {'type': 'object',
              'properties':
                  {'daytime_start': {'type': 'string', 'pattern': '^[0-9]{2}:[0-9]{2}$'},
                   'daytime_end': {'type': 'string', 'pattern': '^[0-9]{2}:[0-9]{2}$'},
                   'night_start': {'type': 'string', 'pattern': '^[0-9]{2}:[0-9]{2}$'},
                   'night_end': {'type': 'string', 'pattern': '^[0-9]{2}:[0-9]{2}$'},
                   'daytime_wage': {'type': 'number', 'minimum': 1},
                   'night_wage': {'type': 'number', 'minimum': 1}
                   },
              'required': ['daytime_start', 'daytime_end', 'night_start', 'night_end', 'daytime_wage', 'night_wage']
              }

    try:
        validate(request.json, schema)
    except ValidationError as e:
        return jsonify({'msg': e.message}), 400

    user = session.query(User).filter(User.code == api_basic_auth.username()).one()

    user.daytime_start = request.json['daytime_start']
    user.daytime_end = request.json['daytime_end']
    user.daytime_wage = request.json['daytime_wage']
    user.night_start = request.json['night_start']
    user.night_end = request.json['night_end']
    user.night_wage = request.json['night_wage']

    session.commit()
    session.close()
    return jsonify({'results':{
        'daytime_start': str(user.daytime_start),
        'daytime_end': str(user.daytime_end),
        'daytime_wage': user.daytime_wage,
        'night_start': str(user.night_start),
        'night_end': str(user.night_end),
        'night_wage': user.night_wage
    }}), 200


@app.route('/api/v1/setting/wage', methods=['GET'])
@api_basic_auth.login_required
def get():
    user = session.query(User).filter(User.code == api_basic_auth.username()).one_or_none()
    session.close()

    return jsonify({'results': {
        'daytime_start': str(user.daytime_start),
        'daytime_end': str(user.daytime_end),
        'daytime_wage': user.daytime_wage,
        'night_start': str(user.night_start),
        'night_end': str(user.night_end),
        'night_wage': user.night_wage
    }}), 200
