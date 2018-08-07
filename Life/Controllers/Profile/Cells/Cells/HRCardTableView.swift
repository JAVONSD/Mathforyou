//
//  HRCardTableView.swift
//  Life
//
//  Created by 123 on 07.08.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import Material

protocol HRCardTableViewDelegate: class {
    func hideView(sender: HRCardTableView, hr: HRPerson?)
}

class HRCardTableView: UIView {
    
    weak var delegate: HRCardTableViewDelegate?
    
    open var dataSourceItems = [DataSourceItem]()
    
    open var hrPersons: [HRPerson]? {
        didSet {
            guard let hrPersons = hrPersons else { return }
            
            print(hrPersons.count)
            
            if dataSourceItems.count > 0 {
                dataSourceItems.removeAll()
            }
            
            for hr in hrPersons {
                dataSourceItems.append(DataSourceItem(data: hr))
            }
            tableView.reloadData()
        }
    }
    
    fileprivate var toolbar: Toolbar!
    fileprivate var tableView: TableView!
    fileprivate var card: Card!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .clear
        
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        prepareTableView()
        prepareToolbar()
        prepareCard()
    }
}

//MARK: - Material
extension HRCardTableView {
    fileprivate func prepareTableView() {
        tableView = TableView()
        tableView.frame.size.height = 200
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TableViewCell.self, forCellReuseIdentifier: "HRCardTableView")
    }
    
    fileprivate func prepareToolbar() {
        toolbar = Toolbar()
        toolbar.title = NSLocalizedString("Закрыть", comment: "")
        let tap = UITapGestureRecognizer(target: self, action: #selector(closeAction))
        toolbar.addGestureRecognizer(tap)
    }
    
    @objc
    func closeAction(sender: UITapGestureRecognizer) {
        delegate?.hideView(sender: self, hr: nil)
    }
    
    fileprivate func prepareCard() {
        card = Card()
        card.depthPreset = .depth3
        card.contentView = tableView
        card.bottomBar = toolbar
        self.addSubview(card)
        card.snp.makeConstraints {
            $0.top.equalTo(self.snp.top)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(300)
        }
    }

}

extension HRCardTableView: TableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        // delegate should pass picked person to textfiled
        let hrPerson = (dataSourceItems[indexPath.row]).data as! HRPerson
        delegate?.hideView(sender: self, hr: hrPerson)
    }
}

extension HRCardTableView: TableViewDataSource {
    open func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if dataSourceItems.count > 0 {
            return dataSourceItems.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HRCardTableView", for: indexPath) as! TableViewCell
        let hrPerson = (dataSourceItems[indexPath.row]).data as! HRPerson
        cell.textLabel?.text = hrPerson.fullname
        return cell
    }
}




















