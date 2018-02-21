//
//  BenefitsView.swift
//  Life
//
//  Created by Shyngys Kassymov on 13.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import Material
import SnapKit

class BenefitsView: UIView {

    private(set) var tableView: UITableView?

    var configureViewForHeader: ((UITableView, Int) -> UIView?)?

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI

    private func setupUI() {
        tableView = UITableView(frame: .zero, style: .grouped)

        guard let tableView = tableView else { return }

        tableView.tableHeaderView = UIView(frame: .init(
            x: 0,
            y: 0,
            width: 1,
            height: 0.001)
        )
        tableView.backgroundView = nil
        tableView.backgroundColor = App.Color.whiteSmoke
        tableView.contentInset = .init(
            top: App.Layout.itemSpacingMedium,
            left: 0,
            bottom: 0,
            right: 0
        )
        tableView.separatorColor = .clear
        tableView.separatorStyle = .none

        addSubview(tableView)
        tableView.snp.makeConstraints { [weak self] (make) in
            guard let `self` = self else { return }
            make.edges.equalTo(self)
        }

        tableView.register(
            ImageTextTableViewCell.self,
            forCellReuseIdentifier: App.CellIdentifier.fitnessBenefitsCellId
        )
        tableView.register(
            ImageTextTableViewCell.self,
            forCellReuseIdentifier: App.CellIdentifier.accBenefitsCellId
        )
        tableView.register(
            BenefitsTableViewCell.self,
            forCellReuseIdentifier: App.CellIdentifier.biClubBenefitsCellId
        )
    }

}

extension BenefitsView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == tableView.numberOfSections - 1 {
            return BenefitsTableViewCell.cellHeight
        } else if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            return 72 + App.Layout.itemSpacingMedium
        }
        return 72
    }

    func tableView(
        _ tableView: UITableView,
        editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 32
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let viewForHeaderDelegate = configureViewForHeader {
            return viewForHeaderDelegate(tableView, section)
        }
        return nil
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView(frame: .init(x: 0, y: 0, width: 1, height: 0.001))
    }
}
