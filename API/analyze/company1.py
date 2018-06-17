from model import *
import subprocess
import os
from views.v1.response import response_msg_500
import mojimoji
import xml.etree.ElementTree as ET
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

    # yが閾値以下の要素を同じ行としてまとめ、ソート済みの配列と日付がある要素番号を受け取る
    x_sorted_same_line_list, day_line_index = get_same_line_list(x_y_text_list)

    # 日付の境界位置
    day_limit_list = get_day_limit(start, x_sorted_same_line_list, day_line_index)


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

    return x_y_text_list


def get_same_line_list(x_y_text_list):
    """
    x, yの値で並び替えを行い、日付が記述されている箇所の判定を行う
    :param x_y_text_list:   x,y,textの辞書が格納された1次元配列
    :return:                xでソート済みの同じ行ごとにまとめたx_y_text_list, 日付が記述されている配列番号
    """

    x_y_text_list = sorted(x_y_text_list, key=lambda dict: dict['y'], reverse=True)

    threshold_y = 3.0
    current_y = x_y_text_list[0]['y']
    same_line_list = []
    tmp_same_one_line = []

    for x_y_text in x_y_text_list:
        if abs(x_y_text['y'] - current_y) <= threshold_y:
            tmp_same_one_line.append(x_y_text)
        else:
            same_line_list.append(tmp_same_one_line)

            tmp_same_one_line = [x_y_text]
            current_y = x_y_text['y']

    # xで並び替え、日付が記述されている箇所（要素数）の特定
    x_sorted_same_line_list = []
    day_line_index = -1
    for i, same_line in enumerate(same_line_list):
        # まだ数字のみの行を見つけていない時のみ数値判定の検索を実施
        if day_line_index == -1:
            if len(list(filter(lambda x: x['text'].isdigit(), same_line))) == len(same_line):
                day_line_index = i

        x_sorted_same_line_list.append(sorted(same_line, key=lambda dict: dict['x'], reverse=False))

    if day_line_index == -1:
        raise Exception(response_msg_500())

    return x_sorted_same_line_list, day_line_index


def get_day_limit(start, x_sorted_same_line_list, day_line_index):
    """
    日付の境界位置を判定して結果を返す
    :param start:                   postで受け取った開始日付
    :param x_sorted_same_line_list: xでソート済みの同じ行ごとにまとめた配列
    :param day_line_index:          日付が記述されている配列番号
    :return:                        日付と境界値を格納した1次元配列
    """

    start_date = DT.strptime(start, '%Y-%m-%d')
    day_limit_list = []
    current_date = str(start_date.day)
    tmp_current_date = ''
    timedelta = 1
    for date_x_y_text in x_sorted_same_line_list[day_line_index]:
        tmp_current_date += date_x_y_text['text']

        if len(tmp_current_date) >= 3:
            raise Exception(response_msg_500())

        if current_date == tmp_current_date:
            day_limit_list.append({'day': current_date, 'limit': date_x_y_text['x']})

            tmp_current_date = ''
            current_date = str((start_date + datetime.timedelta(days=timedelta)).day)
            timedelta += 1

    return day_limit_list


def update_main(table_id):
    print('update', table_id)

    table = session.query(ShiftTable).filter(ShiftTable.id == table_id).one()

    return {'origin': table.origin_path, 'thumbnail': table.thumbnail_path}
