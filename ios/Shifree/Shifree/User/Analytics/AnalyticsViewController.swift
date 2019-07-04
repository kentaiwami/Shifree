//
//  AnalyticsViewController.swift
//  Shifree
//
//  Created by 岩見建汰 on 2018/07/01.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import UIKit
import Charts
import FloatingActionSheetController

protocol AnalyticsViewInterface: class {
    func drawPieChartView()
    func drawBarChartView()
    func showErrorAlert(title: String, msg: String)
}


class AnalyticsViewController: UIViewController, AnalyticsViewInterface {
    
    private var presenter: AnalyticsViewPresenter!
    private var pieChartView: PieChartView!
    private var barChartView: BarChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        presenter = AnalyticsViewPresenter(view: self)
        initializeNavigationItem()
        
        self.navigationItem.title = "集計結果"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        presenter.setRange(range: "latest")
        presenter.setData()
    }
    
    private func initializePieChartView() {
        self.navigationItem.title = "集計結果" + presenter.getFollowTitle()
        
        let pieChartView = PieChartView(frame: self.view.frame)
        pieChartView.chartDescription?.text = ""
        pieChartView.chartDescription?.font = UIFont.systemFont(ofSize: 17)
        pieChartView.chartDescription?.enabled = true
        pieChartView.usePercentValuesEnabled = false
        pieChartView.highlightPerTapEnabled = true
        pieChartView.drawEntryLabelsEnabled = true
        pieChartView.rotationEnabled = true
        pieChartView.noDataText = "シフトデータがないため、表示されません。"
        
        pieChartView.legend.enabled = true
        pieChartView.legend.horizontalAlignment = .left
        pieChartView.legend.verticalAlignment = .top
        pieChartView.legend.orientation = .vertical
        pieChartView.legend.font = UIFont.systemFont(ofSize: 15)
        
        let legendEntries:[LegendEntry] = presenter.getPieChartCustomLegend().map({ category in
            let tmp = LegendEntry()
            tmp.label = category.name
            tmp.form = .square
            tmp.formColor = UIColor.hex(category.hex, alpha: 1.0)
            
            return tmp
        })
        pieChartView.legend.setCustom(entries: legendEntries)
        
        pieChartView.centerText = presenter.getPieChartCenterTitle()
        
        var values:[PieChartDataEntry] = []
        let colors:[UIColor] = presenter.getPieChartColorHex().map({ hex in
            return UIColor.hex(hex, alpha: 1.0)
        })
        
        if let categories = presenter.getPieChartTables() {
            for category in categories {
                values.append(PieChartDataEntry(value: category.count, label: category.name))
            }
        }
        
        let dataSet = PieChartDataSet(entries: values, label: "")
        dataSet.setColors(colors, alpha: 1.0)
        dataSet.drawValuesEnabled = true
        dataSet.selectionShift = 0
        dataSet.entryLabelFont = UIFont.systemFont(ofSize: 16)
        
        let data = PieChartData(dataSet: dataSet)
        
        let pFormatter = NumberFormatter()
        pFormatter.numberStyle = .percent
        pFormatter.maximumFractionDigits = 1
        pFormatter.multiplier = 1
        pFormatter.percentSymbol = " 日"
        pFormatter.zeroSymbol = ""
        data.setValueFormatter(DefaultValueFormatter(formatter: pFormatter))
        
        if !presenter.isNodata() {
            pieChartView.data = data
        }
        
        self.view.addSubview(pieChartView)
        
        pieChartView.center(in: self.view)
        pieChartView.edges(to: self.view)
        
        self.pieChartView = pieChartView
        
        pieChartView.animate(xAxisDuration: 0.5, easingOption: .easeOutBack)
    }
    
    private func initializeBarChartView() {
        self.navigationItem.title = "集計結果" + presenter.getFollowTitle()
        
        let barChartView = BarChartView(frame: self.view.frame)
        barChartView.fitBars = true
        barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: presenter.getBarChartTableTitle())
        barChartView.xAxis.labelCount = presenter.getBarChartCategoryCount().count
        barChartView.xAxis.labelPosition = .bottom
        barChartView.chartDescription?.text = ""
        barChartView.noDataText = presenter.getNodataText()
        barChartView.drawValueAboveBarEnabled = false
        barChartView.rightAxis.enabled = false
        
        var values:[BarChartDataEntry] = []
        
        for (index, categoryCount) in presenter.getBarChartCategoryCount().enumerated() {
            values.append(BarChartDataEntry(x: Double(index), yValues: categoryCount))
        }
        
        let set = BarChartDataSet(entries: values, label: "")
        set.drawIconsEnabled = false
        set.highlightEnabled = false
        set.colors = presenter.getBarChartLabelAndColor().color.map({UIColor.hex($0, alpha: 1.0)})
        set.stackLabels = presenter.getBarChartLabelAndColor().label
        
        let pFormatter = NumberFormatter()
        pFormatter.numberStyle = .percent
        pFormatter.maximumFractionDigits = 1
        pFormatter.multiplier = 1
        pFormatter.percentSymbol = " 日"
        pFormatter.zeroSymbol = ""
        
        let data = BarChartData(dataSet: set)
        data.setValueFont(.systemFont(ofSize: 14, weight: .light))
        data.setValueFormatter(DefaultValueFormatter(formatter: pFormatter))
        data.setValueTextColor(.white)
        
        if !presenter.isNodata() {
            barChartView.data = data
        }

        self.view.addSubview(barChartView)
        barChartView.center(in: self.view)
        barChartView.edges(to: self.view)
        
        self.barChartView = barChartView
        
        barChartView.animate(yAxisDuration: 0.5)
    }
    
    private func initializeNavigationItem() {
        let action = UIBarButtonItem(image: UIImage(named: "action"), style: .plain, target: self, action: #selector(tapActionButton))
        self.navigationItem.setRightBarButton(action, animated: true)
    }
    
    @objc private func tapActionButton() {
        let latestAction = FloatingAction(title: "最新のシフト") { action in
            self.presenter.setRange(range: "latest")
            self.presenter.setData()
        }
        latestAction.textColor = UIColor.hex(Color.main.rawValue, alpha: 1.0)
        latestAction.tintColor = UIColor.white
        
        let prevAction = FloatingAction(title: "過去2つ分のシフト") { action in
            self.presenter.setRange(range: "prev")
            self.presenter.setData()
        }
        prevAction.textColor = UIColor.hex(Color.main.rawValue, alpha: 1.0)
        prevAction.tintColor = UIColor.white
        
        let allAction = FloatingAction(title: "全てのシフト") { action in
            self.presenter.setRange(range: "all")
            self.presenter.setData()
        }
        allAction.textColor = UIColor.hex(Color.main.rawValue, alpha: 1.0)
        allAction.tintColor = UIColor.white
        
        let cancelAction = FloatingAction(title: "キャンセル") { action in}
        cancelAction.textColor = UIColor.hex(Color.main.rawValue, alpha: 1.0)
        cancelAction.tintColor = UIColor.white
        
        let group1 = FloatingActionGroup(actions: [latestAction, prevAction, allAction])
        let group2 = FloatingActionGroup(action: cancelAction)
        FloatingActionSheetController(actionGroup: group1, group2).present(in: self)
    }
    
    private func removeViews() {
        if barChartView != nil {
            barChartView.removeFromSuperview()
        }
        
        if pieChartView != nil {
            pieChartView.removeFromSuperview()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}



// MARK: - Presenterから呼び出される関数
extension AnalyticsViewController {
    
    func drawPieChartView() {
        removeViews()
        initializePieChartView()
    }
    
    func drawBarChartView() {
        removeViews()
        initializeBarChartView()
    }
    
    func showErrorAlert(title: String, msg: String) {
        showStandardAlert(title: title, msg: msg, vc: self)
    }
}
