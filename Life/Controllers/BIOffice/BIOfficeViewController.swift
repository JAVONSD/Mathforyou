//
//  BIOfficeViewController.swift
//  Life
//
//  Created by Shyngys Kassymov on 14.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import IGListKit
import Material
import Moya
import RxSwift
import SnapKit

class BIOfficeViewController: ASViewController<ASDisplayNode>, Stepper, FABMenuDelegate {

    private var listAdapter: ListAdapter!
    private(set) var collectionNode: ASCollectionNode!
    private lazy var refreshCtrl = UIRefreshControl()

    private var fabButton: FABButton!
    private var fabMenu: FABMenu!

    private(set) var viewModel: BIOfficeViewModel
    private let disposeBag = DisposeBag()

    init(viewModel: BIOfficeViewModel) {
        let node = ASDisplayNode()
        self.viewModel = viewModel

        super.init(node: node)

        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = .zero
        collectionNode = ASCollectionNode(collectionViewLayout: layout)
        collectionNode.contentInset = .init(
            top: 0,
            left: 0,
            bottom: App.Layout.itemSpacingBig,
            right: 0
        )
        node.addSubnode(collectionNode)
        let addNode = ASDisplayNode { () -> UIView in
            self.setupFABButton()
            return self.fabMenu
        }
        addNode.backgroundColor = .clear
        addNode.style.preferredSize = CGSize(width: 56, height: 56)
        node.addSubnode(addNode)

        node.layoutSpecBlock = { (_, _) in
            let insetSpec = ASInsetLayoutSpec(insets: .init(
                top: 0,
                left: 0,
                bottom: 30,
                right: App.Layout.sideOffset), child: addNode)
            let relativeSpec = ASRelativeLayoutSpec(
                horizontalPosition: .end,
                verticalPosition: .end,
                sizingOption: [],
                child: insetSpec
            )
            return ASOverlayLayoutSpec(child: self.collectionNode, overlay: relativeSpec)
        }

        let updater = ListAdapterUpdater()
        listAdapter = ListAdapter(updater: updater, viewController: self, workingRangeSize: 0)
        listAdapter.dataSource = self
        listAdapter.setASDKCollectionNode(collectionNode)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionNode.view.backgroundColor = App.Color.whiteSmoke
        collectionNode.view.alwaysBounceVertical = true
        collectionNode.view.scrollIndicatorInsets = .init(
            top: 232,
            left: 0,
            bottom: 0,
            right: 0)

        refreshCtrl = UIRefreshControl()
        refreshCtrl.addTarget(self, action: #selector(refreshFeed), for: .valueChanged)
        refreshCtrl.tintColor = App.Color.azure
        collectionNode.view.addSubview(refreshCtrl)

        refreshFeed()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let tabVC = parent as? AppTabBarController {
            tabVC.didTapTab = { [weak self] idx in
                guard idx == 0, tabVC.currentTabIndex == idx else { return }
                self?.collectionNode.setContentOffset(.zero, animated: true)
            }
        }
    }

    // MARK: - Methods

    @objc
    private func refreshFeed() {
        let eventsSC = listAdapter.sectionController(
            for: viewModel.newsViewModel) as? RefreshingSectionControllerType
        eventsSC?.refreshContent {
            self.refreshCtrl.endRefreshing()
        }

        let tasksAndRequestsSC = listAdapter.sectionController(
            for: viewModel.tasksAndRequestsViewModel) as? RefreshingSectionControllerType
        tasksAndRequestsSC?.refreshContent {
            self.refreshCtrl.endRefreshing()
        }
    }

    private func onUnauthorized() {
        DispatchQueue.main.async { [weak self] in
            User.current.logout()
            self?.step.accept(AppStep.unauthorized)
        }
    }

    private func setupFABButton() {
        self.fabButton = FABButton(image: Icon.cm.add, tintColor: .white)
        self.fabButton.pulseColor = .white
        self.fabButton.backgroundColor = App.Color.azure
        self.fabButton.shadowColor = App.Color.black12
        self.fabButton.depth = Depth(offset: Offset.init(horizontal: 0, vertical: 12), opacity: 1, radius: 12)

        self.fabMenu = FABMenu()
        self.fabMenu.delegate = self
        self.fabMenu.fabButton = self.fabButton
        self.fabMenu.fabMenuItemSize = CGSize(
            width: App.Layout.itemSpacingMedium * 2,
            height: App.Layout.itemSpacingMedium * 2
        )
        self.setupFABMenuItems()
        self.fabMenu.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 56, height: 56))
        }
    }

    private func setupFABMenuItems() {
        let addTaskItem = setupFABMenuItem(
            title: NSLocalizedString("new_task", comment: ""),
            onTap: { [weak self] in
                self?.step.accept(
                    AppStep.createTask(didCreateTask: { [weak self] in
                        self?.refreshFeed()
                    })
                )
        })
        let addRequestItem = setupFABMenuItem(
            title: NSLocalizedString("new_request", comment: ""),
            onTap: { [weak self] in
                self?.step.accept(
                    AppStep.createRequest(category: .it, didCreateRequest: { [weak self] in
                        self?.refreshFeed()
                    })
                )
        })
        let addSuggestionItem = setupFABMenuItem(
            title: NSLocalizedString("new_suggestion", comment: ""),
            onTap: { [weak self] in
                self?.step.accept(AppStep.createSuggestion(completion: { [weak self] (suggestion, _) in
                    guard let `self` = self else { return }

                    self.viewModel.suggestionsViewModel.add(suggestion: suggestion)

                    let suggestionsCtrl = self.listAdapter.sectionController(
                        for: self.viewModel.suggestionsViewModel
                        ) as? SuggestionsSectionController
                    suggestionsCtrl?.updateContents()
                }))
        })

        fabMenu.fabMenuItems = [addTaskItem, addRequestItem, addSuggestionItem].reversed()
    }

    private func setupFABMenuItem(title: String, onTap: @escaping (() -> Void)) -> FABMenuItem {
        let menuItem = FABMenuItem()
        menuItem.title = title
        menuItem.titleLabel.backgroundColor = .clear
        menuItem.titleLabel.font = App.Font.body
        menuItem.titleLabel.textColor = .black
        menuItem.fabButton.image = Icon.cm.add
        menuItem.fabButton.tintColor = .white
        menuItem.fabButton.pulseColor = .white
        menuItem.fabButton.backgroundColor = App.Color.azure
        menuItem.fabButton.rx.tap.asDriver().throttle(0.5).drive(onNext: {
            onTap()

            self.fabMenuWillClose(fabMenu: self.fabMenu)
            self.fabMenu.close()

            self.collectionNode.isUserInteractionEnabled = true
        }).disposed(by: disposeBag)

        return menuItem
    }

    // MARK: - FABMenuDelegate

    func fabMenuWillOpen(fabMenu: FABMenu) {
        collectionNode.alpha = 0.15
        collectionNode.isUserInteractionEnabled = false

        fabButton.backgroundColor = App.Color.paleGreyTwo
        fabButton.image = Icon.cm.close
        fabButton.tintColor = App.Color.coolGrey
    }

    func fabMenuWillClose(fabMenu: FABMenu) {
        collectionNode.alpha = 1

        fabButton.backgroundColor = App.Color.azure
        fabButton.image = Icon.cm.add
        fabButton.tintColor = UIColor.white
    }

    func fabMenuDidClose(fabMenu: FABMenu) {
        collectionNode.isUserInteractionEnabled = true
    }

}

extension BIOfficeViewController: ListAdapterDataSource {
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return [
            viewModel.newsViewModel,
            viewModel.tasksAndRequestsViewModel,
            viewModel.suggestionsViewModel,
            viewModel.questionnairesViewModel
//            viewModel.kpiViewModel,
//            viewModel.hrViewModel,
//            viewModel.idpViewModel
        ]
    }

    private func eventsSection(_ viewModel: NewsViewModel) -> ListSectionController {
        let section = EventsSectionController(viewModel: viewModel)
        section.onUnathorizedError = { [weak self] in
            guard let `self` = self else { return }
            self.onUnauthorized()
        }
        section.didSelectNews = { [weak self] id in
            self?.step.accept(AppStep.newsPicked(withId: id))
        }
        return section
    }

    private func tasksAndRequestsSection(
        _ viewModel: TasksAndRequestsViewModel) -> ListSectionController {
        let section = TasksAndRequestsSectionController(viewModel: viewModel)
        section.onUnathorizedError = { [weak self] in
            guard let `self` = self else { return }
            self.onUnauthorized()
        }
        section.didTapOnTaskOrRequest = { index in
            print("Openning task or request ...")
        }
        section.didTapOnTasksAndRequests = { [weak self] in
            self?.step.accept(AppStep.tasksAndRequests)
        }
        section.didTapAddRequest = { [weak self] in
            let alert = UIAlertController(
                title: NSLocalizedString("choose_option", comment: ""),
                message: nil,
                preferredStyle: .actionSheet)
            alert.popoverPresentationController?.sourceView = self?.view

            let taskAction = UIAlertAction(
                title: NSLocalizedString("new_task", comment: ""),
                style: .default, handler: { [weak self] _ in
                    self?.step.accept(
                        AppStep.createTask(didCreateTask: { [weak self] in
                            self?.refreshFeed()
                        })
                    )
                }
            )
            alert.addAction(taskAction)

            let requestAction = UIAlertAction(
                title: NSLocalizedString("new_request", comment: ""),
                style: .default, handler: { [weak self] _ in
                    self?.step.accept(
                        AppStep.createRequest(category: .it, didCreateRequest: { [weak self] in
                            self?.refreshFeed()
                        })
                    )
                }
            )
            alert.addAction(requestAction)

            let cancelAction = UIAlertAction(
                title: NSLocalizedString("cancel", comment: ""),
                style: .cancel,
                handler: nil)
            alert.addAction(cancelAction)

            self?.present(alert, animated: true, completion: nil)
        }
        section.didTapViewAll = { [weak self] in
            self?.step.accept(AppStep.tasksAndRequests)
        }
        return section
    }

    private func kpiSection(_ viewModel: KPIViewModel) -> ListSectionController {
        let section = KPISectionController(viewModel: viewModel)
        section.onUnathorizedError = { [weak self] in
            guard let `self` = self else { return }
            self.onUnauthorized()
        }
        return section
    }

    private func hrSection(_ viewModel: HRViewModel) -> ListSectionController {
        let section = HRSectionController(viewModel: viewModel)
        section.onUnathorizedError = { [weak self] in
            guard let `self` = self else { return }
            self.onUnauthorized()
        }
        return section
    }

    private func idpSection(_ viewModel: IDPViewModel) -> ListSectionController {
        let section = IDPSectionController(viewModel: viewModel)
        section.onUnathorizedError = { [weak self] in
            guard let `self` = self else { return }
            self.onUnauthorized()
        }
        return section
    }

    private func suggestions(_ viewModel: SuggestionsViewModel) -> ListSectionController {
        let section = SuggestionsSectionController(viewModel: viewModel)
        section.onUnathorizedError = { [weak self] in
            guard let `self` = self else { return }
            self.onUnauthorized()
        }
        section.didTapAtSuggestion = { [weak self] id in
            self?.step.accept(AppStep.suggestionPicked(withId: id))
        }
        section.didTapAddSuggestion = { [weak self] in
            self?.step.accept(AppStep.createSuggestion(completion: { [weak self] (suggestion, _) in
                guard let `self` = self else { return }

                self.viewModel.suggestionsViewModel.add(suggestion: suggestion)

                let suggestionsCtrl = self.listAdapter.sectionController(
                    for: self.viewModel.suggestionsViewModel
                    ) as? SuggestionsSectionController
                suggestionsCtrl?.updateContents()
            }))
        }
        section.didTapViewAll = {
            self.parent?.showToast("Этот раздел еще в разработке.")
            print("View all suggestions ...")
        }
        return section
    }

    private func questionnaires(_ viewModel: QuestionnairesViewModel) -> ListSectionController {
        let section = QuestionnairesSectionController(viewModel: viewModel)
        section.onUnathorizedError = { [weak self] in
            guard let `self` = self else { return }
            self.onUnauthorized()
        }
        section.didTapViewAll = {
            self.parent?.showToast("Этот раздел еще в разработке.")
            print("View all questionnaires ...")
        }
        return section
    }

    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        switch object {
        case let viewModel as NewsViewModel:
            return eventsSection(viewModel)
        case let viewModel as TasksAndRequestsViewModel:
            return tasksAndRequestsSection(viewModel)
        case let viewModel as KPIViewModel:
            return kpiSection(viewModel)
        case let viewModel as HRViewModel:
            return hrSection(viewModel)
        case let viewModel as IDPViewModel:
            return idpSection(viewModel)
        case let viewModel as SuggestionsViewModel:
            return suggestions(viewModel)
        case let viewModel as QuestionnairesViewModel:
            return questionnaires(viewModel)
        default:
            break
        }

        return ListSectionController()
    }

    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
}
