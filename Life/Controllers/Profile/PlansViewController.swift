//
//  PlansViewController.swift
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

class PlansViewController: UIViewController {

    private var plansView: PlansView!
    private var plansViewModel = PlansViewModel()

    private let disposeBag = DisposeBag()

    private let dataSource =
        RxTableViewSectionedReloadDataSource<SectionModel<PlansSectionViewModel, PlanViewModel>>(
        configureCell: { (_, tv, indexPath, element) in
            var cellId = App.CellIdentifier.kpiPlansCellId
            if indexPath.section == 1 {
                cellId = App.CellIdentifier.idpPlansCellId
            } else if indexPath.section == 2 {
                cellId = App.CellIdentifier.vacationPlansCellId
            }

            let someCell = tv.dequeueReusableCell(withIdentifier: cellId) as? ImageTextTableViewCell
            guard let cell = someCell else {
                return ImageTextTableViewCell(style: .default, reuseIdentifier: cellId)
            }

            cell.setImage(hidden: true)
            cell.setImageText(spacing: App.Layout.itemSpacingMedium)
            cell.set(title: element.title)
            cell.setTitle(font: App.Font.body)
            cell.set(subtitle: element.description)
            cell.setSubtitle(font: App.Font.caption)
            cell.setDivider(leftInset: App.Layout.sideOffset)

            let itemsCount = tv.numberOfRows(inSection: indexPath.section)
            if indexPath.row == itemsCount - 1 {
                cell.set(insets: .init(
                    top: App.Layout.itemSpacingMedium,
                    left: App.Layout.sideOffset,
                    bottom: App.Layout.itemSpacingMedium * 2,
                    right: App.Layout.sideOffset)
                )
                cell.setDivider(rightInset: App.Layout.sideOffset)
            } else {
                cell.set(insets: .init(
                    top: App.Layout.itemSpacingMedium,
                    left: App.Layout.sideOffset,
                    bottom: App.Layout.itemSpacingMedium,
                    right: App.Layout.sideOffset)
                )
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
        plansViewModel = PlansViewModel.sample()

        bind()
    }

    // MARK: - Bind

    private func bind() {
        guard let tableView = plansView.tableView else { return }

        let dataSource = self.dataSource

//        let sectionModels = plansViewModel.sections.map {
//            SectionModel(model: $0, items: $0.plans)
//        }
        let items = PublishSubject<[SectionModel<PlansSectionViewModel, PlanViewModel>]>().asObservable()

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
            .setDelegate(plansView)
            .disposed(by: disposeBag)

        plansView.configureViewForHeader = { (tableView, section) in
            return dataSource.tableView(tableView, viewForHeaderInSection: section)
        }
    }

    // MARK: - UI

    private func configUI() {
        view.backgroundColor = App.Color.whiteSmoke

        setupTabItem()
        setupPlansView()
    }

    private func setupTabItem() {
        tabItem.title = NSLocalizedString("plans", comment: "").uppercased()
        tabItem.titleLabel?.font = App.Font.buttonSmall
    }

    private func setupPlansView() {
        plansView = PlansView(frame: .zero)

        guard let plansView = plansView else { return }

        view.addSubview(plansView)
        plansView.snp.makeConstraints { [weak self] (make) in
            guard let `self` = self else { return }
            make.edges.equalTo(self.view)
        }
    }

}
