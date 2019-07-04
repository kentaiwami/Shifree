//
//  FileBrowseTopViewController.swift
//  Shifree
//
//  Created by 岩見建汰 on 2018/07/01.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import UIKit

protocol FileBrowseTopViewInterface: class {
    func initializeUI()
    func updateView()
    func showErrorAlert(title: String, msg: String)
}


class FileBrowseTopViewController: UIViewController, FileBrowseTopViewInterface {
    
    private var presenter: FileBrowseTopViewPresenter!
    var collectionView = UICollectionView(frame: CGRect(), collectionViewLayout: UICollectionViewLayout())
    var refreshControll = UIRefreshControl()
    let cellId = "itemCell"
    var isFirstTime: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = FileBrowseTopViewPresenter(view: self)
        addObserver()
        presenter.setFileTable(isUpdate: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.navigationItem.title = "ファイル"
        self.tabBarController?.navigationItem.setLeftBarButton(nil, animated: true)
        self.tabBarController?.navigationItem.setRightBarButton(nil, animated: true)
        self.tabBarController?.delegate = self
        
        if isFirstTime {
            isFirstTime = false
        }else {
            presenter.setFileTable(isUpdate: true)
        }
        
        collectionView.flashScrollIndicators()
    }
    
    private func initializeCollectionView() {
        let wh = self.view.frame.width/2
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: wh, height: wh)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height), collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.white
        collectionView.register(UINib(nibName: "FileBrowseCell", bundle: nil), forCellWithReuseIdentifier: "FileBrowseCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.autoresizingMask = UIView.AutoresizingMask(rawValue: UIView.AutoresizingMask.RawValue(UInt8(UIView.AutoresizingMask.flexibleHeight.rawValue) | UInt8(UIView.AutoresizingMask.flexibleWidth.rawValue)))
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundView = getEmptyView(msg: EmptyMessage.becauseNoImportShiftFile.rawValue)
        
        collectionView.refreshControl = refreshControll
        refreshControll.addTarget(self, action: #selector(self.refresh(sender:)), for: .valueChanged)
        
        self.view.addSubview(collectionView)
        
        collectionView.backgroundView?.isHidden = presenter.isBackgroundViewHidden()
    }
    
    private func presentDetailView(tableID: Int) {
        let detailVC = FileBrowseDetailViewController(tableID: tableID)
        self.navigationController!.pushViewController(detailVC, animated: true)
    }
    
    @objc private func refresh(sender: UIRefreshControl) {
        refreshControll.beginRefreshing()
        presenter.setFileTable(isUpdate: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}



// MARK: - Presenterから呼び出される関数
extension FileBrowseTopViewController {
    func initializeUI() {
        initializeCollectionView()
    }
    
    func updateView() {
        collectionView.reloadData()
        collectionView.backgroundView?.isHidden = presenter.isBackgroundViewHidden()
        
        refreshControll.endRefreshing()
    }
    
    func showErrorAlert(title: String, msg: String) {
        showStandardAlert(title: title, msg: msg, vc: self)
    }
}



// MARK: - UICollectionView関連
extension FileBrowseTopViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FileBrowseCell", for: indexPath) as! FileBrowseCell
        let fileTable = presenter.getTable(index: indexPath.row)
        
        cell.setAll(title: fileTable.title, url: fileTable.thumbnail)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter.getTableCount()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        presentDetailView(tableID: presenter.getTable(index: indexPath.row).id)
    }
}



// MARK: - UITabBarControllerDelegate
extension FileBrowseTopViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if type(of: viewController) == FileBrowseTopViewController.self && type(of: viewController) == presenter.getPrevViewController() {
            collectionView.scroll(to: .top, animated: true)
        }
        
        presenter.setPrevViewController(value: FileBrowseTopViewController.self)
    }
}



// MARK: - Observer
extension FileBrowseTopViewController {
    func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateView(notification:)), name: .comment, object: nil)
    }
    
    @objc func updateView(notification: Notification) {
        guard let idDict = notification.object as? [String:Int] else {return}
        
        dismissViews(targetViewController: self, selectedIndex: 2)
        presentDetailView(tableID: idDict["id"]!)
    }
}
