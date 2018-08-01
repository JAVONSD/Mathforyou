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
   
    lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.dataSource = self
        tv.delegate = self
        return tv
    }()
    
    private let disposeBag = DisposeBag()
    var didTapAvatar: (() -> Void)?
    
    var collapsed = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    
    // MARK: - Setup Views
    func setupViews() {
        bind()
        setupTabItem()
        setupTableView()
    }
    
    private func setupTabItem() {
        tabItem.title = NSLocalizedString("info", comment: "").uppercased()
        tabItem.titleLabel?.font = App.Font.buttonSmall
    }
    
    func setupTableView() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        tableView.register(UserHeaderTableCell.self, forCellReuseIdentifier: UserHeaderTableCell.identifier)
        
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.register(UserFoldHeaderView.self, forHeaderFooterViewReuseIdentifier: UserFoldHeaderView.identifier)
        
        tableView.sectionHeaderHeight = 70
        tableView.separatorStyle = .none

        setHeaderView()
    }
    
    private func setHeaderView() {
        let header = UserInfoHeaderView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 200))
        tableView.tableHeaderView = header
        header.item = profile
    }

    // MARK: - Bind
    private func bind() {
        User.current.updated.asDriver().drive(onNext: { [weak self] profile in
            guard let `self` = self else { return }
            
            self.updateUI(with: profile)
        }).disposed(by: disposeBag)
    }
    
    var profile: UserProfile?
    private func updateUI(with profile: UserProfile?) {
        self.profile = profile
        print(profile)
        
        
    }
    

}

// MARK: - UITableView DataSource
extension MyInfoViewControllerTableView: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: UserHeaderTableCell.identifier, for: indexPath) as! UserHeaderTableCell
            
            cell.item = profile
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: UserHeaderTableCell.identifier, for: indexPath) as! UserHeaderTableCell
            
            cell.item = profile
            return cell
        }
    }
    
}


// MARK: - UITableView Delegate
extension MyInfoViewControllerTableView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section == 1 {
            if let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: UserFoldHeaderView.identifier) as? UserFoldHeaderView {
                
                headerView.section = section
                headerView.delegate = self
                
                headerView.contentView.backgroundColor = #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1)
                
                return headerView
            }
        }
        
        return UIView()
    }
    
}

extension MyInfoViewControllerTableView: HeaderViewDelegate {
    
    func toggleSection(header: UserFoldHeaderView, section: Int) {
        
        if collapsed == false {
            collapsed = true
        } else {
            collapsed = false
        }
        
        header.setCollapsed(collapsed: collapsed)
    }

}
































