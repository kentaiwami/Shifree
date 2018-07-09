//
//  EditCommentViewController.swift
//  Parjob
//
//  Created by 岩見建汰 on 2018/06/28.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import UIKit
import Eureka


protocol EditCommentViewInterface: class {
    var indexPath: IndexPath { get }
    var formValues: [String:Any?] { get }
    
    func showErrorAlert(title: String, msg: String)
    func popupViewController()
}

class EditCommentViewController: FormViewController, EditCommentViewInterface {
    var indexPath: IndexPath = []
    var formValues: [String : Any?] = [:]
    fileprivate var presenter: EditCommentViewPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializePresenter()
        initializeUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "Edit Comment"
    }
    
    private func initializePresenter() {
        let fileBrowseDetailVC = self.navigationController?.viewControllers[1] as! FileBrowseDetailViewController
        let comment = fileBrowseDetailVC.getComment()[indexPath.row]
        presenter = EditCommentViewPresenter(view: self)
        presenter.setSelectedCommentData(comment: comment)
    }
    
    fileprivate func initializeNavigationItem() {
        let check = UIBarButtonItem(image: UIImage(named: "checkmark"), style: .plain, target: self, action: #selector(tapEditDoneButton))
        self.navigationItem.setRightBarButton(check, animated: true)
    }
    
    @objc private func tapEditDoneButton() {
        self.formValues = self.form.values()
        presenter.tapEditDoneButton()
    }
    
    fileprivate func initializeForm() {
        UIView.setAnimationsEnabled(false)
        
        form +++ Section(footer: "何も入力しない状態で保存した場合、コメントは削除されます。")
            <<< TextAreaRow(){
                $0.title = "Comment"
                $0.tag = "Comment"
                $0.value = presenter.getComment().text
                $0.placeholder = "タップしてコメントを入力…"
        }
        
        UIView.setAnimationsEnabled(true)
    }
        
    /// どのセクションをタップしてインスタンス化したかを記録
    ///
    /// - Parameter at: タップされたIndexPath
    func setIndexPath(at: IndexPath) {
        self.indexPath = at
    }
    
    private func initializeUI() {
        initializeNavigationItem()
        initializeForm()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension EditCommentViewController {
    func showErrorAlert(title: String, msg: String) {
        ShowStandardAlert(title: title, msg: msg, vc: self, completion: nil)
    }
    
    func popupViewController() {
        self.navigationController?.popViewController(animated: true)
    }
}
