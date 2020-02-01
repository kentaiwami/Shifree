from flask import Blueprint, jsonify, abort, Response
from database import session
from sqlalchemy import exc

app = Blueprint('health_check_bp', __name__)


@app.route('/api/v1/health_check', methods=['GET'])
def get():

    try:
        session.connection()
    except exc.SQLAlchemyError:
        abort(500)
        session.close()

    session.close()

    return Response(status=200)
