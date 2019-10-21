import inspect
from flask import abort
from model import *
from datetime import datetime as DT
import calendar
from config import demo_company
import random
from utility import get_salary


def create_main():
    table = session.query(ShiftTable).filter(ShiftTable.company_id == demo_company['id']).one_or_none()

    if table is not None:
        session.close()
        frame = inspect.currentframe()
        abort(409, {'code': frame.f_lineno, 'msg': '既に同じシフトを取り込んでいるため、新規取り込みはできません。', 'param': None})

    now = DT.now()
    title = '{}月シフト'.format(now.month)

    _, lastday = calendar.monthrange(now.year, now.month)
    start = DT.strptime('{}-{}-{}'.format(now.year, now.month, 1), '%Y-%m-%d')
    end = DT.strptime('{}-{}-{}'.format(now.year, now.month, lastday), '%Y-%m-%d')


    new_table = ShiftTable(
        title=title,
        origin_path=demo_company['origin_path'],
        thumbnail_path=demo_company['thumbnail_path'],
        company_id=demo_company['id'],
        start=start,
        end=end
    )
    session.add(new_table)
    session.commit()

    shifts = session.query(Shift).\
        join(ShiftCategory, Shift.shift_category_id == ShiftCategory.id).\
        filter(ShiftCategory.company_id == demo_company['id']).all()

    if len(shifts) == 0:
        session.close()
        frame = inspect.currentframe()
        abort(500, {'code': frame.f_lineno, 'msg': 'シフトを登録してから取り込みを開始してください', 'param': None})

    users = session.query(User).filter(User.company_id == demo_company['id']).all()

    new_user_shift_objects = []
    salary_objects = []

    for user in users:
        tmp_salary = 0

        for day in range(1, lastday + 1):
            date = DT.strptime('{}-{}-{}'.format(now.year, now.month, day), '%Y-%m-%d')
            choice_shift = random.choice(shifts)
            new_user_shift = UserShift(date=date, shift_id=choice_shift.id, user_id=user.id, shift_table_id=new_table.id)
            new_user_shift_objects.append(new_user_shift)

            tmp_salary += get_salary(user, choice_shift)

        new_salary = Salary(pay=tmp_salary, user_id=user.id, shifttable_id=new_table.id)
        salary_objects.append(new_salary)


    session.bulk_save_objects(new_user_shift_objects)
    session.bulk_save_objects(salary_objects)
    session.commit()

    return new_table.title, new_table.id
