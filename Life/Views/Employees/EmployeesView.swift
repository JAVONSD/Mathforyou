//
//  EmployeesView.swift
//  Life
//
//  Created by Shyngys Kassymov on 15.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import Material
import SnapKit

class EmployeesView: UIView {

    private(set) lazy var spinner = NVActivityIndicatorView(
        frame: .init(x: 0, y: 0, width: 44, height: 44),
        type: .circleStrokeSpin,
        color: App.Color.azure,
        padding: 0)
    private(set) var tableView: UITableView?
    private(set) var searchView: SearchView?

    var configureViewForHeader: ((UITableView, Int) -> UIView?)?

    override init(frame: CGRect) {
        super.init(frame: .zero)

        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Methods

    public func startLoading() {
        spinner.isHidden = false
        spinner.startAnimating()
    }

    public func stopLoading() {
        spinner.stopAnimating()
        spinner.isHidden = true
    }

    // MARK: - UI

    private func setupUI() {
        setupSearchView()
        setupTableView()
    }

    private func setupSearchView() {
        searchView = SearchView(frame: .zero)
        searchView?.edgeInsets = .init(
            top: 20,
            left: App.Layout.itemSpacingMedium,
            bottom: 0,
            right: App.Layout.itemSpacingMedium
        )

        guard let searchView = searchView else { return }

        addSubview(searchView)
        searchView.snp.makeConstraints { (make) in
            make.top.equalTo(self)
            make.left.equalTo(self)
            make.right.equalTo(self)
            make.height.equalTo(72)
        }
    }

    private func setupTableView() {
        tableView = UITableView(frame: .zero, style: .plain)

        guard let searchView = searchView,
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
            make.top.equalTo(searchView.snp.bottom)
            make.left.equalTo(self)
            make.bottom.equalTo(self)
            make.right.equalTo(self)
        }

        tableView.register(
            EmployeeCell.self,
            forCellReuseIdentifier: App.CellIdentifier.employeeCellId
        )
        tableView.register(
            VacancyCell.self,
            forCellReuseIdentifier: App.CellIdentifier.vacancyCellId
        )

        tableView.estimatedRowHeight = 72
        tableView.rowHeight = UITableViewAutomaticDimension

        spinner.isHidden = true
        tableView.addSubview(spinner)
        spinner.snp.makeConstraints { (make) in
            guard let tableView = self.tableView else { return }

            make.size.equalTo(self.spinner.frame.size)
            make.center.equalTo(tableView)
        }
    }

}

extension EmployeesView: UITableViewDelegate {
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
        return nil
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView(frame: .init(x: 0, y: 0, width: 1, height: 0.001))
    }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? HeaderView {
            header.backgroundColor = App.Color.whiteSmoke
        }
    }
}
