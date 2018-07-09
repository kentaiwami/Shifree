//
//  ColorSchemeViewController.swift
//  Parjob
//
//  Created by 岩見建汰 on 2018/07/01.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import UIKit
import TinyConstraints
import MKColorPicker

protocol ColorSchemViewInterface: class {
    var selectedColor: String { get }
    var selectedCellIndexPath: IndexPath { get }
    
    func successUpdateShiftCategory()
    func updateTableData()
    func showErrorAlert(title: String, msg: String)
}

class ColorSchemeViewController: UIViewController, ColorSchemViewInterface {
    var selectedColor = ""
    var selectedCellIndexPath = IndexPath()
    
    var tableView = UITableView()
    fileprivate var presenter: ColorSchemViewPresenter!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = ColorSchemViewPresenter(view: self)
        presenter.setOriginShiftCategoryColor()
        initializeUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "Color Scheme Setting"
    }
    
    private func initializeUI() {
        initializeTableView()
        initializeNavigationItem()
    }
    
    private func initializeTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "ColorCell", bundle: nil), forCellReuseIdentifier: "ColorCell")
        tableView.backgroundView = GetEmptyView(msg: "シフトカテゴリが登録されていないため、\n表示されません。")
        self.view.addSubview(tableView)
        
        tableView.height(to: self.view)
        tableView.top(to: self.view)
        tableView.left(to: self.view)
        tableView.right(to: self.view)
        tableView.bottom(to: self.view)
    }
    
    private func initializeNavigationItem() {
        let check = UIBarButtonItem(image: UIImage(named: "checkmark"), style: .plain, target: self, action: #selector(tapEditDoneButton))
        self.navigationItem.setRightBarButton(check, animated: true)
    }
    
    @objc private func tapEditDoneButton() {
        presenter.updateShiftCategory()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}


// MARK: - Presenterから呼び出される関数
extension ColorSchemeViewController {
    func updateTableData() {
        tableView.reloadData()
        
        if presenter.getShiftCategoryColor().count == 0 {
            tableView.backgroundView?.isHidden = false
        }else {
            tableView.backgroundView?.isHidden = true
        }
    }
    
    func successUpdateShiftCategory() {
        ShowStandardAlert(title: "Success", msg: "情報を更新しました", vc: self) {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func showErrorAlert(title: String, msg: String) {
        ShowStandardAlert(title: title, msg: msg, vc: self, completion: nil)
    }
}



// MARK: - TableView関連
extension ColorSchemeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.getShiftCategoryColor().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "ColorCell") as! ColorCell
        let shiftCategoryColor = presenter.getShiftCategoryColor()
        
        cell.setCell(name: shiftCategoryColor[indexPath.row].name, color: shiftCategoryColor[indexPath.row].color)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCell = tableView.cellForRow(at: indexPath) as! ColorCell
        selectedCellIndexPath = indexPath
        showColorPicker(sendor: selectedCell)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}



// MARK: - PupOverColorPicker関連
extension ColorSchemeViewController{
    func showColorPicker(sendor: UIView) {
        let MKColorPicker = ColorPickerViewController()
        MKColorPicker.selectedColor = { color in
            self.selectedColor = color.toHexString
            self.presenter.setShiftCategoryColor()
        }

        if let popoverController = MKColorPicker.popoverPresentationController{
            popoverController.delegate = MKColorPicker
            popoverController.permittedArrowDirections = .any
            popoverController.sourceView = sendor
            popoverController.sourceRect = sendor.bounds
        }
        self.present(MKColorPicker, animated: true, completion: nil)
    }
}
