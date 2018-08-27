//
//  FileBrowseTopViewController.swift
//  Parjob
//
//  Created by 岩見建汰 on 2018/07/01.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import UIKit

protocol FileBrowseTopViewInterface: class {
    func initializeUI()
    func showErrorAlert(title: String, msg: String)
}


class FileBrowseTopViewController: UIViewController, FileBrowseTopViewInterface {
    
    fileprivate var presenter: FileBrowseTopViewPresenter!
    var collectionView = UICollectionView(frame: CGRect(), collectionViewLayout: UICollectionViewLayout())
    let cellId = "itemCell"
    
    fileprivate let notificationCenter = NotificationCenter.default
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = FileBrowseTopViewPresenter(view: self)
        addObserver()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.navigationItem.title = "ファイル"
        self.tabBarController?.navigationItem.setLeftBarButton(nil, animated: true)
        self.tabBarController?.navigationItem.setRightBarButton(nil, animated: true)
        
        collectionView.removeFromSuperview()
        presenter.setFileTable()
    }
    
    fileprivate func initializeCollectionView() {
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
        collectionView.autoresizingMask = UIViewAutoresizing(rawValue: UIViewAutoresizing.RawValue(UInt8(UIViewAutoresizing.flexibleHeight.rawValue) | UInt8(UIViewAutoresizing.flexibleWidth.rawValue)))
        collectionView.backgroundView = GetEmptyView(msg: EmptyMessage.becauseNoImportShiftFile.rawValue)
        self.view.addSubview(collectionView)
        
        if presenter.getTable().count == 0 {
            collectionView.backgroundView?.isHidden = false
        }else {
            collectionView.backgroundView?.isHidden = true
        }
    }
    
    fileprivate func presentDetailView(tableID: Int) {
        let detailVC = FileBrowseDetailViewController()
        detailVC.setTableID(id: tableID)
        self.navigationController!.pushViewController(detailVC, animated: true)
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
    
    func showErrorAlert(title: String, msg: String) {
        ShowStandardAlert(title: title, msg: msg, vc: self, completion: nil)
    }
}



// MARK: - UICollectionView関連
extension FileBrowseTopViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FileBrowseCell", for: indexPath) as! FileBrowseCell
        cell.setAll(title: presenter.getTable()[indexPath.row].title, url: presenter.getTable()[indexPath.row].thumbnail)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter.getTable().count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        presentDetailView(tableID: presenter.getTable()[indexPath.row].id)        
    }
}


extension FileBrowseTopViewController {
    func addObserver() {
        notificationCenter.addObserver(self, selector: #selector(updateView(notification:)), name: .comment, object: nil)
    }
    
    @objc func updateView(notification: Notification) {
        guard let idDict = notification.object as? [String:Int] else {return}
        
        DismissViews(targetViewController: self, selectedIndex: 2)
        presentDetailView(tableID: idDict["id"]!)
    }
}
