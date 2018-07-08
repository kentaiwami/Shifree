//
//  FileBrowseDetailViewController.swift
//  Parjob
//
//  Created by 岩見建汰 on 2018/07/01.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import UIKit
import PopupDialog

protocol FileBrowseDetailViewInterface: class {
    var tableID: Int { get }
    
    func initializeUI()
    func success()
    func showErrorAlert(title: String, msg: String)
}


class FileBrowseDetailViewController: UIViewController, FileBrowseDetailViewInterface {
    
    fileprivate var presenter: FileBrowseDetailViewPresenter!
    private var pdfView: UIWebView!
    fileprivate var commentTableView: UITableView!
    
    var navigationTitle: String = ""
    var tableID: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        
        presenter = FileBrowseDetailViewPresenter(view: self)
        presenter.setFileTableDetail()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = navigationTitle
    }
    
    fileprivate func initializePDFView() {
        pdfView = UIWebView()
        pdfView.delegate = self
        self.view.addSubview(pdfView)
        
        pdfView.top(to: self.view)
        pdfView.left(to: self.view)
        pdfView.right(to: self.view)
        pdfView.height(self.view.frame.height/2)
        
        let url = presenter.getFileTable().origin
        let encURL = URL(string: GetHost()+url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)!
        let urlRequest = URLRequest(url: encURL)
        pdfView.loadRequest(urlRequest)
    }
    
    fileprivate func initializeCommentTableView() {
        commentTableView = UITableView()
        commentTableView.delegate = self
        commentTableView.dataSource = self
        commentTableView.register(UINib(nibName: "CommentCell", bundle: nil), forCellReuseIdentifier: "CommentCell")
        self.view.addSubview(commentTableView)
        
        commentTableView.topToBottom(of: pdfView)
        commentTableView.left(to: self.view)
        commentTableView.right(to: self.view)
        commentTableView.bottom(to: self.view)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

// MARK: - Presenterから呼び出される関数
extension FileBrowseDetailViewController {
    func initializeUI() {
        initializePDFView()
        initializeCommentTableView()
    }
    
    func success() {
        ShowStandardAlert(title: "Success", msg: "情報を更新しました", vc: self) {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func showErrorAlert(title: String, msg: String) {
        ShowStandardAlert(title: title, msg: msg, vc: self, completion: nil)
    }
}


// MARK: - インスタンス化される前に呼ばれるべき関数
extension FileBrowseDetailViewController {
    func setTitle(title: String) {
        self.navigationTitle = title
    }
    
    func setTableID(id: Int) {
        self.tableID = id
    }
}

extension FileBrowseDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.getComments().count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "コメントの一覧"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = commentTableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentCell
        let comment = presenter.getComments()[indexPath.row]
        cell.setAll(username: comment.user, created: comment.created, text: comment.text)
        return cell
    }
}

extension FileBrowseDetailViewController: UIWebViewDelegate {
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        return true
    }
}
