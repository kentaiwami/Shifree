//
//  Enum.swift
//  Parjob
//
//  Created by 岩見建汰 on 2018/06/24.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import Foundation

enum Color: String {
    case main = "#20324f"
    case red = "#FF2726"
}

enum EmptyMessage: String {
    case noShiftInfo = "シフト情報はありません"
    case becauseNoShiftCategory = "シフトカテゴリが登録されていないため、\n表示されません。"
    case becauseNoImportShiftFile = "シフトファイルが取り込まれていないため、\n表示されません。"
    case becauseNotFoundShiftInfo = "該当するシフト情報が見つからないため、\n表示されません。"
    case becauseNoUser = "ユーザが登録されていないため、\n表示されません。"
    case noComment = "コメントはありません"
}
