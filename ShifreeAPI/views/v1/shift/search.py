import inspect
from flask import Blueprint, request, jsonify, abort
from model import User, ShiftTable, Shift, ShiftCategory, Company
from database import session
from basic_auth import api_basic_auth


app = Blueprint('shift_search_bp', __name__)


@app.route('/api/v1/usershift/search/init', methods=['GET'])
@api_basic_auth.login_required
def get_search_init():
    access_user = session.query(User).filter(User.code == api_basic_auth.username()).one()
    shift_categories = session.query(ShiftCategory).filter(ShiftCategory.company_id == access_user.company_id).all()
    shifts = session.query(Shift).join(ShiftCategory).filter(ShiftCategory.company_id == access_user.company_id).all()
    users = session.query(User).filter(User.company_id == access_user.company_id).all()
    tables = session.query(ShiftTable).filter(ShiftTable.company_id == access_user.company_id).all()

    session.close()
    return jsonify({'results': {
        'category': [{'id': category.id, 'name': category.name} for category in shift_categories],
        'shift': [{'id': shift.id, 'name': shift.name} for shift in shifts],
        'user': [{'id': user.id, 'name': user.name} for user in users],
        'table': [{'id': table.id, 'title': table.title} for table in tables]
    }}), 200
