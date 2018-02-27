//
//  TasksAndRequetsView.swift
//  Life
//
//  Created by Shyngys Kassymov on 21.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import Material
import SnapKit

class TasksAndRequetsView: UIView, TabBarDelegate {

    private(set) var headerView: NotificationHeaderView?
    private(set) var tabBar: TabBar?
    private(set) var tableView: UITableView?

    var didTapCloseButton: (() -> Void)?
    var didTapTabItem: ((Int) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Actions

    @objc
    private func handleCloseButton() {
        if let didTapCloseButton = didTapCloseButton {
            didTapCloseButton()
        }
    }

    // MARK: - UI

    private func setupUI() {
        setupHeaderView()
        setupTabBar()
        setupTableView()
    }

    private func setupHeaderView() {
        headerView = NotificationHeaderView(
            image: nil,
            title: NSLocalizedString("tasks_and_requests", comment: ""),
            subtitle: nil
        )
        headerView?.closeButton?.addTarget(self, action: #selector(handleCloseButton), for: .touchUpInside)

        guard let headerView = headerView else { return }

        addSubview(headerView)
        headerView.snp.makeConstraints { (make) in
            make.top.equalTo(self)
            make.left.equalTo(self)
            make.right.equalTo(self)
        }
    }

    private func addSeparator(_ tabBar: TabBar) {
        let separator = UIView()
        separator.backgroundColor = App.Color.coolGrey
        tabBar.addSubview(separator)
        tabBar.sendSubview(toBack: separator)
        separator.snp.makeConstraints { (make) in
            make.height.equalTo(0.5)
            make.left.equalTo(tabBar)
            make.bottom.equalTo(tabBar)
            make.right.equalTo(tabBar)
        }
    }

    private func addTabItems(_ tabBar: TabBar) {
        let inboxTabItem = TabItem(
            title: NSLocalizedString("inbox", comment: "").uppercased(),
            titleColor: UIColor.black
        )
        inboxTabItem.tag = 0
        inboxTabItem.titleLabel?.font = App.Font.label

        let outboxTabItem = TabItem(
            title: NSLocalizedString("outbox", comment: "").uppercased(),
            titleColor: UIColor.black
        )
        outboxTabItem.tag = 1
        outboxTabItem.titleLabel?.font = App.Font.label

        tabBar.tabItems = [inboxTabItem, outboxTabItem]
    }

    private func setupTabBar() {
        tabBar = TabBar(frame: .zero)

        guard let headerView = headerView,
            let tabBar = tabBar else {
            return
        }

        tabBar.delegate = self
        tabBar.setLineColor(App.Color.azure, for: .selected)

        tabBar.setTabItemsColor(App.Color.slateGrey, for: .normal)
        tabBar.setTabItemsColor(UIColor.black, for: .selected)
        tabBar.setTabItemsColor(UIColor.black, for: .highlighted)

        tabBar.tabBarStyle = .nonScrollable
        tabBar.dividerColor = nil
        tabBar.lineHeight = 2.0
        tabBar.lineAlignment = .bottom
        tabBar.backgroundColor = App.Color.white
        tabBar.tabItemsContentEdgeInsetsPreset = .none

        addTabItems(tabBar)

        addSubview(tabBar)
        tabBar.snp.makeConstraints { (make) in
            make.top.equalTo(headerView.snp.bottom)
            make.left.equalTo(self).inset(App.Layout.sideOffset)
            make.right.equalTo(self).inset(App.Layout.sideOffset)
            make.height.equalTo(44)
        }

        addSeparator(tabBar)
    }

    private func setupTableView() {
        tableView = UITableView(frame: .zero, style: .plain)

        guard let tabBar = tabBar,
            let tableView = tableView else { return }

        tableView.tableHeaderView = UIView(frame: .init(
            x: 0,
            y: 0,
            width: 1,
            height: 0.001)
        )
        tableView.backgroundView = nil
        tableView.backgroundColor = UIColor.white
        tableView.contentInset = .init(
            top: 0,
            left: 0,
            bottom: 0,
            right: 0
        )
        tableView.separatorColor = .clear
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 72

        addSubview(tableView)
        tableView.snp.makeConstraints { [weak self] (make) in
            guard let `self` = self else { return }
            make.top.equalTo(tabBar.snp.bottom).offset(App.Layout.itemSpacingSmall)
            make.left.equalTo(self)
            make.bottom.equalTo(self)
            make.right.equalTo(self)
        }

        tableView.register(
            TRTableViewCell.self,
            forCellReuseIdentifier: App.CellIdentifier.taskOrReqeustCellId
        )
    }

    // MARK: - TabBarDelegate

    func tabBar(tabBar: TabBar, didSelect tabItem: TabItem) {
        if let didTapTabItem = didTapTabItem {
            didTapTabItem(tabItem.tag)
        }
    }

}

extension TasksAndRequetsView: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView(frame: .init(x: 0, y: 0, width: 1, height: 0.001))
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView(frame: .init(x: 0, y: 0, width: 1, height: 0.001))
    }
}
