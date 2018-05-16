from model import *

def create_main(title, company_id):
    print('main')

    table = ShiftTable(title=title, company_id=company_id)
    session.add(table)
    session.commit()

    return table
    # raise ValueError


def update_main(table_id):
    print('update', table_id)

    table = session.query(ShiftTable).filter(ShiftTable.id == table_id).one()

    return {'origin': table.origin_path, 'thumbnail': table.thumbnail_path}
