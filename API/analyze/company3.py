from model import *
import subprocess
import os
from views.v1.response import response_msg_500
from flask import jsonify
import xml.etree.ElementTree as ET


def create_main(company_id, title, number, start, end, file):
    _, file_ext = os.path.splitext(file.filename)
    file_path = 'uploads/tmp/company_{}{}'.format(company_id, file_ext)
    file.save(file_path)

    try:
        results = subprocess.check_output(['pdf2txt.py', file_path, '-t', 'xml'])
    except ValueError:
        os.remove(file_path)
        raise Exception(response_msg_500())

    page = ET.fromstring(results)[0]

    x_y_text_list = []
    # xmlからx,y,textを抽出してリストへ格納
    for textbox in page:
        for textline in textbox:
            for text in textline:
                if text.text != '\n' and 'bbox' in text.attrib:
                    bbox = text.attrib['bbox'].split(',')
                    x_y_text_list.append({
                        'x': float(bbox[0]),
                        'y': float(bbox[1]),
                        'text': text.text
                    })

    x_y_text_list = sorted(x_y_text_list, key=lambda dict: dict['y'], reverse=True)

    if len(x_y_text_list) == 0:
        raise Exception(response_msg_500())

    # yが閾値以下の要素を同じ行としてまとめる
    threshold_y = 3.0
    current_y = x_y_text_list[0]['y']
    same_line_list = []
    same_one_line = []
    for x_y_text in x_y_text_list:
        if abs(x_y_text['y'] - current_y) <= threshold_y:
            same_one_line.append(x_y_text)
        else:
            same_line_list.append(same_one_line)
            same_one_line = []
            same_one_line.append(x_y_text)
            current_y = x_y_text['y']

    new_same_line_list = []
    for same_line in same_line_list:
        new_same_line_list.append(sorted(same_line, key=lambda dict: dict['x'], reverse=False))

    # table = ShiftTable(title=title, company_id=company_id)
    # session.add(table)
    # session.commit()
    #
    # return table
    # raise ValueError
    os.remove(file_path)


def update_main(table_id):
    print('update', table_id)

    table = session.query(ShiftTable).filter(ShiftTable.id == table_id).one()

    return {'origin': table.origin_path, 'thumbnail': table.thumbnail_path}
