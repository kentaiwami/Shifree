//
//  SalaryViewController.swift
//  Parjob
//
//  Created by 岩見建汰 on 2018/07/01.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import UIKit
import ScrollableGraphView
import PopupDialog


protocol SalaryViewInterface: class {
    func showErrorAlert(title: String, msg: String)
    func initializeUI()
    func reloadUI()
}


class SalaryViewController: UIViewController, ScrollableGraphViewDataSource, SalaryViewInterface {
    
    fileprivate var presenter: SalaryViewPresenter!
    var graphView = ScrollableGraphView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        
        presenter = SalaryViewPresenter(view: self)
        presenter.setSalary()
    }
    
    fileprivate func initializeGraph() {
        let frame = CGRect.zero
        let graphView = ScrollableGraphView(frame: frame, dataSource: self)
        
        let linePlot = LinePlot(identifier: "darkLine")
        linePlot.lineWidth = 1
        linePlot.lineColor = UIColor.hex("#777777", alpha: 1.0)
        linePlot.lineStyle = ScrollableGraphViewLineStyle.smooth
        linePlot.shouldFill = true
        linePlot.fillType = ScrollableGraphViewFillType.gradient
        linePlot.fillGradientType = ScrollableGraphViewGradientType.linear
        linePlot.fillGradientStartColor = UIColor.hex("#555555", alpha: 1.0)
        linePlot.fillGradientEndColor = UIColor.hex("#444444", alpha: 1.0)
        linePlot.adaptAnimationType = ScrollableGraphViewAnimationType.elastic
        
        let dotPlot = DotPlot(identifier: "darkLineDot")
        dotPlot.dataPointSize = 2
        dotPlot.dataPointFillColor = UIColor.white
        dotPlot.adaptAnimationType = ScrollableGraphViewAnimationType.elastic
        
        let referenceLines = ReferenceLines()
        referenceLines.referenceLineLabelFont = UIFont.boldSystemFont(ofSize: 13)
        referenceLines.referenceLineColor = UIColor.white.withAlphaComponent(0.2)
        referenceLines.referenceLineLabelColor = UIColor.white
        referenceLines.shouldShowLabels = true
        referenceLines.positionType = .relative
        referenceLines.relativePositions = [0, 0.25, 0.5, 0.75, 1]
        referenceLines.includeMinMax = true
        referenceLines.dataPointLabelColor = UIColor.white.withAlphaComponent(0.5)
        
        graphView.backgroundFillColor = UIColor.hex("#333333", alpha: 1.0)
        graphView.dataPointSpacing = 80
        graphView.shouldAnimateOnStartup = true
        graphView.shouldAdaptRange = true
        graphView.shouldRangeAlwaysStartAtZero = true
        graphView.direction = .rightToLeft
        graphView.rangeMax = presenter.getSalaryMax()
        graphView.addReferenceLines(referenceLines: referenceLines)
        graphView.addPlot(plot: linePlot)
        graphView.addPlot(plot: dotPlot)

        self.graphView = graphView
        self.view.addSubview(graphView)
        
        graphView.width(to: self.view)
        graphView.height(to: self.view)
        graphView.left(to: self.view)
        graphView.right(to: self.view)
//        graphView.height(self.view.frame.height / 2)
//        graphView.center(in: self.view)
    }
    
    fileprivate func initializeNavigationItem() {
        let check = UIBarButtonItem(image: UIImage(named: "reload"), style: .plain, target: self, action: #selector(tapReloadButton))
        self.navigationItem.setRightBarButton(check, animated: true)
    }
    
    @objc private func tapReloadButton() {
        presenter.reloadSalary()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "Salary View"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}


// MARK: - Presenterから呼び出される関数
extension SalaryViewController {
    func initializeUI() {
        initializeGraph()
        initializeNavigationItem()
    }
    
    func reloadUI() {
        graphView.removeFromSuperview()
        initializeGraph()
    }
    
    func showErrorAlert(title: String, msg: String) {
        ShowStandardAlert(title: title, msg: msg, vc: self, completion: nil)
    }
}


// MARK: - ScrollableGraphView関連
extension SalaryViewController {
    func value(forPlot plot: Plot, atIndex pointIndex: Int) -> Double {
        return Double(presenter.getSalary()[pointIndex].pay)
    }
    
    func label(atIndex pointIndex: Int) -> String {
        return presenter.getSalary()[pointIndex].title
    }
    
    func numberOfPoints() -> Int {
        return presenter.getSalary().count
    }
}
