//
//  SearchShiftResultsViewController.swift
//  Shifree
//
//  Created by 岩見建汰 on 2018/07/01.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import UIKit

protocol SearchShiftResultsViewInterface: class {
    func updateView()
    func showErrorAlert(title: String, msg: String)
}


class SearchShiftResultsViewController: UIViewController, SearchShiftResultsViewInterface {
    
    private var presenter: SearchShiftResultsViewPresenter!
    private var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeForm()
        initializeNavigationItem()
        self.navigationItem.title = "検索結果"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.indexPathsForSelectedRows?.forEach({
            tableView.deselectRow(at: $0, animated: true)
        })
        
        if presenter.getPrevControllerisDetailView() {
            presenter.updateData()
            presenter.setPrevControllerisDetailView(value: false)
        }
    }
    
    init(searchResults: [[String:Any]], query: [String:Int]) {
        super.init(nibName: nil, bundle: nil)
        
        presenter = SearchShiftResultsViewPresenter(view: self)
        presenter.setData(results: searchResults, query: query)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initializeForm() {
        tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        self.view.addSubview(tableView)
        
        tableView.edges(to: self.view)
    }
    
    private func initializeNavigationItem() {
        let close = UIBarButtonItem(image: UIImage(named: "close"), style: .plain, target: self, action: #selector(tapCloseButton))
        self.navigationItem.setLeftBarButton(close, animated: true)
    }
    
    @objc private func tapCloseButton() {
        self.dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}



// MARK: - Presenterからの呼び出し
extension SearchShiftResultsViewController {
    func updateView() {
        tableView.reloadData()
    }
    
    func showErrorAlert(title: String, msg: String) {
        Utility().showStandardAlert(title: title, msg: msg, vc: self)
    }
}


// MARK: - UITableViewDelegate, UITableViewDataSource
extension SearchShiftResultsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = presenter.getJoinString(index: indexPath.section)
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.lineBreakMode = .byWordWrapping
        cell.accessoryType = .disclosureIndicator
        
        if presenter.isBeforeToday(index: indexPath.section) {
            cell.textLabel?.textColor = UIColor.gray
        }else {
            cell.textLabel?.textColor = UIColor.black
        }
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return presenter.getResultsCount()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return presenter.getHeaderString(index: section)
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let headerTitle = view as? UITableViewHeaderFooterView
        var txtColor = UIColor.black
        
        if presenter.isToday(index: section) {
            txtColor = UIColor.red
        }
        
        headerTitle?.textLabel?.textColor = txtColor
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.setPrevControllerisDetailView(value: true)
        
        let detailVC = CalendarDetailViewController(
            title: presenter.getHeaderString(index: indexPath.section),
            tableViewShift: presenter.getTableViewShift(index: indexPath.section),
            memo: "",
            isFollowing: true,
            targetUserShift: TargetUserShift()
        )
        
        self.navigationController!.pushViewController(detailVC, animated: true)
    }
}
