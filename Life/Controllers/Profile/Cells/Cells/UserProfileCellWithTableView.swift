//
//  UserProfileCellWithTableView.swift
//  Life
//
//  Created by 123 on 03.08.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import Kingfisher
import SnapKit

class UserProfileCellWithTableView: UITableViewCell {
    var modelItem: ProfileViewModelItem?
    
    lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.dataSource = self
        tv.delegate = self
        tv.contentInset = UIEdgeInsetsMake(0, 0, 70, 0)
        return tv
    }()
    
    static var identifier: String {
        return String(describing: self)
    }
    
    var item: UserProfile? {
        didSet {
            guard item != nil else { return }
            tableView.reloadData()
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupViews()
    }
    
    fileprivate func setupViews() {
        setupTableView()
    }
    
    fileprivate func setupTableView() {
        addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        tableView.register(UserPersonalCell.self, forCellReuseIdentifier: UserPersonalCell.identifier)
        
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension UserProfileCellWithTableView: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return item?.educations.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: UserPersonalCell.identifier, for: indexPath) as? UserPersonalCell {
            
            let education = item?.educations[indexPath.row]
            
            if indexPath.row == 0 {
                cell.txtLabel.text =
                    NSLocalizedString("Вид образование", comment: "")
                
                cell.detailLabel.text =
                    NSLocalizedString("\(String(describing: education?.educationTypeName ?? ""))", comment: "")
                
                cell.rightTxtLabel.text =
                    NSLocalizedString("Учебное заведение", comment: "")
                cell.rightDetailLabel.text =
                    NSLocalizedString("\(String(describing: education?.institutionName ?? ""))", comment: "")
                
                cell.backgroundColor = .red
                
            } else if indexPath.row == 1 {
                cell.txtLabel.text =
                    NSLocalizedString("Специальность", comment: "")
                cell.detailLabel.text = NSLocalizedString("\(String(describing: education?.specialty ?? ""))", comment: "")
                
                cell.rightTxtLabel.text = NSLocalizedString("Год окончания", comment: "")
                
                let year = "\(education?.graduationYear ?? 0)"
                cell.rightDetailLabel.text = NSLocalizedString(year, comment: "")
                
                cell.backgroundColor = .yellow
            }
           return cell
        }
        return UITableViewCell()
    }
    
}

extension UserProfileCellWithTableView: UITableViewDelegate {
    
}






















