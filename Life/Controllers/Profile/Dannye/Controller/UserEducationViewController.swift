//
//  UserEducationViewController.swift
//  Life
//
//  Created by 123 on 03.08.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit

class UserEducationViewController: UIViewController {
    var educations = [Education]()
    var history = [HistoryRelocation]()
    
    var isEducationOrHistory: Bool
    
    var profile: UserProfile? {
        didSet {
            guard let profile = profile
                else { return }
            
            if isEducationOrHistory {
                educations = profile.educations
            } else if !isEducationOrHistory {
                history = profile.history
            }
            
            afterDelayOnMain(0) { [weak self] in
                guard let `self` = self else { return }
                
                self.tableView.reloadData()
            }
        }
        
    }
    
    init(isEducationOrHistory: Bool) {
        self.isEducationOrHistory = isEducationOrHistory
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.dataSource = self
        tv.delegate = self
        return tv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setupTableView()
    }
    
    fileprivate func setupTableView() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
     
        tableView.register(UserEducationCell.self, forCellReuseIdentifier: UserEducationCell.identifier)
        
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
    }
}

extension UserEducationViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isEducationOrHistory {
            if educations.count > 0 {
                return educations.count
            } else {
                return 0
            }
        } else {
            if history.count > 0 {
                return history.count
            } else {
                return 0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: UserEducationCell.identifier, for: indexPath) as? UserEducationCell {
            
            if isEducationOrHistory {
                let education = educations[indexPath.row]
                
                cell.txtLabel.text = "Вид образования"
                cell.detailLabel.text = education.educationTypeName
                
                cell.rightTxtLabel.text = "Учебное заведение"
                cell.rightDetailLabel.text = education.institutionName
                
                cell.txtLabel1.text = "Специальность"
                cell.detailLabel1.text = education.specialty
                
                cell.rightTxtLabel1.text = "Год окончания"
                cell.rightDetailLabel1.text = "\(education.graduationYear)"
                
            } else {
                let historyOne = history[indexPath.row]
             
                
                cell.txtLabel.text = "Тип"
                cell.detailLabel.text = historyOne.employmentType
                
                cell.rightTxtLabel.text = "Должность"
                cell.rightDetailLabel.text = historyOne.position
                
                cell.txtLabel1.text = "Организация"
                cell.detailLabel1.text = historyOne.organization
                
                cell.rightTxtLabel1.text = "Отдел"
                cell.rightDetailLabel1.text = historyOne.department
            }
            return cell
        }
        
        return UITableViewCell()
    }
}

extension UserEducationViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return isEducationOrHistory ? "Образование" : "Перемещения"
    }
    
}




























