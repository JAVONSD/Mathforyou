//
//  SearchNewsViewController.swift
//  Life
//
//  Created by 123 on 29.07.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import Kingfisher
import Material
import Moya
import RxSwift
import RxCocoa
import SnapKit
import Alamofire

class SearchNewsViewController: UIViewController {
    
    var onUnathorizedError: (() -> Void)?
    
    weak var viewModel: SearchNewsViewModel?
    var didSelectEmployee: ((Employee) -> Void)?
    
    private var searchNewsView: SearchNewsView!
    
    private let disposeBag = DisposeBag()
    private let dataSource =
        RxTableViewSectionedReloadDataSource<SectionModel<SearchNewsViewModel, NewsSearch>>(
            configureCell: { (_, tv, indexPath, element) in
                let cellId = App.CellIdentifier.searchNews
                
                let someCell = tv.dequeueReusableCell(withIdentifier: cellId) as? SearchNewsCell
                guard let cell = someCell else {
                    return SearchNewsCell(style: .default, reuseIdentifier: cellId)
                }
                
                cell.titleLabel.text = element.title
                cell.subtitleLabel.text = element.body
                
                cell.newsImageView.backgroundColor = .clear
                cell.newsImageView.set(
                    image: "",
                    employeeCode: "element.employee.code",
                    placeholderImage: #imageLiteral(resourceName: "ic-user"),
                    size: CGSize(width: 40, height: 40)
                )
                
                cell.accessoryButton.isHidden = true
                
                let itemsCount = tv.numberOfRows(inSection: indexPath.section)
                if indexPath.row == itemsCount - 1 {
                    cell.separatorView.isHidden = true
                } else {
                    cell.separatorView.isHidden = false
                }
                
                return cell
        },
            viewForHeaderInSection: { (_, _, _) in
                let someHeader = HeaderView(frame: .zero)
                let title = NSLocalizedString("employees", comment: "")
                someHeader.titleLabel?.font = App.Font.headline
                someHeader.titleLabel?.text = title
                someHeader.set(insets: .init(
                    top: 0,
                    left: App.Layout.sideOffset,
                    bottom: App.Layout.itemSpacingSmall,
                    right: App.Layout.sideOffset))
                return someHeader
        }
    )
    
    init(viewModel: SearchNewsViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        bind()
        
        viewModel?.searchNews(text: "")
        viewModel?.onError.observeOn(MainScheduler.instance).subscribe(onNext: { [weak self] error in
            guard let `self` = self
                else { return }
            
            if let moyaError = error as? MoyaError,
                moyaError.response?.statusCode == 401,
                let onUnathorizedError = self.onUnathorizedError {
                onUnathorizedError()
            }
        }).disposed(by: disposeBag)
        
        viewModel?.loading.asDriver().drive(onNext: { [weak self] loading in
            if loading {
                self?.searchNewsView.startLoading()
            } else {
                self?.searchNewsView.stopLoading()
            }
        }).disposed(by: disposeBag)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let tabVC = parent as? StuffViewController {
            tabVC.needScrollToTop = { [weak self] idx in
                guard idx == 0 else { return }
                self?.searchNewsView.tableView?.setContentOffset(.zero, animated: true)
            }
        }
    }
    
    
    // MARK: - Bind
    
    private func bind() {
        guard
            let tableView = searchNewsView.tableView,
            let viewModel = viewModel
            else {
                return
        }
        
        let dataSource = self.dataSource
        
        let observable = viewModel.news.asObservable()
        let items = observable.concatMap { (items) in
            return Observable.just([SectionModel(model: self.viewModel!, items: items)])
        }
        
        items
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        tableView.rx
            .itemSelected
            .map { indexPath in
                return (indexPath, dataSource[indexPath])
            }
            .subscribe(onNext: { pair in
//                if let didSelectEmployee = self.didSelectEmployee {
//                    didSelectEmployee(pair.1.employee)
//                }
            })
            .disposed(by: disposeBag)
        
        tableView.rx
            .setDelegate(searchNewsView)
            .disposed(by: disposeBag)
        
        searchNewsView.configureViewForHeader = { (tableView, section) in
            return dataSource.tableView(tableView, viewForHeaderInSection: section)
        }
    }
    
    // MARK: - UI
    
    private func setupUI() {
        view.backgroundColor = App.Color.whiteSmoke
        
        setupTabItem()
        setupSearchNewsView()
    }
    
    private func setupTabItem() {
        tabItem.title = NSLocalizedString("all", comment: "").uppercased()
        tabItem.titleLabel?.font = App.Font.buttonSmall
    }
    
    private func setupSearchNewsView() {
        searchNewsView = SearchNewsView(frame: .zero)
        searchNewsView.searchView?.didType = { [weak self] text in
            guard let `self` = self else { return }
            self.viewModel?.filter(with: text)
        }
        view.addSubview(searchNewsView)
        searchNewsView.snp.makeConstraints({ [weak self] (make) in
            guard let `self` = self else { return }
            make.top.equalTo(self.view).inset(UIEdgeInsetsMake(topHeight, 0, 0, 0))
            make.left.right.bottom.equalTo(self.view)
        })
    }
    
}








