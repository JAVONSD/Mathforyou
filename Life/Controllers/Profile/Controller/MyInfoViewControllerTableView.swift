//
//  ProfileViewController2.swift
//  Life
//
//  Created by 123 on 31.07.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import Kingfisher
import Material
import RxSwift
import RxCocoa
import SnapKit

class MyInfoViewControllerTableView: UIViewController {
    
    fileprivate let dataSource = MyInfoDataSourse()
    fileprivate var profile: UserProfile?
    fileprivate let disposeBag = DisposeBag()
    
    fileprivate var collapsed = false
    
    public var didTapAvatar: (() -> Void)?
   
    lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.dataSource = dataSource
        tv.delegate = dataSource
        return tv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindToDataSorceClousers()
        bind()
        setupViews()
    }
    
    fileprivate func bindToDataSorceClousers() {
        dataSource.reloadSections = { [weak self] (section: Int) in
             guard let `self` = self else { return }
            
            self.tableView.beginUpdates()
            self.tableView.reloadSections([section], with: .fade)
            self.tableView.endUpdates()
        }
        
        dataSource.showVCHistoryDetails = { [weak self] profile in
            guard let `self` = self else { return }
            
            let detailVC = UserEducationViewController(isEducationOrHistory: false)
            detailVC.profile = profile
            
            self.show(detailVC, sender: AnyObject.self)
        }
        
        dataSource.showVCDetails = { [weak self] profile in
            guard let `self` = self else { return }
            
            let detailVC = UserEducationViewController(isEducationOrHistory: true)
            detailVC.profile = profile
            
            self.show(detailVC, sender: AnyObject.self)
        }
    }
    
    // MARK: - Setup Views
    fileprivate func setupViews() {
        setupTabItem()
        setupTableView()
        setHeaderView()
    }
    
    fileprivate func setupTabItem() {
        tabItem.title = NSLocalizedString("данные", comment: "").uppercased()
        tabItem.titleLabel?.font = App.Font.buttonSmall
    }
    
    fileprivate func setupTableView() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        tableView.register(UserFoldHeaderView.self, forHeaderFooterViewReuseIdentifier: UserFoldHeaderView.identifier)
        
        tableView.register(UserHeaderTableCell.self, forCellReuseIdentifier: UserHeaderTableCell.identifier)
        tableView.register(UserPersonalCell.self, forCellReuseIdentifier: UserPersonalCell.identifier)

        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.contentInset = UIEdgeInsetsMake(0, 0, 100, 0)
    }
    
    fileprivate func setHeaderView() {
        let header = UserInfoHeaderFooterView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 200))
        tableView.tableHeaderView = header
        header.item = profile
    }

    // MARK: - Bind
    fileprivate func bind() {
        User.current.updated.asDriver().drive(onNext: { [weak self] profile in
            guard let `self` = self else { return }
            
            self.updateUI(with: profile)
        }).disposed(by: disposeBag)
    }
    
    private func updateUI(with profile: UserProfile?) {
        self.profile = profile
        
        
    }
    

}





