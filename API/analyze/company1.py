from model import *
import subprocess
import os
from views.v1.response import response_msg_500
import mojimoji
import xml.etree.ElementTree as ET
import re


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
    day_line_index = -1
    for i, same_line in enumerate(same_line_list):
        # まだ数字のみの行を見つけていない時のみ数値判定の検索を実施
        if day_line_index == -1:
            if len(list(filter(lambda x:x['text'].isdigit(),same_line))) == len(same_line):
                day_line_index = i
                break

        new_same_line_list.append(sorted(same_line, key=lambda dict: dict['x'], reverse=False))


    if day_line_index == -1:
        raise Exception(response_msg_500())

    # 開始・終了日の日付文字列を抽出
    start_date = {}
    end_date = {}
    pattern = re.compile('([0-9]{4})-([0-9]{2})-([0-9]{2})')
    m = pattern.search(start)

    if not m:
        raise Exception(response_msg_500())

    start_date['year'] = m.group(1)
    start_date['month'] = m.group(2)
    start_date['day'] = m.group(3)

    m = pattern.search(end)

    if not m:
        raise Exception(response_msg_500())

    end_date['year'] = m.group(1)
    end_date['month'] = m.group(2)
    end_date['day'] = m.group(3)

    # hoge = open('sample/test.txt', 'w')
    # for hhh in new_same_line_list:
    #     for abc in hhh:
    #         hoge.write(abc['text'] + ' ')
    #     hoge.write('\n')


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
