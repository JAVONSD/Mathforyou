//
//  UserMainFoldableCell.swift
//  Life
//
//  Created by 123 on 01.08.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import Kingfisher
import SnapKit

class ProfileViewModelUserMainFoldableItem: ProfileViewModelItemCollabsible {
    var profile: UserProfile
    
    
    var type: ProfileViewModelItemType {
        return .email
    }
    
    var sectionTitle: String {
        return "Email"
    }
    
    var isCollapsed = true
    
    init(profile: UserProfile) {
        self.profile = profile
    }
}

class UserMainFoldableCell: UITableViewCell {
    
    lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero)
        tv.dataSource = self
        tv.delegate = self
        return tv
    }()
    
    static var identifier: String {
        return String(describing: self)
    }
    
    let fullNameLabel: UILabel = {
        let nl = UILabel()
        nl.font = App.Font.headline
        nl.numberOfLines = 2
        return nl
    }()
    
    let jobPositionLabel: UILabel = {
        let jl = UILabel()
        jl.font = App.Font.footnote
        jl.textColor = App.Color.blackDisable
        jl.numberOfLines = 2
        return jl
    }()
    
    let pictureImageView: UIImageView = {
        let pi = UIImageView()
        pi.layer.cornerRadius = 25
        pi.layer.masksToBounds = true
        pi.contentMode = .scaleAspectFit
        pi.backgroundColor = UIColor.lightGray
        return pi
    }()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        pictureImageView.image = nil
    }
    
    var item: ProfileViewModelUserMainFoldableItem? {
        didSet {
            guard let item = item else {
                return
            }
            
            fullNameLabel.text = item.profile.fullname
            jobPositionLabel.text = item.profile.jobPosition
            
            ImageDownloader.set(
                image: "",
                employeeCode: User.current.employeeCode,
                to: self.pictureImageView,
                placeholderImage: #imageLiteral(resourceName: "ic-user"),
                size: CGSize(width: 96, height: 96)
            )
            
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupViews()
        setupTableView()
    }
    
    fileprivate func setupViews() {
        addSubview(pictureImageView)
        pictureImageView.snp.makeConstraints {
            $0.top.equalTo(self).offset(20)
            $0.left.equalTo(self).offset(20)
            $0.bottom.equalTo(self).offset(-20)
            $0.size.equalTo(CGSize(width: 96, height: 96))
        }
        
        addSubview(fullNameLabel)
        fullNameLabel.snp.makeConstraints {
            $0.top.equalTo(self).offset(20)
            $0.left.equalTo(pictureImageView.snp.right).offset(20)
            $0.right.equalTo(self).offset(-20)
        }
        
        addSubview(jobPositionLabel)
        jobPositionLabel.snp.makeConstraints {
            $0.top.equalTo(fullNameLabel.snp.bottom).offset(8)
            $0.left.equalTo(fullNameLabel.snp.left)
            $0.right.equalTo(self).offset(-20)
        }
    }
    
    func setupTableView() {
        addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        tableView.register(UserHeaderTableCell.self, forCellReuseIdentifier: UserHeaderTableCell.identifier)
        tableView.register(UserMainFoldableCell.self, forCellReuseIdentifier: UserMainFoldableCell.identifier)
        
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension UserMainFoldableCell: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UserHeaderTableCell.identifier, for: indexPath) as! UserHeaderTableCell
        
        if let profile = item?.profile {
            cell.item = ProfileViewModelAboutItem(profile: )
            cell.backgroundColor = .cyan
        }

        return cell
        
    }
}

extension UserMainFoldableCell: UITableViewDelegate {
    
}






















