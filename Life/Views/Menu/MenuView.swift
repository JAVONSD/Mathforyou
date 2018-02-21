//
//  MenuView.swift
//  Life
//
//  Created by Shyngys Kassymov on 17.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import DynamicColor
import Material
import SnapKit

class MenuView: UIView {

    private(set) var headerButton: ImageTextButton?
    private(set) var tableView: UITableView?

    var configureViewForHeader: ((UITableView, Int) -> UIView?)?

    override init(frame: CGRect) {
        super.init(frame: .zero)

        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI

    private func setupUI() {
        setupHeaderButton()
        setupTableView()
    }

    private func setupHeaderButton() {
        headerButton = ImageTextButton(
            image: nil,
            title: "User Name",
            subtitle: "Personal"
        )
        headerButton?.view?.imageSize = CGSize(width: 56, height: 56)
        headerButton?.view?.imageView?.backgroundColor = UIColor(hexString: "#d8d8d8")
        headerButton?.view?.stackView?.insets = .init(
            top: App.Layout.sideOffset,
            left: App.Layout.sideOffset,
            bottom: App.Layout.sideOffset,
            right: 0
        )
        headerButton?.view?.stackView?.stackView?.spacing = App.Layout.itemSpacingMedium
        headerButton?.view?.textStackView?.stackView?.spacing = App.Layout.itemSpacingSmall / 2
        headerButton?.view?.titleLabel?.font = App.Font.headline
        headerButton?.view?.subtitleLabel?.font = App.Font.caption

        let detailView = EmployeeDetailView(frame: .zero)
        detailView.label.isHidden = true
        headerButton?.view?.stackView?.stackView?.addArrangedSubview(detailView)

        guard let headerButton = headerButton else { return }

        addSubview(headerButton)
        headerButton.snp.makeConstraints { (make) in
            make.top.equalTo(self)
            make.left.equalTo(self)
            make.right.equalTo(self)
            make.height.equalTo(104)
        }
    }

    private func setupTableView() {
        tableView = UITableView(frame: .zero, style: .plain)

        guard let headerButton = headerButton,
            let tableView = tableView else { return }

        tableView.tableHeaderView = UIView(frame: .init(
            x: 0,
            y: 0,
            width: 1,
            height: 0.001)
        )
        tableView.backgroundView = nil
        tableView.backgroundColor = App.Color.whiteSmoke
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
            make.top.equalTo(headerButton.snp.bottom)
            make.left.equalTo(self)
            make.bottom.equalTo(self)
            make.right.equalTo(self)
        }

        tableView.register(
            EmployeeCell.self,
            forCellReuseIdentifier: App.CellIdentifier.menuCellId
        )
    }

}

extension MenuView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68
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
