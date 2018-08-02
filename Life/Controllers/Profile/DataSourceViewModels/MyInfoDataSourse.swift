//
//  MyInfoDataSourse.swift
//  Life
//
//  Created by 123 on 01.08.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import Kingfisher
import Material
import RxSwift
import RxCocoa
import SnapKit

class MyInfoDataSourse:  NSObject {
    
    var reloadSections: ( (_ section: Int) -> Void )?
    private let disposeBag = DisposeBag()
    
    // temporary
    var collapsed = false
    
     override init() {
        super.init()
        
        bind()
    }
    
    // MARK: - Bind
    fileprivate func bind() {
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
extension MyInfoDataSourse: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if collapsed && (section == 1) {
            return 0
        } else {
            return 1
        }
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
extension MyInfoDataSourse: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 {
            if let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: UserFoldHeaderView.identifier) as? UserFoldHeaderView {
                
                headerView.section = section 
                headerView.delegate = self
                headerView.setCollapsed(collapsed: collapsed)
                
                return headerView
            }
        }
        return UIView()
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            return 35.0
        }
        return 0.0
    }
}

extension MyInfoDataSourse: HeaderViewDelegate {
    
    func toggleSection(header: UserFoldHeaderView, section: Int) {
        
        if collapsed == false {
            collapsed = true
        } else {
            collapsed = false
        }
        
        // Adjust the number of the rows inside the section
        reloadSections?(section)
    }
    
}

























