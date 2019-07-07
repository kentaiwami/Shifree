//
//  PopUpColorViewController.swift
//  Shifree
//
//  Created by 岩見建汰 on 2018/06/30.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import UIKit
import TinyConstraints


protocol PopUpColorViewInterface: class {
    func updateTableData()
    func showErrorAlert(title: String, msg: String)
}

class PopUpColorViewController: UIViewController, PopUpColorViewInterface {
    
    private var presenter: PopUpColorViewPresenter!
    var tableView = UITableView()
    
    fileprivate let utility = Utility()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = PopUpColorViewPresenter(view: self)
        presenter.setShiftCategoryColor()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsSelection = false
        tableView.register(UINib(nibName: "ColorCell", bundle: nil), forCellReuseIdentifier: "ColorCell")
        tableView.backgroundView = utility.getEmptyView(msg: EmptyMessage.becauseNoShiftCategory.rawValue)
        self.view.addSubview(tableView)
        
        tableView.height(self.view.frame.height / 2)
        tableView.top(to: self.view)
        tableView.left(to: self.view)
        tableView.right(to: self.view)
        tableView.bottom(to: self.view)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}



// MARK: - Presenterから呼び出される関数
extension PopUpColorViewController {
    func showErrorAlert(title: String, msg: String) {
        utility.showStandardAlert(title: title, msg: msg, vc: self)
    }
    
    func updateTableData() {
        tableView.reloadData()
        
        if presenter.getShiftCategoryColor().count == 0 {
            tableView.backgroundView?.isHidden = false
        }else {
            tableView.backgroundView?.isHidden = true
        }
    }
}


// MARK: - TableView関連
extension PopUpColorViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "ColorCell") as! ColorCell
        
        let shiftCategoryColor = presenter.getShiftCategoryColor()
        
        cell.setCell(name: shiftCategoryColor[indexPath.row].name, color: shiftCategoryColor[indexPath.row].color)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.getShiftCategoryColor().count
    }
}


