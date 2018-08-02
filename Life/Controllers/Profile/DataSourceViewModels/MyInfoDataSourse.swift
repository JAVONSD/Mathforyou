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
    var items = [ProfileViewModelItem]()

  
    var reloadSections: ( (_ section: Int) -> Void )?
    private let disposeBag = DisposeBag()

    
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
        
        if profile != nil {
            let personalItem = ProfileViewModelPersonalItem()
            items.append(personalItem)
           
        }
    }
    
}

// MARK: - UITableView DataSource
extension MyInfoDataSourse: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let item = items[section]
        guard item.isCollapsible else {
            return item.rowCount
        }
        
        // when the section is collapsed, we will set its row count to zero
        if item.isCollapsed {
            return 0
        } else {
            return item.rowCount
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let modelItem = items[indexPath.section]
        switch modelItem.type {
        case .personal:
            if let cell = tableView.dequeueReusableCell(withIdentifier: UserPersonalCell.identifier, for: indexPath) as? UserPersonalCell {
                cell.item = profile
                cell.modelItem = modelItem
                return cell
            }
        default:
           return UITableViewCell()
        }
        return UITableViewCell()
    }
    
}

// MARK: - UITableView Delegate
extension MyInfoDataSourse: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: UserFoldHeaderView.identifier) as? UserFoldHeaderView {
            let modelItem = items[section]
            
            headerView.modelItem = modelItem
            headerView.section = section
            headerView.delegate = self
            
            return headerView
        }
        return UIView()
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        if section == 0 {
//            return 00.0
//        }
        return 35.0
    }
}

extension MyInfoDataSourse: HeaderViewDelegate {
    
    func toggleSection(header: UserFoldHeaderView, section: Int) {
        var item = items[section]
        if item.isCollapsible {
            
            // Toggle collapse
            let collapsed = !item.isCollapsed
            item.isCollapsed = collapsed
            header.setCollapsed(collapsed: collapsed)
            
            // Adjust the number of the rows inside the section
            DispatchQueue.main.async { [weak self] in
                if let reloadSections = self?.reloadSections {
                    reloadSections(section)
                }
            }
        }
        
    }
    
}















