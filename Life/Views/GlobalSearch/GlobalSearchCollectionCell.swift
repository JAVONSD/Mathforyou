//
//  SearchNewsCollectionCell.swift
//  Life
//
//  Created by 123 on 30.07.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import Hue
import Material
import SnapKit

class GlobalSearchCollectionCell: BaseCell {
    
    struct GlobalSearchCollectionCellIdentifiers {
        static let NewsCell = "NewsCell"
    }
    
    lazy var collectionView: UICollectionView = { [weak self] in
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .white
        cv.dataSource = self
        cv.delegate = self
        return cv
        }()
    
    var newsSearchArray: [NewsSearch]?

    override func setupViews() {
        setupCollectionView()
        perfomSearch()
    }
    
    fileprivate func setupCollectionView() {
        collectionView.register(SearchNewsCollectionCell.self, forCellWithReuseIdentifier: GlobalSearchCollectionCellIdentifiers.NewsCell)
        
        addCustomConstrains()
    }
    
    private func addCustomConstrains() {
        addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func perfomSearch() {
        
    }
 
}

    //MARK: - UICollectionViewDelegate
extension GlobalSearchCollectionCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}

    //MARK: - UICollectionView DataSource

extension GlobalSearchCollectionCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 30 //newsSearchArray?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GlobalSearchCollectionCellIdentifiers.NewsCell, for: indexPath) as! SearchNewsCollectionCell
        
        return cell
    }
}

extension GlobalSearchCollectionCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = (frame.size.width - 16 - 16)
        return CGSize(width: frame.size.width, height: 120)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}



























