//
//  BenefitsViewController.swift
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

class BenefitsViewController: UIViewController {

    private var benefitsView: BenefitsView!
    private var benefitsViewModel = BenefitsViewModel()

    private let disposeBag = DisposeBag()

    private let dataSource =
        RxTableViewSectionedReloadDataSource<SectionModel<BenefitsSectionViewModel, BenefitViewModel>>(
        configureCell: { (_, tv, indexPath, element) in
            var cellId = App.CellIdentifier.fitnessBenefitsCellId
            if indexPath.section == 1 {
                cellId = App.CellIdentifier.accBenefitsCellId
            } else if indexPath.section == 2 {
                cellId = App.CellIdentifier.biClubBenefitsCellId

                let someCell = tv.dequeueReusableCell(withIdentifier: cellId) as? BenefitsTableViewCell
                guard let cell = someCell else {
                    return BenefitsTableViewCell(style: .default, reuseIdentifier: cellId)
                }

                cell.numberOfItems = { return element.images.count }
                cell.configureCell = { (collectionCell, indexPath) in
                    guard indexPath.row < element.images.count else {
                        return
                    }
                    let image = element.images[indexPath.row]
                    collectionCell.set(imageURL: image)
                }
                cell.didSelectItem = { indexPath in
                    print("Did select image at \(indexPath)")
                }

                return cell
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
        benefitsViewModel = BenefitsViewModel.sample()

        bind()
    }

    // MARK: - Bind

    private func bind() {
        guard let tableView = benefitsView.tableView else { return }

        let dataSource = self.dataSource

//        let sectionModels = benefitsViewModel.sections.map {
//            SectionModel(model: $0, items: $0.benefits)
//        }
        let items = PublishSubject<[
            SectionModel<BenefitsSectionViewModel, BenefitViewModel>
            ]>().asObservable()

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
            .setDelegate(benefitsView)
            .disposed(by: disposeBag)

        benefitsView.configureViewForHeader = { (tableView, section) in
            return dataSource.tableView(tableView, viewForHeaderInSection: section)
        }
    }

    // MARK: - UI

    private func configUI() {
        view.backgroundColor = App.Color.whiteSmoke

        setupTabItem()
        setupBenefitsView()
    }

    private func setupTabItem() {
        tabItem.title = NSLocalizedString("benefits", comment: "").uppercased()
        tabItem.titleLabel?.font = App.Font.buttonSmall
    }

    private func setupBenefitsView() {
        benefitsView = BenefitsView(frame: .zero)

        guard let plansView = benefitsView else { return }

        view.addSubview(plansView)
        plansView.snp.makeConstraints { [weak self] (make) in
            guard let `self` = self else { return }
            make.edges.equalTo(self.view)
        }
    }

}
