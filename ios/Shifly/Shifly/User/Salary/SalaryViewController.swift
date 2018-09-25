//
//  SalaryViewController.swift
//  Shifly
//
//  Created by 岩見建汰 on 2018/07/01.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import UIKit
import ScrollableGraphView

protocol SalaryViewInterface: class {
    func showErrorAlert(title: String, msg: String)
    func initializeUI()
    func reloadUI()
}


class SalaryViewController: UIViewController, ScrollableGraphViewDataSource, SalaryViewInterface {
    
    fileprivate var presenter: SalaryViewPresenter!
    var graphView = ScrollableGraphView()
    var emptyView = getEmptyView(msg: EmptyMessage.becauseNotFoundShiftInfo.rawValue)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        
        presenter = SalaryViewPresenter(view: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "給与"
        
        graphView.removeFromSuperview()
        emptyView.removeFromSuperview()
        presenter.setSalary()
    }
    
    fileprivate func initializeGraph() {
        let frame = CGRect.zero
        let graphView = ScrollableGraphView(frame: frame, dataSource: self)
        
        let barPlot = BarPlot(identifier: "bar")
        barPlot.barWidth = 25
        barPlot.barLineWidth = 1
        barPlot.barLineColor = UIColor.hex(Color.main.rawValue, alpha: 0.7)
        barPlot.barColor = UIColor.hex(Color.main.rawValue, alpha: 0.5)
        barPlot.adaptAnimationType = ScrollableGraphViewAnimationType.elastic
        barPlot.animationDuration = 1.5
        
        var relativePositions: [Double] = []
        if presenter.getSalaryMax() != 0.0 {
            relativePositions = [0, 0.25, 0.5, 0.75, 1]
        }
        
        let referenceLines = ReferenceLines()
        referenceLines.referenceLineLabelFont = UIFont.boldSystemFont(ofSize: 13)
        referenceLines.referenceLineColor = UIColor.hex(Color.main.rawValue, alpha: 0.5)
        referenceLines.referenceLineLabelColor = UIColor.hex(Color.main.rawValue, alpha: 1.0)
        referenceLines.referenceLineNumberStyle = .currency
        referenceLines.shouldShowLabels = true
        referenceLines.positionType = .relative
        referenceLines.relativePositions = relativePositions
        referenceLines.includeMinMax = true
        referenceLines.dataPointLabelColor = UIColor.hex(Color.main.rawValue, alpha: 1.0)
        referenceLines.dataPointLabelFont = UIFont.boldSystemFont(ofSize: 12)
        
        graphView.backgroundFillColor = UIColor.white
        graphView.dataPointSpacing = 80
        graphView.leftmostPointPadding = 100
        graphView.shouldAnimateOnStartup = true
        graphView.shouldRangeAlwaysStartAtZero = true
        graphView.direction = .rightToLeft
        graphView.rangeMax = presenter.getSalaryMax()
        graphView.addPlot(plot: barPlot)
        graphView.addReferenceLines(referenceLines: referenceLines)

        self.graphView = graphView
        self.view.addSubview(graphView)
        
        graphView.width(to: self.view)
        graphView.height(to: self.view)
        graphView.left(to: self.view)
        graphView.right(to: self.view)
        
        self.view.addSubview(emptyView)
        emptyView.edges(to: self.view)
        
        if presenter.getSalary().count == 0 {
            graphView.isHidden = true
            emptyView.isHidden = false
        }else {
            graphView.isHidden = false
            emptyView.isHidden = true
        }
    }
    
    fileprivate func initializeNavigationItem() {
        let check = UIBarButtonItem(image: UIImage(named: "reload"), style: .plain, target: self, action: #selector(tapReloadButton))
        self.navigationItem.setRightBarButton(check, animated: true)
    }
    
    @objc private func tapReloadButton() {
        presenter.reloadSalary()
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
        emptyView.removeFromSuperview()
        initializeGraph()
    }
    
    func showErrorAlert(title: String, msg: String) {
        showStandardAlert(title: title, msg: msg, vc: self)
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
