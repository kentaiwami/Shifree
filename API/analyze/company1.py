from model import *
import subprocess
import os
import mojimoji
import xml.etree.ElementTree as ET
from datetime import datetime as DT
import datetime
import inspect


tmp_file_path = ''


def create_main(company_id, title, number, start, end, file):
    global tmp_file_path

    _, file_ext = os.path.splitext(file.filename)
    tmp_file_path = 'uploads/tmp/company_{}{}'.format(company_id, file_ext)
    file.save(tmp_file_path)

    try:
        results = subprocess.check_output(['pdf2txt.py', tmp_file_path, '-t', 'xml'])
    except ValueError:
        os.remove(tmp_file_path)
        frame = inspect.currentframe()
        raise Exception('解析コマンドの実行中にエラーが発生しました[{}]'.format(frame.f_lineno))

    page = ET.fromstring(results)[0]

    x_y_text_list = get_x_y_text_from_xml(page)
    same_line_list, day_line_index = get_same_line_list(x_y_text_list)
    day_x_list = get_day_x(start, same_line_list, day_line_index)
    users_line = get_user_line(company_id, same_line_list, day_x_list[0]['x'], number)
    should_join_shift = get_should_join_shift(users_line)
    users_shift_list = get_user_shift(users_line, day_x_list)
    joined_users_shift = get_joined_users_shift(users_shift_list, should_join_shift)

    # for hoge in joined_users_shift:
    #     for us in hoge:
    #         print(us)




    # hoge = open('sample/test.txt', 'w')
    # for hhh in x_sorted_same_line_list:
    #     for abc in hhh:
    #         hoge.write('{}({}) '.format(abc['text'], abc['x']))
    #     hoge.write('\n')

    # table = ShiftTable(title=title, company_id=company_id)
    # session.add(table)
    # session.commit()
    #
    # return table
    # raise ValueError
    os.remove(tmp_file_path)


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
        os.remove(tmp_file_path)
        frame = inspect.currentframe()
        raise Exception('情報抽出中にエラーが発生しました[{}]'.format(frame.f_lineno))

    return x_y_text_list


def get_same_line_list(x_y_text_list):
    """
    x, yの値で並び替えを行い、日付が記述されている箇所の判定を行う
    :param x_y_text_list:   x,y,textの辞書が格納された1次元配列
    :return:                xでソート済みの同じ行ごとにまとめたx_y_text_list, 日付が記述されている配列番号
    """

    threshold_y = 3.0

    x_y_text_list = sorted(x_y_text_list, key=lambda dict: dict['y'], reverse=True)

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
        os.remove(tmp_file_path)
        frame = inspect.currentframe()
        raise Exception('日付の判定中にエラーが発生しました[{}]'.format(frame.f_lineno))

    return x_sorted_same_line_list, day_line_index


def get_day_x(start, same_line_list, day_line_index):
    """
    日付の記載場所を判定して結果を返す
    :param start:                   postで受け取った開始日付
    :param same_line_list: xでソート済みの同じ行ごとにまとめた配列
    :param day_line_index:          日付が記述されている配列番号
    :return:                        日付と記載場所(x)を格納した1次元配列
    """

    start_date = DT.strptime(start, '%Y-%m-%d')
    day_x_list = []
    current_date = str(start_date.day)
    tmp_current_date = ''
    timedelta = 1
    for date_x_y_text in same_line_list[day_line_index]:
        tmp_current_date += date_x_y_text['text']

        if len(tmp_current_date) >= 3:
            os.remove(tmp_file_path)
            frame = inspect.currentframe()
            raise Exception('日付の解析中にエラーが発生しました[{}]'.format(frame.f_lineno))

        if current_date == tmp_current_date:
            day_x_list.append({'day': current_date, 'x': date_x_y_text['x']})

            tmp_current_date = ''
            current_date = str((start_date + datetime.timedelta(days=timedelta)).day)
            timedelta += 1

    return day_x_list


def get_user_line(company_id, same_line_list, first_day_limit, number):
    """
    ユーザ名が含まれている行のみを抽出し、ユーザ名の一致と各ユーザのシフトの開始位置を格納した2次元配列を返す
    :param company_id:          ユーザが属する企業のID
    :param same_line_list:      xでソート済みの同じ行ごとにまとめた配列
    :param first_day_limit:     シフトの最初の日付が記述されているxの値
    :param number:              取り込もうとしているシフト表に記載されているユーザの人数（POSTで受付）
    :return:
    """

    threshold_x = 10.0

    users = session.query(User).filter(User.company_id == company_id).order_by('order').all()
    users_line = []

    for user in users:
        for line in same_line_list[:]:
            # ユーザ名が含まれている文字列（日付より前）を抽出
            candidate_username = list(filter(lambda h: h['x'] < first_day_limit - threshold_x, line))
            candidate_username = [x['text'] for x in candidate_username]
            candidate_username = ''.join(candidate_username)

            if candidate_username.find(user.name) != -1:
                last_char_username = user.name[-1:]
                last_username_obj = next((item for item in line if item["text"] == last_char_username))
                shift_start_index = line.index(last_username_obj) + 1
                users_line.append({
                    'line': line,
                    'shift_start': shift_start_index,
                    'name': user.name
                })
                same_line_list.remove(line)
                break

    if number != len(users_line):
        os.remove(tmp_file_path)
        frame = inspect.currentframe()
        raise Exception('シフト表に記載されているユーザの人数が一致しません[{}]'.format(frame.f_lineno))

    return users_line


def get_should_join_shift(users_line):
    """
    全ユーザのシフト文字列から、連結した文字列（1つのシフト）とするべきものを判別して返す
    :param users_line:  全ユーザのシフトが記述された2次元配列
    :return:            全ユーザのシフトの連結開始・終了位置を辞書ごと格納した2次元配列
    """

    results = []
    threshold_x = 8.0

    for user in users_line:
        tmp_user_line = []
        shift_list = user['line'][user['shift_start']:]

        # 閾値より近いシフトを後で開始終了位置を判別するために（長い文字列への対応）、1次元配列へ格納していく
        candidate_join_shift = []
        for shift1, shift2 in zip(shift_list, shift_list[1:]):
            if abs(shift1['x'] - shift2['x']) <= threshold_x:
                candidate_join_shift.append(shift1)
                candidate_join_shift.append(shift2)
            else:
                tmp_user_line.append(shift1)

        # 連結すべき文字列の範囲を検出
        # ex.) 導, 入, 入, 研, 研, 修を「開始：導, 終了：修」として記録する
        search_index = 1
        join_start_end = []
        start = 0

        while search_index < len(candidate_join_shift) - 1:
            if candidate_join_shift[search_index] != candidate_join_shift[search_index+1]:
                join_start_end.append({'start': candidate_join_shift[start], 'end': candidate_join_shift[search_index]})
                start = search_index + 1

            search_index += 2

        join_start_end.append({'start': candidate_join_shift[start], 'end': candidate_join_shift[search_index]})
        results.append(join_start_end)

    return results


def get_user_shift(users_line, day_x_list):
    """
    全ユーザのシフトを日付ごとにまとめる。結合セルがあった場合は空文字として登録する。
    :param users_line:          全ユーザのシフト情報が格納された2次元配列
    :param day_x_list:          日付の場所が格納された1次元配列
    :return:                    全ユーザ×全日付の2次元配列
    """

    threshold_x = 9.0
    results = []

    for user in users_line:
        shift_list = user['line'][user['shift_start']:]
        usr_result = []
        day_index = 0
        shift_index = 0
        tmp_current_day_shift = []

        while len(day_x_list)-1 >= day_index and len(shift_list)-1 >= shift_index:
            if abs(shift_list[shift_index]['x'] - day_x_list[day_index]['x']) <= threshold_x:
                tmp_current_day_shift.append(shift_list[shift_index])
                shift_index += 1
            else:
                usr_result.append({
                    'day': day_x_list[day_index]['day'],
                    'shift': tmp_current_day_shift
                })
                tmp_current_day_shift = []
                day_index += 1

        results.append(usr_result)

    if len(list(filter(lambda x: len(x) != len(day_x_list), results))) != 0:
        os.remove(tmp_file_path)
        frame = inspect.currentframe()
        raise Exception('シフトの抽出結果に誤りがあったためエラーが発生しました[{}]'.format(frame.f_lineno))

    return results


def get_joined_users_shift(users_shift, should_join_shift):
    """
    ユーザのシフトの中で、結合すべきシフトや空文字となっているシフトを結合してエクセル上の結合セルと整合性を取る
    :param users_shift:         ユーザごと×全日付の2次元配列
    :param should_join_shift:   ユーザごとの結合すべきシフトが格納された2次元配列
    :return:                    ユーザごとの結合済みのシフトが格納された2次元配列
    """

    results = []

    for user_shift, join_shift in zip(users_shift, should_join_shift):
        tmp_results = []
        skip = -1

        for i, day in enumerate(user_shift):
            # シフト文字が結合されている分だけループをスキップ
            if skip > 0:
                skip -= 1
                continue
            else:
                skip = -1

            # shouldのstartに含まれているかどうか
            shift_names = get_search_results_shift_name(day, join_shift, user_shift[i + 1:])

            if shift_names is None:
                # shift内のリスト内のテキストを結合してその日のシフト名とする
                shift_name = [x['text'] for x in day['shift']]
                tmp_results.append(''.join(shift_name))
            else:
                skip = len(shift_names) - 1
                for shift_name in shift_names:
                    tmp_results.append(shift_name)

        results.append(tmp_results)

    results_lens = [len(x) for x in results]

    if len(list(set(results_lens))) != 1:
        os.remove(tmp_file_path)
        frame = inspect.currentframe()
        raise Exception('シフトの抽出結果に誤りがあったためエラーが発生しました[{}]'.format(frame.f_lineno))

    return results


def get_search_results_shift_name(current_day_shift, join_shift, after_current_day_shifts):
    """
    結合開始・終了に含まれているかを検索。
    含まれている場合は、終了地点までのシフト文字列を結合した結果を返す
    含まれていない場合は、単純に結合した文字列を返す
    :param current_day_shift:           対象となっている1日分のシフト情報
    :param join_shift:                  結合開始・終了位置と対象ディクショナリを格納した1次元配列
    :param after_current_day_shifts:    current_day_shift以降の1次元配列
    :return:                            シフトの文字列が格納された1次元配列
    """

    if len(current_day_shift['shift']) == 0:
        return ' '

    found_shift = list(filter(lambda x: x['start'] == current_day_shift['shift'][0], join_shift))

    if len(found_shift) == 0:
        return None

    found_shift = found_shift[0]
    found_start_shift_index = current_day_shift['shift'].index(found_shift['start'])

    # 連結開始のシフト文字が0番目以外で見つかる場合は、そもそもシフトを日付で分断する際に失敗している
    if found_start_shift_index != 0:
        os.remove(tmp_file_path)
        frame = inspect.currentframe()
        raise Exception('シフトの解析エラーが発生しました[{}]'.format(frame.f_lineno))

    found_end_shift = list(filter(lambda x: x == found_shift['end'], current_day_shift['shift']))

    # startとendが1日にあるため単純に結合して返す
    if len(found_end_shift) != 0:
        shift_names = [x['text'] for x in current_day_shift['shift']]
        return [''.join(shift_names)]

    # startとendが違う場所にある場合に探す
    is_found = False
    for i, after_current_day_shift in enumerate(after_current_day_shifts):
        for shift in after_current_day_shift['shift']:
            if shift == found_shift['end']:
                is_found = True
                break

        if is_found:
            break

    # 結合して日数分だけ同じのを返す
    join_range_shift = after_current_day_shifts[:i+1]
    join_range_shift.insert(0, current_day_shift)
    shift_name = ''

    for day in join_range_shift:
        texts = [x['text'] for x in day['shift']]
        shift_name += ''.join(texts)

    results = []
    for i in range(0, len(join_range_shift)):
        results.append(shift_name)

    return results



def update_main(table_id):
    print('update', table_id)

    table = session.query(ShiftTable).filter(ShiftTable.id == table_id).one()

    return {'origin': table.origin_path, 'thumbnail': table.thumbnail_path}
