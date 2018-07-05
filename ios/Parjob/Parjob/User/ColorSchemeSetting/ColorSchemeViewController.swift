//
//  ColorSchemeViewController.swift
//  Parjob
//
//  Created by 岩見建汰 on 2018/07/01.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import UIKit
import TinyConstraints

protocol ColorSchemViewInterface: class {
    func updateTableData()
    func showErrorAlert(title: String, msg: String)
}

class ColorSchemeViewController: UIViewController, ColorSchemViewInterface {
    
    var tableView = UITableView()
    fileprivate var presenter: ColorSchemViewPresenter!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = ColorSchemViewPresenter(view: self)
        presenter.setShiftCategoryColor()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "CustomColorTableViewCell", bundle: nil), forCellReuseIdentifier: "CustomColorCell")
        self.view.addSubview(tableView)

        tableView.height(to: self.view)
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
extension ColorSchemeViewController {
    func updateTableData() {
        tableView.reloadData()
    }
    
    func showErrorAlert(title: String, msg: String) {
        ShowStandardAlert(title: title, msg: msg, vc: self, completion: nil)
    }
}


extension ColorSchemeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.getShiftCategoryColor().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "CustomColorCell") as! CustomColorTableViewCell
        let shiftCategoryColor = presenter.getShiftCategoryColor()
        
        cell.setCell(name: shiftCategoryColor[indexPath.row].name, color: shiftCategoryColor[indexPath.row].color)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
