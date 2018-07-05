from flask import Blueprint, jsonify
from model import User, Shift, ShiftCategory, Company
from database import session
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
