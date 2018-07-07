//
//  FileBrowseTopViewController.swift
//  Parjob
//
//  Created by 岩見建汰 on 2018/07/01.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import UIKit
import PopupDialog

protocol FileBrowseTopViewInterface: class {
    func initializeUI()
    func showErrorAlert(title: String, msg: String)
}


class FileBrowseTopViewController: UIViewController, FileBrowseTopViewInterface {
    
    fileprivate var presenter: FileBrowseTopViewPresenter!
    var collectionView = UICollectionView(frame: CGRect(), collectionViewLayout: UICollectionViewLayout())
    let cellId = "itemCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = FileBrowseTopViewPresenter(view: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "File View"
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
        collectionView.register(UINib(nibName: "FileBrowseCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "FileBrowseCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.autoresizingMask = UIViewAutoresizing(rawValue: UIViewAutoresizing.RawValue(UInt8(UIViewAutoresizing.flexibleHeight.rawValue) | UInt8(UIViewAutoresizing.flexibleWidth.rawValue)))
        self.view.addSubview(collectionView)
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


extension FileBrowseTopViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FileBrowseCell", for: indexPath) as! FileBrowseCollectionViewCell
        cell.setAll(title: presenter.getTable()[indexPath.row].title, url: presenter.getTable()[indexPath.row].thumbnail)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter.getTable().count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailVC = FileBrowseDetailViewController()
        detailVC.setTitle(title: presenter.getTable()[indexPath.row].title)
        detailVC.setTableID(id: presenter.getTable()[indexPath.row].id)
        self.navigationController!.pushViewController(detailVC, animated: true)
    }
    
}
