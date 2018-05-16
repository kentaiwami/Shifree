from flask_httpauth import HTTPBasicAuth
from werkzeug.security import check_password_hash
from database import session
from model import User

api_basic_auth = HTTPBasicAuth()


@api_basic_auth.verify_password
def verify_pw(user_code, password):
    user = session.query(User).filter(User.code == user_code).one_or_none()

    if user is None:
        return False
    else:
        return check_password_hash(user.password, password)
