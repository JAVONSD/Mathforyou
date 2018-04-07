//
//  ResultsViewController.swift
//  Life
//
//  Created by Shyngys Kassymov on 12.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import Material
import RxCocoa
import RxSwift
import SnapKit

class ResultsViewController: UIViewController {

    private var resultsView: ResultsView!
    private var resultsViewModel = ResultsViewModel()

    private let disposeBag = DisposeBag()

    private let dataSource =
        RxTableViewSectionedReloadDataSource<SectionModel<ResultsSectionViewModel, ResultViewModel>>(
        configureCell: { (_, tv, indexPath, element) in
            var cellId = App.CellIdentifier.corporateResultsCellId
            if indexPath.section == 1 {
                cellId = App.CellIdentifier.educationResultsCellId
            } else if indexPath.section == 2 {
                cellId = App.CellIdentifier.attestationResultsCellId
            }

            let someCell = tv.dequeueReusableCell(withIdentifier: cellId) as? ImageTextTableViewCell
            guard let cell = someCell else {
                return ImageTextTableViewCell(style: .default, reuseIdentifier: cellId)
            }

            cell.set(imageSize: CGSize(width: 40, height: 40))
            cell.set(imageRadius: App.Layout.cornerRadiusSmall)
            cell.set(imageURL: element.image)
            cell.setImageText(spacing: App.Layout.itemSpacingMedium)
            cell.set(title: element.title)
            cell.setTitle(font: App.Font.body)
            cell.set(subtitle: element.description)
            cell.setSubtitle(font: App.Font.caption)

            let itemsCount = tv.numberOfRows(inSection: indexPath.section)
            if indexPath.row == itemsCount - 1 {
                cell.set(insets: .init(
                    top: App.Layout.itemSpacingMedium,
                    left: App.Layout.sideOffset,
                    bottom: App.Layout.itemSpacingMedium * 2,
                    right: App.Layout.sideOffset)
                )
                cell.setDivider(leftInset: App.Layout.sideOffset)
                cell.setDivider(rightInset: App.Layout.sideOffset)
            } else {
                cell.set(insets: .init(
                    top: App.Layout.itemSpacingMedium,
                    left: App.Layout.sideOffset,
                    bottom: App.Layout.itemSpacingMedium,
                    right: App.Layout.sideOffset)
                )
                cell.setDivider(leftInset: 80)
                cell.setDivider(rightInset: 0)
            }

            return cell
        },
        viewForHeaderInSection: { (_, _, element) in
            let someHeader = HeaderView(frame: .zero)
            let title = element.model.title
            someHeader.titleLabel?.text = title
            return someHeader
        }
    )

    override func viewDidLoad() {
        super.viewDidLoad()

        configUI()

        // For debug
        resultsViewModel = ResultsViewModel.sample()

        bind()
    }

    // MARK: - Bind

    private func bind() {
        guard let tableView = resultsView.tableView else { return }

        let dataSource = self.dataSource

//        let sectionModels = resultsViewModel.sections.map {
//            SectionModel(model: $0, items: $0.results)
//        }
        let items = PublishSubject<[SectionModel<ResultsSectionViewModel, ResultViewModel>]>().asObservable()

        items
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        tableView.rx
            .itemSelected
            .map { indexPath in
                return (indexPath, dataSource[indexPath])
            }
            .subscribe(onNext: { pair in
                print("Tapped `\(pair.1)` @ \(pair.0)")
            })
            .disposed(by: disposeBag)

        tableView.rx
            .setDelegate(resultsView)
            .disposed(by: disposeBag)

        resultsView.configureViewForHeader = { (tableView, section) in
            return dataSource.tableView(tableView, viewForHeaderInSection: section)
        }
    }

    // MARK: - UI

    private func configUI() {
        view.backgroundColor = App.Color.whiteSmoke

        setupTabItem()
        setupResultsView()
    }

    private func setupTabItem() {
        tabItem.title = NSLocalizedString("results", comment: "").uppercased()
        tabItem.titleLabel?.font = App.Font.buttonSmall
    }

    private func setupResultsView() {
        resultsView = ResultsView(frame: .zero)

        guard let resultsView = resultsView else { return }

        view.addSubview(resultsView)
        resultsView.snp.makeConstraints { [weak self] (make) in
            guard let `self` = self else { return }
            make.edges.equalTo(self.view)
        }
    }

}
