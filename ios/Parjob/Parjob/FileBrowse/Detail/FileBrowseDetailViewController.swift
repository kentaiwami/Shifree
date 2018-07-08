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
    func showErrorAlert(title: String, msg: String)
}


class FileBrowseDetailViewController: UIViewController, FileBrowseDetailViewInterface {
    
    fileprivate var presenter: FileBrowseDetailViewPresenter!
    private var pdfView: UIWebView!
    fileprivate var commentTableView: UITableView!
    fileprivate var myIndiator = UIActivityIndicatorView()

    var navigationTitle: String = ""
    var tableID: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        presenter = FileBrowseDetailViewPresenter(view: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = navigationTitle
        
        presenter.setFileTableDetail()
        
        if pdfView != nil {
            pdfView.removeFromSuperview()
            commentTableView.removeFromSuperview()
        }
    }
    
    fileprivate func initializePDFView() {
        pdfView = UIWebView()
        pdfView.delegate = self
        self.view.addSubview(pdfView)
        
        pdfView.top(to: self.view)
        pdfView.left(to: self.view)
        pdfView.right(to: self.view)
        pdfView.height(self.view.frame.height/2)
        
        myIndiator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        myIndiator.center = pdfView.center
        myIndiator.hidesWhenStopped = true
        myIndiator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        pdfView.addSubview(myIndiator)
        
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
        commentTableView.rowHeight = 60
        self.view.addSubview(commentTableView)
        
        commentTableView.topToBottom(of: pdfView)
        commentTableView.left(to: self.view)
        commentTableView.right(to: self.view)
        commentTableView.bottom(to: self.view)
    }
    
    fileprivate func initializeNavigationItem() {
        let add = UIBarButtonItem(image: UIImage(named: "add"), style: .plain, target: self, action: #selector(TapAddCommentButton))
        
        self.navigationItem.setRightBarButton(add, animated: true)
    }
    
    @objc private func TapAddCommentButton(sendor: UIButton) {
        let addCommentVC = AddCommentViewController()
        addCommentVC.setTableID(id: tableID)
        let nav = UINavigationController()
        nav.viewControllers = [addCommentVC]
        nav.modalTransitionStyle = .coverVertical
        present(nav, animated: true, completion: nil)
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

// MARK: - Presenterから呼び出される関数
extension FileBrowseDetailViewController {
    func initializeUI() {
        initializeNavigationItem()
        initializePDFView()
        initializeCommentTableView()
        commentTableView.reloadData()
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
        tableView.deselectRow(at: indexPath, animated: true)
        
        if presenter.isMyComment(row: indexPath.row) {
            let editCommentVC = EditCommentViewController()
            editCommentVC.setIndexPath(at: indexPath)
            self.navigationController!.pushViewController(editCommentVC, animated: true)
        }
    }
}



// MARK: - PDFを表示するためにWebView関連
extension FileBrowseDetailViewController: UIWebViewDelegate {
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        myIndiator.startAnimating()
        return true
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        myIndiator.stopAnimating()
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        myIndiator.stopAnimating()
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}



// MARK: - EditCommentViewControllerへコメントデータを渡すための関数
extension FileBrowseDetailViewController {
    func getComment() -> [Comment] {
        return presenter.getComments()
    }
}

