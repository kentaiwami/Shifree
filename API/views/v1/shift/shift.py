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
    current_category = ''
    tmp_shifts = []

    for shift_category in shift_category_list:
        if current_category == shift_category[1].name:
            tmp_shifts.append({
                'id': shift_category[0].id,
                'name': shift_category[0].name,
                'start': shift_category[0].start.strftime("%H:%M") if shift_category[0].start != None else None,
                'end': shift_category[0].end.strftime("%H:%M") if shift_category[0].end != None else None
            })
        else:
            results.append({'category': current_category, 'shifts': tmp_shifts})
            tmp_shifts = []
            tmp_shifts.append({
                'id': shift_category[0].id,
                'name': shift_category[0].name,
                'start': shift_category[0].start.strftime("%H:%M") if shift_category[0].start != None else None,
                'end': shift_category[0].end.strftime("%H:%M") if shift_category[0].end != None else None
            })
            current_category = shift_category[1].name

    # ループを単純にするために、最初に空の情報が入ってしまうので選別
    results = [result for result in results if result['category'] != '']

    session.close()
    return jsonify({'results': results}), 200
