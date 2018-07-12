import inspect
from flask import Blueprint, jsonify, abort
from model import User, Salary, ShiftTable, Shift, UserShift
from database import session
from views.v1.response import response_msg_404
from basic_auth import api_basic_auth
from .table import get_salary

app = Blueprint('test_bp', __name__)

@app.route('/api/v1/test', methods=['GET'])
@api_basic_auth.login_required
def get():
    results = []

    return jsonify({'results': results}), 200