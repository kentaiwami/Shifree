from model import *
import subprocess
import os
from views.v1.response import response_msg_500
import mojimoji
import xml.etree.ElementTree as ET
import re
from datetime import datetime as DT
import datetime


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

    # xmlからx,y,textを抽出してリストへ格納
    x_y_text_list = get_x_y_text_from_xml(page)

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

    all_same_line_list = []
    day_line_index = -1
    for i, same_line in enumerate(same_line_list):
        # まだ数字のみの行を見つけていない時のみ数値判定の検索を実施
        if day_line_index == -1:
            if len(list(filter(lambda x:x['text'].isdigit(),same_line))) == len(same_line):
                day_line_index = i

        all_same_line_list.append(sorted(same_line, key=lambda dict: dict['x'], reverse=False))


    if day_line_index == -1:
        raise Exception(response_msg_500())

    start_date = DT.strptime(start, '%Y-%m-%d')

    # 日付の境界位置を格納
    day_limit_list = []
    current_date = str(start_date.day)
    tmp_current_date = ''
    timedelta = 1
    for date_x_y_text in all_same_line_list[day_line_index]:
        tmp_current_date += date_x_y_text['text']

        if len(tmp_current_date) >= 3:
            raise Exception(response_msg_500())

        if current_date == tmp_current_date:
            day_limit_list.append({'day': current_date, 'limit': date_x_y_text['x']})

            tmp_current_date = ''
            current_date = str((start_date + datetime.timedelta(days=timedelta)).day)
            timedelta += 1

    # hoge = open('sample/test.txt', 'w')
    # for hhh in all_same_line_list:
    #     for abc in hhh:
    #         hoge.write('{}({}) '.format(abc['text'], abc['x']))
    #     hoge.write('\n')


    # table = ShiftTable(title=title, company_id=company_id)
    # session.add(table)
    # session.commit()
    #
    # return table
    # raise ValueError
    os.remove(file_path)


def get_x_y_text_from_xml(page):
    """
    xmlからx,y,textを抽出した結果をリストとして返す
    :param page:    ElementTreeで抽出したxml
    :return:        x,y,textの辞書が格納された1次元配列
    """
    x_y_text_list = []
    for textbox in page:
        for textline in textbox:
            for text in textline:
                if text.text != '\n' and 'bbox' in text.attrib:
                    bbox = text.attrib['bbox'].split(',')
                    x_y_text_list.append({
                        'x': float(bbox[0]),
                        'y': float(bbox[1]),
                        'text': mojimoji.zen_to_han(text.text, kana=False)
                    })

    if len(x_y_text_list) == 0:
        raise Exception(response_msg_500())

    x_y_text_list = sorted(x_y_text_list, key=lambda dict: dict['y'], reverse=True)

    return x_y_text_list


def update_main(table_id):
    print('update', table_id)

    table = session.query(ShiftTable).filter(ShiftTable.id == table_id).one()

    return {'origin': table.origin_path, 'thumbnail': table.thumbnail_path}
