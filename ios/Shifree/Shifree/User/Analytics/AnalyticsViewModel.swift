//
//  AnalyticsViewModel.swift
//  Shifree
//
//  Created by 岩見建汰 on 2018/07/01.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import Foundation

protocol AnalyticsViewModelDelegate: class {
    func drawPieChartView()
    func drawBarChartView()
    func faildAPI(title: String, msg: String)
}

class AnalyticsViewModel {
    weak var delegate: AnalyticsViewModelDelegate?
    private let api = API()
    private(set) var range = "latest"
    private(set) var follow = ""
    private(set) var results:[AnalyticsResultFileTable] = []
    
    func setData() {
        api.getAnalyticsData(range: range).done { (json) in
            self.follow = json["results"]["follow"].stringValue
            self.results = json["results"]["table"].arrayValue.map({ table in
                let tmpCategories:[AnalyticsResultCategory] = table["category"].arrayValue.map({ category in
                    return AnalyticsResultCategory.init(
                        count: category["count"].doubleValue,
                        hex: category["hex"].stringValue,
                        name: category["name"].stringValue
                    )
                })
                return AnalyticsResultFileTable.init(
                    start: table["start"].stringValue,
                    end: table["end"].stringValue,
                    title: table["title"].stringValue,
                    categories: tmpCategories
                )
            })
            
            if self.range == "latest" {
                self.delegate?.drawPieChartView()
            }else {
                self.delegate?.drawBarChartView()
            }
        }
        .catch { (err) in
            let tmp_err = err as NSError
            let title = "Error(" + String(tmp_err.code) + ")"
            self.delegate?.faildAPI(title: title, msg: tmp_err.domain)
        }
    }
    
    func setRange(range: String) {
        self.range = range
    }
    
    func isNodata() -> Bool {
        return results.count == 0
    }
}


// MARK: - PieChart
extension AnalyticsViewModel {
    func getPieChartCenterTitle() -> String? {
        return results.first?.title
    }
    
    func getPieChartTableValue() -> [AnalyticsResultCategory]? {
        return results.first?.categories.filter({$0.count != 0})
    }
    
    func getPieChartColorHex() -> [String] {
        if let fileTable = results.first {
            return fileTable.categories.filter({$0.count != 0}).map({$0.hex})
        }
        
        return []
    }
    
    func getPieChartCustomLegend() -> [AnalyticsResultCategory] {
        if let fileTable = results.first {
            return fileTable.categories
        }
        
        return []
    }
}


// MARK: - BarChart
extension AnalyticsViewModel {
    func getBarChartCategoryCount() -> [[Double]] {
        var tmp:[[Double]] = []
        
        if results.count >= 2 {
            for fileTable in results.reversed() {
                tmp.append(fileTable.categories.map({$0.count}))
            }
        }
        
        return tmp
    }
    
    func getBarChartLabelAndColor() -> (label: [String], color: [String]) {
        var label:[String] = []
        var color:[String] = []
        
        if results.count >= 2 {
            label = results.first!.categories.map({$0.name})
            color = results.first!.categories.map({$0.hex})
        }
        
        return (label, color)
    }
    
    func getBarChartTableTitle() -> [String] {
        var title:[String] = []
        
        if results.count >= 2 {
            title = results.reversed().map({$0.title})
        }
        
        return title
    }
}
