//
//  hoge.swift
//  Parjob
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

class PopUpColorViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, PopUpColorViewInterface {
    
    @IBOutlet weak var tableView: UITableView!
    private var presenter: PopUpColorViewPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = PopUpColorViewPresenter(view: self)
        presenter.setShiftCategoryColor()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsSelection = false
        
        tableView.height(self.view.frame.height / 2)
        tableView.top(to: self.view)
        tableView.left(to: self.view)
        tableView.right(to: self.view)
        tableView.bottom(to: self.view)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as! PopUpColorCell
        let shiftCategoryColor = presenter.getShiftCategoryColor()
        
        cell.setCell(name: shiftCategoryColor[indexPath.row].name, color: shiftCategoryColor[indexPath.row].color)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.getShiftCategoryColor().count
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension PopUpColorViewController {
    func showErrorAlert(title: String, msg: String) {
        ShowStandardAlert(title: title, msg: msg, vc: self, completion: nil)
    }
    
    func updateTableData() {
        tableView.reloadData()
    }
}


