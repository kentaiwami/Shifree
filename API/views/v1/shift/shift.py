from flask import Blueprint, jsonify
from model import User, Shift, ShiftCategory, Company
from database import session
from basic_auth import api_basic_auth


app = Blueprint('shift_bp', __name__)


@app.route('/api/v1/shift', methods=['GET'])
@api_basic_auth.login_required
def get():
    user = session.query(User).filter(User.code == api_basic_auth.username()).one()

    shifts = session.query(Shift).join(ShiftCategory, Company).filter(ShiftCategory.company_id == user.company_id).all()
    results = []

    for shift in shifts:
        results.append({
            'id': shift.id,
            'name': shift.name
        })

    session.close()
    return jsonify({'results': results}), 200
