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

    private(set) lazy var headerView = NotificationHeaderView(
        image: nil,
        title: NSLocalizedString("add_answer", comment: ""),
        subtitle: nil
    )
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
        setupHeaderView()
        setupTableView()
        setupFooterView()
    }

    private func setupHeaderView() {
        headerView.backgroundColor = .white
        headerView.titleLabel?.text = isVideo
            ? NSLocalizedString("add_video_answer", comment: "")
            : NSLocalizedString("add_answer", comment: "")
        addSubview(headerView)
        headerView.snp.makeConstraints { (make) in
            make.top.equalTo(self)
            make.left.equalTo(self)
            make.right.equalTo(self)
        }
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
            make.top.equalTo(self.headerView.snp.bottom)
            make.left.equalTo(self)
            make.bottom.equalTo(self)
            make.right.equalTo(self)
        }

        tableView.register(
            CheckboxCell.self,
            forCellReuseIdentifier: App.CellIdentifier.checkboxCellId
        )
    }

    private func setupFooterView() {
        if isVideo {
            tableView.setAndLayoutTable(footerView: videoAnswerView)
        } else {
            tableView.setAndLayoutTable(footerView: answerView)
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
        return 30
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: .init(x: 0, y: 0, width: tableView.frame.size.width, height: 30))
        view.backgroundColor = .white

        let label = UILabel()
        label.font = App.Font.bodyAlts
        label.textColor = .black
        label.text = NSLocalizedString("choose_question_to_answer", comment: "")
        view.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.left.equalTo(view).inset(App.Layout.sideOffset)
            make.right.equalTo(view).inset(App.Layout.sideOffset)
            make.centerY.equalTo(view)
        }

        return view
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView(frame: .init(x: 0, y: 0, width: 1, height: 0.001))
    }
}

extension UITableView {
    func setAndLayoutTable(headerView: UIView) {
        self.tableHeaderView = headerView
        headerView.setNeedsLayout()
        headerView.layoutIfNeeded()
        headerView.frame.size = headerView.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
        self.tableHeaderView = headerView
    }

    func setAndLayoutTable(footerView: UIView) {
        self.tableFooterView = footerView
        footerView.setNeedsLayout()
        footerView.layoutIfNeeded()
        footerView.frame.size = footerView.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
        self.tableFooterView = footerView
    }
}









