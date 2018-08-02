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
    var isCollapsedFamily = false
    
    var items = [Bool]()
    
    var reloadSections: ( (_ section: Int) -> Void )?
    private let disposeBag = DisposeBag()
    
    var collapsed = false
    var collapsedSection = 0
    
     override init() {
        super.init()
        
        items = [isCollapsedFamily]
        
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
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        
      
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: UserHeaderTableCell.identifier, for: indexPath) as! UserHeaderTableCell
            
            cell.item = profile
            return cell
            
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: UserHeaderTableCell.identifier, for: indexPath) as! UserHeaderTableCell
            
            cell.item = profile
            return cell
        } else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: UserHeaderTableCell.identifier, for: indexPath) as! UserHeaderTableCell
            
            cell.item = profile
            return cell
        } else if indexPath.section == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: UserHeaderTableCell.identifier, for: indexPath) as! UserHeaderTableCell
            
            cell.item = profile
            return cell
        }
        return UITableViewCell()
    }
    
}

// MARK: - UITableView Delegate
extension MyInfoDataSourse: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return UIView()
        }
        if let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: UserFoldHeaderView.identifier) as? UserFoldHeaderView {
            
            headerView.section = section
            headerView.delegate = self
            headerView.setCollapsed(collapsed: collapsed, section: section)
            return headerView
        }
         return UIView()
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 00.0
        }
        return 35.0
    }
}

extension MyInfoDataSourse: HeaderViewDelegate {
    
    func toggleSection(header: UserFoldHeaderView, section: Int) {
        
        collapsedSection = section
        
        if collapsed == false {
            collapsed = true
        } else {
            collapsed = false
        }
        
        // Adjust the number of the rows inside the section
        reloadSections?(section)
    }
    
}


