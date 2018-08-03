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
    var showVCDetails: ( (_ profile: UserProfile) -> Void )?
    
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
        
        if let profile = profile {
            let headerItem = ProfileViewModeHeaderItem()
            items.append(headerItem)
            
            let personalItem = ProfileViewModelPersonalItem()
            items.append(personalItem)
            
            let workActivities = ProfileViewModelWorkActivitiesItem()
            items.append(workActivities)
            
            let medicalItem = ProfileViewModelMedicalItem()
            items.append(medicalItem)
            
            let educationItem = ProfileViewModelEducationItem(profile: profile)
            items.append(educationItem)
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
        case .nameAndPicture:
            if let cell = tableView.dequeueReusableCell(withIdentifier: UserHeaderTableCell.identifier, for: indexPath) as? UserHeaderTableCell {
                cell.item = profile
                cell.modelItem = modelItem
                
                if indexPath.row == 0 {
                    cell.pictureImageView.image = #imageLiteral(resourceName: "domain").withRenderingMode(.alwaysTemplate)
                    cell.companyLabel.text = profile?.company
                } else if indexPath.row == 1 {
                    cell.pictureImageView.image = #imageLiteral(resourceName: "mobile").withRenderingMode(.alwaysTemplate)
                    cell.companyLabel.text = profile?.mobilePhoneNumber
                } else if indexPath.row == 2 {
                    cell.pictureImageView.image = #imageLiteral(resourceName: "mail").withRenderingMode(.alwaysTemplate)
                    cell.companyLabel.text = profile?.email
                } else if indexPath.row == 3 {
                    cell.pictureImageView.image = #imageLiteral(resourceName: "phone-inactive").withRenderingMode(.alwaysTemplate)
                    cell.companyLabel.text = profile?.workPhoneNumber
                }
                
                return cell
            }
        case .personal:
            if let cell = tableView.dequeueReusableCell(withIdentifier: UserPersonalCell.identifier, for: indexPath) as? UserPersonalCell {
                cell.modelItem = modelItem
                
                if indexPath.row == 0 {
                    cell.txtLabel.text = NSLocalizedString("ИИН", comment: "")
                    cell.detailLabel.text = NSLocalizedString("\(String(describing: profile?.iin ?? ""))", comment: "")
                    cell.rightTxtLabel.text = NSLocalizedString("Дата рождения", comment: "")
                    cell.rightDetailLabel.text = NSLocalizedString("\(String(describing: profile?.birthDate ?? "").prettyDateStringNoSeconds())", comment: "")
                    
                } else if indexPath.row == 1 {
                    cell.txtLabel.text = NSLocalizedString("Семейное положение", comment: "")
                    cell.detailLabel.text = NSLocalizedString("\(String(describing: profile?.familyStatus ?? ""))", comment: "")
                    cell.rightTxtLabel.text = NSLocalizedString("Пол", comment: "")
                    cell.rightDetailLabel.text = NSLocalizedString("\(String(describing: profile?.gender ?? ""))", comment: "")
                    
                } else if indexPath.row == 2 {
                    cell.txtLabel.text = NSLocalizedString("Дети", comment: "")
                    cell.detailLabel.text = NSLocalizedString("\(String(describing: profile?.childrenQuantity ?? ""))", comment: "")
                    cell.rightTxtLabel.text = NSLocalizedString("Размер одежды", comment: "")
                    cell.rightDetailLabel.text = NSLocalizedString("\(String(describing: profile?.clothingSize ?? ""))", comment: "")
                }
                
                return cell
            }
        case .workexperiance:
            if let cell = tableView.dequeueReusableCell(withIdentifier: UserPersonalCell.identifier, for: indexPath) as? UserPersonalCell {
                cell.modelItem = modelItem
                
                if indexPath.row == 0 {
                    cell.txtLabel.text = NSLocalizedString("Корпоративный стаж (мес)", comment: "")
                    cell.detailLabel.text = NSLocalizedString("\(String(describing: profile?.corporateExperience ?? ""))", comment: "")
                    cell.rightTxtLabel.text = NSLocalizedString("Общий стаж в ГК BI Group (мес)", comment: "")
                    cell.rightDetailLabel.text = NSLocalizedString("\(String(describing: profile?.totalExperience ?? ""))", comment: "")
                    
                } else if indexPath.row == 1 {
                    cell.txtLabel.text = NSLocalizedString("Административный руководитель", comment: "")
                    cell.detailLabel.text = NSLocalizedString("\(String(describing: profile?.administrativeChiefName ?? ""))", comment: "")
                    cell.rightTxtLabel.text = NSLocalizedString("Функциональный руководитель", comment: "")
                    cell.rightDetailLabel.text = NSLocalizedString("\(String(describing: profile?.functionalChiefName ?? ""))", comment: "")
                }
                
                return cell
            }
        case .medical:
            if let cell = tableView.dequeueReusableCell(withIdentifier: UserPersonalCell.identifier, for: indexPath) as? UserPersonalCell {
                cell.modelItem = modelItem
                                
                if indexPath.row == 0 {
                    cell.txtLabel.text = NSLocalizedString("Последнее прохождение", comment: "")
                    cell.detailLabel.text = NSLocalizedString("\(String(describing: profile?.medicalExamination.last ?? "").prettyDateStringNoSeconds())", comment: "")
                    cell.rightTxtLabel.text = NSLocalizedString("Ближайшее", comment: "")
                    cell.rightDetailLabel.text = NSLocalizedString("\(String(describing: profile?.medicalExamination.next ?? "").prettyDateStringNoSeconds())", comment: "")
                }
                return cell
            }
//        case .education:
//            if let cell = tableView.dequeueReusableCell(withIdentifier: UserPersonalCell.identifier, for: indexPath) as? UserPersonalCell {
//                cell.modelItem = modelItem
//                cell.item = profile
//                return cell
//            }
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
        let modelItem = items[section]
        switch modelItem.type {
        case .nameAndPicture:
            return 0
        default:
            return 50
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let modelItem = items[indexPath.section]
        switch modelItem.type {
        case .nameAndPicture:
            return 55
        default:
            return UITableViewAutomaticDimension
        }
    }
    
}

extension MyInfoDataSourse: HeaderViewDelegate {
    func showDetails(header: UserFoldHeaderView) {
        if let showVCDetails = showVCDetails {
            showVCDetails(profile!)
        }
    }
    
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















