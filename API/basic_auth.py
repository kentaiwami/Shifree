from flask_httpauth import HTTPBasicAuth
from werkzeug.security import check_password_hash
from database import session
from model import User
from config import demo_admin_user, demo_general_user

api_basic_auth = HTTPBasicAuth()


@api_basic_auth.verify_password
def verify_pw(user_code, password):
    user = session.query(User).filter(User.code == user_code).one_or_none()
    session.close()

    if user is None:
        return False
    else:
        if user.code == demo_general_user['code'] or user.code == demo_admin_user['code']:
            return True

        return check_password_hash(user.password, password)
