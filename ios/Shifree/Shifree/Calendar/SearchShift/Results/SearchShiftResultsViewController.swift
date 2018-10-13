//
//  SearchShiftResultsViewController.swift
//  Shifree
//
//  Created by 岩見建汰 on 2018/07/01.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import UIKit

protocol SearchShiftResultsViewInterface: class {}


class SearchShiftResultsViewController: UIViewController, SearchShiftResultsViewInterface {
    
    private var presenter: SearchShiftResultsViewPresenter!
    private(set) var tmpSearchResults:[[String:Any]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = SearchShiftResultsViewPresenter(view: self)
        presenter.setResults(results: tmpSearchResults)
        
        initializeForm()
        
        self.navigationItem.title = "検索結果"
        initializeNavigationItem()
    }
    
    private func initializeForm() {
        self.view.backgroundColor = UIColor.white
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


// MARK: - 遷移前にデータを格納するための関数
extension SearchShiftResultsViewController {
    func setData(results: [[String:Any]]) {
        tmpSearchResults = results
    }
}
