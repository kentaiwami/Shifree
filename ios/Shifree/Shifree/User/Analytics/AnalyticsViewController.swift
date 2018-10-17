//
//  AnalyticsViewController.swift
//  Shifree
//
//  Created by 岩見建汰 on 2018/07/01.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import UIKit
import Eureka
import Charts

protocol AnalyticsViewInterface: class {
    var formValue: [String:Any?] { get }
    func success()
    func showErrorAlert(title: String, msg: String)
}


class AnalyticsViewController: FormViewController, AnalyticsViewInterface {
    
    private var presenter: AnalyticsViewPresenter!
    var formValue: [String : Any?] {
        return form.values()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = AnalyticsViewPresenter(view: self)
        initializeUI()
        self.navigationItem.title = "シフトの集計結果"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func initializeChartView() {
        let chart = PieChartView(frame: self.view.frame)
        chart.chartDescription?.text = ""
        chart.usePercentValuesEnabled = true
        chart.highlightPerTapEnabled = true
        chart.chartDescription?.enabled = true
        chart.drawEntryLabelsEnabled = true
        chart.legend.enabled = true
        chart.rotationEnabled = true
        
        let values = [
            PieChartDataEntry(value: 300, label: "中番"),
            PieChartDataEntry(value: 90, label: "遅番"),
            PieChartDataEntry(value: 0, label: "Un"),
            PieChartDataEntry(value: 0, label: "ABC")
        ]
        let dataSet = PieChartDataSet(values: values, label: "")
        dataSet.setColors(UIColor.hex("#FF6D00", alpha: 1.0), UIColor.hex("#212121", alpha: 1.0))
        
        dataSet.drawValuesEnabled = true
        
        chart.legend.horizontalAlignment = .left
        chart.legend.verticalAlignment = .top
        chart.legend.orientation = .vertical
        chart.legend.font = UIFont.systemFont(ofSize: 20)
        
        chart.centerText = "10月11日〜"
        
        let data = PieChartData(dataSet: dataSet)
        
        let pFormatter = NumberFormatter()
        pFormatter.numberStyle = .percent
        pFormatter.maximumFractionDigits = 1
        pFormatter.multiplier = 1
        pFormatter.percentSymbol = " %"
        data.setValueFormatter(DefaultValueFormatter(formatter: pFormatter))
        
        chart.data = data
        
        self.view.addSubview(chart)
        
        chart.center(in: self.view)
        chart.edges(to: self.view)
    }
    
    private func initializeUI() {
        initializeNavigationItem()
        initializeChartView()
    }
    
    private func initializeNavigationItem() {
        let check = UIBarButtonItem(image: UIImage(named: "checkmark"), style: .plain, target: self, action: #selector(tapEditDoneButton))
        self.navigationItem.setRightBarButton(check, animated: true)
    }
    
    @objc private func tapEditDoneButton() {
        if isValidateFormValue(form: self.form) {
            presenter.postContact()
        }else {
            showStandardAlert(title: "エラー", msg: "入力されていない項目があります", vc: self)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}



// MARK: - Presenterから呼び出される関数
extension AnalyticsViewController {
    func success() {
        showStandardAlert(title: "完了", msg: "お問い合わせありがとうございます", vc: self) {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func showErrorAlert(title: String, msg: String) {
        showStandardAlert(title: title, msg: msg, vc: self)
    }
}
