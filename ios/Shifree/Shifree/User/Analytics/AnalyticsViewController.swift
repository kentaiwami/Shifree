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
    
    let months = ["Jan", "Feb", "Mar",
                  "Apr", "May", "Jun",
                  "Jul", "Aug", "Sep",
                  "Oct", "Nov", "Dec"]

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        presenter = AnalyticsViewPresenter(view: self)
        initializeNavigationItem()
        
        self.navigationItem.title = "シフトの集計結果"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        presenter.setData()
    }
    
    private func initializePieChartView() {
        let chart = PieChartView(frame: self.view.frame)
        chart.chartDescription?.text = ""
        chart.chartDescription?.font = UIFont.systemFont(ofSize: 17)
        chart.chartDescription?.enabled = true
        chart.usePercentValuesEnabled = false
        chart.highlightPerTapEnabled = true
        chart.drawEntryLabelsEnabled = true
        chart.rotationEnabled = true
        chart.noDataText = "シフトデータがないため、表示されません。"
        
        chart.legend.enabled = true
        chart.legend.horizontalAlignment = .left
        chart.legend.verticalAlignment = .top
        chart.legend.orientation = .vertical
        chart.legend.font = UIFont.systemFont(ofSize: 15)
        
        let legendEntries:[LegendEntry] = presenter.getCustomLegend().map({ category in
            let tmp = LegendEntry()
            tmp.label = category.name
            tmp.form = .square
            tmp.formColor = UIColor.hex(category.hex, alpha: 1.0)
            
            return tmp
        })
        chart.legend.setCustom(entries: legendEntries)
        
        chart.centerText = presenter.getPieChartCenterTitle()
        
        var values:[PieChartDataEntry] = []
        let colors:[UIColor] = presenter.getPieChartColorHex().map({ hex in
            return UIColor.hex(hex, alpha: 1.0)
        })
        
        if let categories = presenter.getPieChartTables() {
            for category in categories {
                values.append(PieChartDataEntry(value: Double(category.count), label: category.name))
            }
        }
        
        let dataSet = PieChartDataSet(values: values, label: "")
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
            chart.data = data
        }
        
        self.view.addSubview(chart)
        
        chart.center(in: self.view)
        chart.edges(to: self.view)
        
        pieChartView = chart
        
        chart.animate(xAxisDuration: 1.4, easingOption: .easeOutBack)
    }
    
    private func initializeBarChartView() {
        let barChartView = BarChartView(frame: self.view.frame)
        
        let values:[BarChartDataEntry] = [
            BarChartDataEntry(x: 1, yValues: [10,20,30, 10]),
            BarChartDataEntry(x: 2, yValues: [30,20,80])
        ]
        let set = BarChartDataSet(values: values, label: "")
        set.drawIconsEnabled = false
        set.colors = [
            ChartColorTemplates.material()[0],
            ChartColorTemplates.material()[1],
            ChartColorTemplates.material()[2],
            ChartColorTemplates.material()[3]
        ]
        set.stackLabels = ["Births", "Divorces", "Marriages", "TEST"]
        
        let pFormatter = NumberFormatter()
        pFormatter.numberStyle = .percent
        pFormatter.maximumFractionDigits = 1
        pFormatter.multiplier = 1
        pFormatter.percentSymbol = " %"
        
        let data = BarChartData(dataSet: set)
        data.setValueFont(.systemFont(ofSize: 7, weight: .light))
        data.setValueFormatter(DefaultValueFormatter(formatter: pFormatter))
        data.setValueTextColor(.white)
        
        barChartView.fitBars = true
        barChartView.data = data
        barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: months)
        barChartView.xAxis.labelCount = 2
        barChartView.xAxis.labelPosition = .bottom
        barChartView.chartDescription?.text = ""
        
        
        self.view.addSubview(barChartView)
        
        barChartView.center(in: self.view)
        barChartView.edges(to: self.view)
        
        self.barChartView = barChartView
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
