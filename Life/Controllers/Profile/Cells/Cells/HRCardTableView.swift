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
    func hideView(sender: HRCardTableView)
}

class HRCardTableView: UIView {
    
    weak var delegate: HRCardTableViewDelegate?
    
    open var dataSourceItems = [DataSourceItem]()
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
        prepareToolbar()
        prepareTableView()
        prepareCard()
        prepareData()
    }
}

//MARK: - Material
extension HRCardTableView {
    fileprivate func prepareToolbar() {
        toolbar = Toolbar()
        toolbar.title = "TableView Within Card"
        toolbar.detail = "Sample"
    }
    
    fileprivate func prepareTableView() {
        tableView = TableView()
        tableView.frame.size.height = 300
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TableViewCell.self, forCellReuseIdentifier: "TableViewCell")
    }
    
    fileprivate func prepareCard() {
        card = Card()
        card.depthPreset = .depth3
        card.toolbar = toolbar
        card.contentView = tableView
        layout(card).horizontally(left: 20, right: 20).center()
    }
    
    fileprivate func prepareData() {
        let persons = [["name": "Daniel"], ["name": "Sarah"]]
        for person in persons {
            dataSourceItems.append(DataSourceItem(data: person))
        }
        tableView.reloadData()
    }
}

extension HRCardTableView: TableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        delegate?.hideView(sender: self)
    }
}

extension HRCardTableView: TableViewDataSource {
    @objc
    open func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    @objc
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSourceItems.count
    }
    
    @objc
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as! TableViewCell
        
        guard let data = dataSourceItems[indexPath.row].data as? [String: String] else {
            return cell
        }
        
        cell.textLabel?.text = data["name"]
        
        return cell
    }
}
















