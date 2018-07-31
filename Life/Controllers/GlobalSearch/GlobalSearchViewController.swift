//
//  GlobalSearchViewController.swift
//  Life
//
//  Created by 123 on 30.07.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import DZNEmptyDataSet
import Material
import Moya
import NVActivityIndicatorView
import PopupDialog
import RealmSwift
import RxSwift
import RxCocoa
import SnapKit
import Hero

class GlobalSearchViewController: UIViewController,  Stepper {
    
    struct GlobalSearchCellIdentifiers {
        static let SearchNewsCell = "SearchNewsCell"
        static let nothingFoundCell = "NothingFoundCell"
        static let loadingCell = "LoadingCell"
    }
    
    lazy var collectionView: UICollectionView = { [weak self] in
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .white
        cv.isPagingEnabled = true
        cv.dataSource = self
        cv.delegate = self
        return cv
        }()
    
    lazy var menuBar: MenuBar = {
        let mb = MenuBar()
        mb.delegate = self
        return mb
    }()
    
    let searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        
        setupViews()
    }
    
    fileprivate func setupViews() {
        setupMenuBar()
        setupCollectionView()
        setupSeachViewController()
        setupNavBarButtons()
    }
    
    fileprivate func setupMenuBar() {
        view.addSubview(menuBar)
        if #available(iOS 11.0, *) {
            menuBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        } else {
            // Fallback on earlier versions
            menuBar.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor, constant: 0).isActive = true
        }
        menuBar.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.height.equalTo(50)
        }
    }
    
    fileprivate func setupCollectionView() {
        collectionView.register(SearchNewsCollectionCell.self, forCellWithReuseIdentifier: GlobalSearchCellIdentifiers.SearchNewsCell)
        
        setupCollectionViewConstraints()
    }
    
    private func setupCollectionViewConstraints() {
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.left.right.bottom.equalToSuperview()
            $0.top.equalTo(menuBar.snp.bottom)
        }
    }
    
    fileprivate func setupSeachViewController() {
        navigationItem.titleView = searchController.searchBar
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        self.searchController.hidesNavigationBarDuringPresentation = false
        definesPresentationContext = true
        searchController.searchBar.delegate = self
        searchController.searchBar.becomeFirstResponder()
    }
    
    fileprivate func setupNavBarButtons() {
        let dismissImage = UIImage(named: "close-circle-dark")?.withRenderingMode(.alwaysOriginal)
        let dimissBarButtonItem = UIBarButtonItem(image: dismissImage, style: .plain, target: self, action: #selector(handleDismiss))

        navigationItem.rightBarButtonItems = [dimissBarButtonItem]
    }
    
    @objc
    private func handleDismiss() {
        if presentingViewController != nil {
            self.dismiss(animated: true, completion: nil)
        }
    }

}

      //MARK: - UICollectionView DataSource
extension GlobalSearchViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let identifier: String
        
        identifier = GlobalSearchCellIdentifiers.SearchNewsCell
       
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
        cell.backgroundColor = indexPath.item % 2 == 0 ? .cyan : .yellow
        
        return cell
    }
    
}

extension GlobalSearchViewController: UICollectionViewDelegate {
    
    
}

extension GlobalSearchViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: view.frame.height - 50)
    }
    
}

extension GlobalSearchViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // чтобы horizontalBarView смещалась когда свайпаем вьюшки
        menuBar.horizontalLeftAnchor?.constant = scrollView.contentOffset.x / 4
    }
}

extension GlobalSearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        performSearch()
        
    }
    
    func segmentChanged(_ sender: UISegmentedControl) {
        performSearch()
    }
    
    fileprivate func performSearch() {
        
        collectionView.reloadData()
        searchController.searchBar.resignFirstResponder()
    }
}

extension GlobalSearchViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        
    }
  
}

extension GlobalSearchViewController: MenuBarProtocol {
    
    func scrollToMenuIndex(sender: MenuBar, menuIndex: Int) {
        
        
    }
    
    
}





















