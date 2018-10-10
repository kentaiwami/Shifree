//
//  FileBrowseDetailViewController.swift
//  Shifree
//
//  Created by 岩見建汰 on 2018/07/01.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import UIKit
import PopupDialog
import FloatingActionSheetController


protocol FileBrowseDetailViewInterface: class {
    var tableID: Int { get }
    
    func popView()
    func initializeUI()
    func updateUI()
    func showErrorAlert(title: String, msg: String)
}


class FileBrowseDetailViewController: UIViewController, FileBrowseDetailViewInterface {
    
    fileprivate var presenter: FileBrowseDetailViewPresenter!
    private var pdfView: UIWebView!
    fileprivate var commentTableView: UITableView!
    fileprivate var myIndicator = UIActivityIndicatorView()

    fileprivate(set) var tableID: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        presenter = FileBrowseDetailViewPresenter(view: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 初回表示時とそれ以外で切り分けて、作成済みのViewを削除せずに更新
        if pdfView == nil {
            presenter.setFileTableDetail(isUpdate: false)
        }else {
            commentTableView.indexPathsForSelectedRows?.forEach({
                commentTableView.deselectRow(at: $0, animated: true)
            })
            presenter.setFileTableDetail(isUpdate: true)
        }
    }
    
    fileprivate func initializePDFView() {
        pdfView = UIWebView()
        pdfView.delegate = self
        pdfView.scalesPageToFit = true
        self.view.addSubview(pdfView)
        
        pdfView.top(to: self.view)
        pdfView.left(to: self.view)
        pdfView.right(to: self.view)
        pdfView.height(self.view.frame.height/2)
        
        let url = presenter.getFileTable().origin
        let encURL = URL(string: GetShifreeHost()+url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)!
        let urlRequest = URLRequest(url: encURL)
        pdfView.loadRequest(urlRequest)
    }
    
    fileprivate func initializeIndicator() {
        myIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        myIndicator.hidesWhenStopped = true
        myIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        pdfView.addSubview(myIndicator)
        myIndicator.center(in: pdfView)
    }
    
    fileprivate func initializeCommentTableView() {
        commentTableView = UITableView()
        commentTableView.delegate = self
        commentTableView.dataSource = self
        commentTableView.register(UINib(nibName: "CommentCell", bundle: nil), forCellReuseIdentifier: "CommentCell")
        commentTableView.estimatedRowHeight = 100
        commentTableView.backgroundView = getEmptyView(msg: EmptyMessage.noComment.rawValue)
        self.view.addSubview(commentTableView)
        
        commentTableView.topToBottom(of: pdfView)
        commentTableView.left(to: self.view)
        commentTableView.right(to: self.view)
        commentTableView.bottom(to: self.view)
        
        if presenter.getComments().count == 0 {
            commentTableView.backgroundView?.isHidden = false
        }else {
            commentTableView.backgroundView?.isHidden = true
        }
    }
    
    fileprivate func initializeNavigationItem() {
        let add = UIBarButtonItem(image: UIImage(named: "action"), style: .plain, target: self, action: #selector(TapActionButton))
        self.navigationItem.setRightBarButton(add, animated: false)
    }
    
    @objc private func TapActionButton(sendor: UIButton) {
        let addCommentAction = FloatingAction(title: "コメントの追加") { action in
            let addCommentVC = AddCommentViewController()
            addCommentVC.setTableID(id: self.tableID)
            let nav = UINavigationController()
            nav.viewControllers = [addCommentVC]
            nav.modalTransitionStyle = .coverVertical
            self.present(nav, animated: true, completion: nil)
        }
        addCommentAction.textColor = UIColor.hex(Color.main.rawValue, alpha: 1.0)
        addCommentAction.tintColor = UIColor.white
        
        let updateShiftTitleAction = FloatingAction(title: "タイトルの変更") { action in
            let updateTitleVC = UpdateTitleViewController()
            updateTitleVC.setAll(tableTitle: self.presenter.getFileTable().title, tableID: self.tableID)
            let nav = UINavigationController()
            nav.viewControllers = [updateTitleVC]
            nav.modalTransitionStyle = .coverVertical
            self.present(nav, animated: true, completion: nil)
        }
        updateShiftTitleAction.textColor = UIColor.hex(Color.main.rawValue, alpha: 1.0)
        updateShiftTitleAction.tintColor = UIColor.white
        
        let deleteShiftAction = FloatingAction(title: "シフトの削除") { action in
            let popup = PopupDialog(title: "再確認", message: "取り込んだシフトを削除しますか？")
            let cancelBtn = CancelButton(title: "キャンセル") {}
            let deleteBtn = DestructiveButton(title: "削除", action: {
                self.presenter.deleteFileTable()
            })
            popup.addButtons([deleteBtn, cancelBtn])
            self.present(popup, animated: true, completion: nil)
        }
        deleteShiftAction.textColor = UIColor.hex(Color.red.rawValue, alpha: 1.0)
        deleteShiftAction.tintColor = UIColor.white
        
        
        let cancelAction = FloatingAction(title: "キャンセル") { action in}
        cancelAction.textColor = UIColor.hex(Color.main.rawValue, alpha: 1.0)
        cancelAction.tintColor = UIColor.white
        
        let group1 = FloatingActionGroup()
        if presenter.isAdmin() {
            group1.add(actions: [addCommentAction, updateShiftTitleAction, deleteShiftAction])
        }else {
            group1.add(actions: [addCommentAction])
        }
        
        let group2 = FloatingActionGroup(action: cancelAction)
        FloatingActionSheetController(actionGroup: group1, group2)
            .present(in: self)
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

// MARK: - Presenterから呼び出される関数
extension FileBrowseDetailViewController {
    func initializeUI() {
        self.navigationItem.title = presenter.getFileTable().title
        initializeNavigationItem()
        initializePDFView()
        initializeIndicator()
        initializeCommentTableView()
        commentTableView.reloadData()
    }
    
    func updateUI() {
        self.navigationItem.title = presenter.getFileTable().title
        initializeNavigationItem()
        commentTableView.reloadData()
    }
    
    func showErrorAlert(title: String, msg: String) {
        showStandardAlert(title: title, msg: msg, vc: self)
    }
    
    func popView() {
        self.navigationController?.popViewController(animated: true)
    }
}


// MARK: - インスタンス化される前に呼ばれるべき関数
extension FileBrowseDetailViewController {
    func setTableID(id: Int) {
        self.tableID = id
    }
}

extension FileBrowseDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.getComments().count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "コメントの一覧"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = commentTableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentCell
        let comment = presenter.getComments()[indexPath.row]
        cell.setAll(username: comment.user, created: comment.created)
        
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = "\n" + comment.text + "\n"
        
        if presenter.isMyComment(row: indexPath.row) {
            cell.selectionStyle = .blue
            cell.accessoryType = .disclosureIndicator
        }else {
            cell.selectionStyle = .none
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {        
        if presenter.isMyComment(row: indexPath.row) {
            let editCommentVC = EditCommentViewController()
            editCommentVC.setSelectedData(indexPath: indexPath, comment: presenter.getComments()[indexPath.row])
            self.navigationController!.pushViewController(editCommentVC, animated: true)
        }
    }
}



// MARK: - PDFを表示するためにWebView関連
extension FileBrowseDetailViewController: UIWebViewDelegate {
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        myIndicator.startAnimating()
        return true
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        myIndicator.stopAnimating()
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        myIndicator.stopAnimating()
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}

