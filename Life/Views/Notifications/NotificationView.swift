//
//  NotificationView.swift
//  Life
//
//  Created by Shyngys Kassymov on 17.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import SnapKit
import Material

class NotificationView: UIView {

    private(set) var headerView: NotificationHeaderView?
    private(set) var tableView: UITableView?

    var didTapCloseButton: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI

    @objc
    private func handleCloseButton() {
        if let didTapCloseButton = didTapCloseButton {
            didTapCloseButton()
        }
    }

    // MARK: - UI

    private func setupUI() {
        setupHeaderView()
        setupTableView()
    }

    private func setupHeaderView() {
        headerView = NotificationHeaderView(
            image: nil,
            title: NSLocalizedString("notifications", comment: ""),
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

    private func setupTableView() {
        tableView = UITableView(frame: .zero, style: .plain)

        guard let headerView = headerView,
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

        addSubview(tableView)
        tableView.snp.makeConstraints { [weak self] (make) in
            guard let `self` = self else { return }
            make.top.equalTo(headerView.snp.bottom)
            make.left.equalTo(self)
            make.bottom.equalTo(self)
            make.right.equalTo(self)
        }

        tableView.register(
            NotificationCell.self,
            forCellReuseIdentifier: App.CellIdentifier.notificationsCellId
        )
    }

}

extension NotificationView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }

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
