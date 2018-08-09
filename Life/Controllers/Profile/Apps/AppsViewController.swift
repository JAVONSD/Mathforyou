//
//  AppsViewController.swift
//  Life
//
//  Created by 123 on 08.08.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import FileProvider
import RxSwift
import RxCocoa
import SnapKit
import Moya
import Moya_ModelMapper
import Material

class AppsViewController: UIViewController {
    
    var collectionView: UICollectionView!
    
    var titleStr = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
    }

    fileprivate func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(AppCollectionViewCell.self, forCellWithReuseIdentifier: AppCollectionViewCell.identifier)
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.top.equalTo(view.snp.top).offset(10)
            $0.right.equalTo(view.snp.right).offset(-10)
            $0.left.equalTo(view.snp.left).offset(10)
            $0.bottom.equalTo(view.snp.bottom).offset(-10)
        }
        
        collectionView.reloadData()
    }
}

extension AppsViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AppCollectionViewCell.identifier, for: indexPath) as! AppCollectionViewCell
        
        switch indexPath.item {
        case 0:
            cell.appImageView.image = #imageLiteral(resourceName: "ic_clients")
            cell.titleLabel.text = "BI GROUP Clients"
        case 1:
            cell.appImageView.image = #imageLiteral(resourceName: "ic_partners")
            cell.titleLabel.text = "BI GROUP Partners"
        default:
            printMine(items: "no apps")
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        var url: URL?
        if indexPath.item == 0 {
            url = URL(string: "itms-apps://itunes.apple.com/us/app/bi-group-clients/id1311182242?mt=8")
        } else if indexPath.item == 1 {
            url = URL(string: "itms-apps://itunes.apple.com/us/app/bi-group-partners/id1303499262?mt=8")
        }
        
        if let url = url, UIApplication.shared.canOpenURL(url) {
            
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else { UIApplication.shared.openURL(url) }
        }
    }
}

extension AppsViewController: UICollectionViewDelegate {

    
}

extension AppsViewController: UICollectionViewDelegateFlowLayout {
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let width = (view.frame.width - 50) / 4
//        return CGSize(width: width, height: width + 30)
//    }
    
     func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let dummyCell = AppCollectionViewCell(frame: frame)
        dummyCell.titleLabel.text = "BI GROUP Partners"
        dummyCell.layoutIfNeeded()
        
        let estimatedSize = dummyCell.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
        
        let width = (view.frame.width - 50) / 4
        return CGSize(width: width, height: estimatedSize.height)
    }
}




















