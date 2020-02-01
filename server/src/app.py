from database import init_db, session
from flask import Flask, jsonify
from flask_basicauth import BasicAuth
from flask_migrate import Migrate
from model import db
from config import secret_key
from views.v1 import auth, login, salary, comment, table, company, token, health_check
from views.v1.shift import usershift, memo, shift, search, analytics
from views.v1.setting import wage, username, password, user, shiftcategory, color, notification, follow, export
from admin import AuthException, init_admin
from flask_pushjack import FlaskAPNS


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
        auth.app, login.app, wage.app, username.app, password.app, user.app, shiftcategory.app, notification.app,
        color.app, salary.app, usershift.app, table.app, comment.app, memo.app, company.app, shift.app, token.app,
        follow.app, export.app, search.app, analytics.app, health_check.app
    ]

    for bp_app in modules_define:
        app_obj.register_blueprint(bp_app)


app = init_app()
client = FlaskAPNS()
client.init_app(app)
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
    code = None
    msg = None
    param = None

    if type(error.description) is dict:
        code = error.description['code']
        msg = error.description['msg']
        param = error.description['param']

    response = jsonify({
        'code':  code,
        'msg': msg,
        'param': param,
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
