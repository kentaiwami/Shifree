import sys
import os
path = os.path.join(os.path.dirname(__file__), '../')
sys.path.append(path)
from flask_script import Manager
from sqlalchemy_seed import load_fixtures, load_fixture_files
from app import init_app
from database import session

app = init_app()
manager = Manager(app)


@manager.command
def loaddata(filename=''):
    """Load seed data."""
    if filename == '':
        return
    path = os.path.join(app.root_path, 'fixtures')

    fixtures = load_fixture_files(path, [filename])
    load_fixtures(session, fixtures)

if __name__ == "__main__":

    manager.run()
