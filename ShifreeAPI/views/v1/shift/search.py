from flask import Blueprint, request, jsonify
from model import User, ShiftTable, Shift, ShiftCategory, Company, UserShift
from database import session
from basic_auth import api_basic_auth
from itertools import groupby


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


@app.route('/api/v1/usershift/search/shift', methods=['GET'])
@api_basic_auth.login_required
def search():
    access_user = session.query(User).filter(User.code == api_basic_auth.username()).one()

    user_id = request.args.get('user_id', default=-1, type=int)
    category_id = request.args.get('category_id', default=-1, type=int)
    table_id = request.args.get('table_id', default=-1, type=int)
    shift_id = request.args.get('shift_id', default=-1, type=int)

    user_id_statement = True if user_id == -1 else UserShift.user_id == user_id
    table_id_statement = True if table_id == -1 else UserShift.shift_table_id == table_id
    shift_id_statement = True if shift_id == -1 else UserShift.shift_id == shift_id
    category_id_statement = True if category_id == -1 else ShiftCategory.id == category_id

    query_results = session.query(UserShift).join(Shift, ShiftCategory, Company).filter(
        Company.id == access_user.company_id,
        user_id_statement,
        table_id_statement,
        shift_id_statement,
        category_id_statement
    ).all()

    query_results.sort(key=lambda user_shift: user_shift.date)
    results = []
    for date, date_group in groupby(query_results, key=lambda user_shift: user_shift.date):
        results.append({
            'date': str(date),
            'shift': [{'id': user_shift.id, 'user': user_shift.user.name, 'name': user_shift.shift.name} for user_shift in list(date_group)]
        })

    session.close()
    return jsonify({'results': results}), 200
