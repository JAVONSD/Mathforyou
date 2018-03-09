//
//  AnswerFormView.swift
//  Life
//
//  Created by Shyngys Kassymov on 07.03.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import SnapKit

class AnswerFormView: UIView {

    private(set) lazy var tableView = UITableView(frame: .zero, style: .plain)
    private(set) lazy var answerView = AnswerFooterView()
    private(set) lazy var videoAnswerView = VideoAnswerFooterView()

    private(set) var isVideo = false

    init(isVideo: Bool) {
        self.isVideo = isVideo

        super.init(frame: .zero)

        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI

    private func setupUI() {
        setupTableView()
        setupFooterView()
    }

    private func setupTableView() {
        tableView.tableHeaderView = UIView(frame: .init(
            x: 0,
            y: 0,
            width: 1,
            height: 0.001)
        )
        tableView.backgroundView = nil
        tableView.backgroundColor = UIColor.white
        tableView.contentInset = .zero
        tableView.separatorColor = .clear
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 50

        addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }

        tableView.register(
            CheckboxCell.self,
            forCellReuseIdentifier: App.CellIdentifier.checkboxCellId
        )
    }

    private func setupFooterView() {
        if isVideo {
            tableView.setAndLayoutTableHeaderView(header: videoAnswerView)
        } else {
            tableView.setAndLayoutTableHeaderView(header: answerView)
        }
    }

}

extension AnswerFormView: UITableViewDelegate {
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

extension UITableView {
    func setAndLayoutTableHeaderView(header: UIView) {
        self.tableHeaderView = header
        header.setNeedsLayout()
        header.layoutIfNeeded()
        header.frame.size = header.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
        self.tableHeaderView = header
    }
}
