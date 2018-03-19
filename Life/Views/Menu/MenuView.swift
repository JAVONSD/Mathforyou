//
//  MenuView.swift
//  Life
//
//  Created by Shyngys Kassymov on 17.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import Material
import RxSwift
import RxCocoa
import SnapKit

class MenuView: UIView {

    private(set) lazy var headerButton = MenuHeaderButton()
    private(set) var tableView: UITableView?

    var configureViewForHeader: ((UITableView, Int) -> UIView?)?

    let disposeBag = DisposeBag()

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
        headerButton.employeeImageView.set(
            image: "",
            employeeCode: User.current.employeeCode,
            placeholderImage: #imageLiteral(resourceName: "ic-user")
        )
        addSubview(headerButton)
        headerButton.snp.makeConstraints { (make) in
            make.top.equalTo(self)
            make.left.equalTo(self)
            make.right.equalTo(self)
        }

        User.current.updated.asDriver().drive(onNext: { [weak self] profile in
            self?.headerButton.textLabel.text = User.current.profile?.fullname
            self?.headerButton.subtitleLabel.text = User.current.profile?.jobPosition
        }).disposed(by: disposeBag)
    }

    private func setupTableView() {
        tableView = UITableView(frame: .zero, style: .plain)

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
