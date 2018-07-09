from database import init_db, session
from flask import Flask, jsonify
from flask_basicauth import BasicAuth
from flask_migrate import Migrate
from model import db
from config import secret_key
from views.v1 import auth, login, salary, comment, table, company
from views.v1.shift import usershift, memo, shift
from views.v1.setting import wage, username, password, user, shiftcategory, color
from admin import AuthException, init_admin


def init_app():
    app_obj = Flask(__name__, static_folder='uploads')
    app_obj.config.from_object('config.BaseConfig')
    app_obj.secret_key = secret_key

    init_db(app_obj)
    init_admin(app_obj)
    add_bp(app_obj)

    return app_obj


def add_bp(app_obj):
    modules_define = [
        auth.app, login.app, wage.app, username.app, password.app, user.app, shiftcategory.app,
        color.app, salary.app, usershift.app, table.app, comment.app, memo.app, company.app, shift.app
    ]

    for bp_app in modules_define:
        app_obj.register_blueprint(bp_app)


app = init_app()
admin_basic_auth = BasicAuth(app)
migrate = Migrate(app, db)


@app.route('/logout')
def Logout():
    raise AuthException('Successfully logged out.')


@app.route('/')
@app.route('/index')
def index():
    return 'This is index page'


@app.errorhandler(400)
@app.errorhandler(403)
@app.errorhandler(404)
@app.errorhandler(409)
@app.errorhandler(500)
def error_handler(error):
    response = jsonify({
        'code': error.description['code'],
        'msg': error.description['msg'],
        'param': error.description['param'],
        'status': error.code
    })
    return response, error.code


@app.teardown_appcontext
def session_clear(exception):
    if exception and session.is_active:
        session.rollback()
    else:
        session.commit()

    session.close()
