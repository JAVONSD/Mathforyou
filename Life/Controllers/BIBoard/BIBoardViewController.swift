//
//  BIBoardViewController.swift
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

class BIBoardViewController: ASViewController<ASCollectionNode>, Stepper {

    private var listAdapter: ListAdapter!
    private var collectionNode: ASCollectionNode {
        return node
    }
    private lazy var refreshCtrl = UIRefreshControl()

    var viewModel: BIBoardViewModel

    let disposeBag = DisposeBag()

    init(viewModel: BIBoardViewModel) {
        self.viewModel = viewModel

        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = .zero
        let node = ASCollectionNode(collectionViewLayout: layout)
        node.contentInset = .init(
            top: 0,
            left: 0,
            bottom: App.Layout.itemSpacingBig,
            right: 0
        )

        super.init(node: node)

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
            top: 180,
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
                guard idx == 1, tabVC.currentTabIndex == idx else { return }
                self?.collectionNode.setContentOffset(.zero, animated: true)
            }
        }
    }

    // MARK: - Methods

    @objc
    private func refreshFeed() {
        let newsCtrl = listAdapter.sectionController(
            for: viewModel.newsViewModel
            ) as? RefreshingSectionControllerType
        newsCtrl?.refreshContent {
            if self.refreshCtrl.isRefreshing {
                self.refreshCtrl.endRefreshing()
            }
        }

        let suggestionsCtrl =  listAdapter.sectionController(
            for: viewModel.suggestionsViewModel
            ) as? RefreshingSectionControllerType
        suggestionsCtrl?.refreshContent(with: {
            if self.refreshCtrl.isRefreshing {
                self.refreshCtrl.endRefreshing()
            }
        })

        let questionnairesCtrl =  listAdapter.sectionController(
            for: viewModel.questionnairesViewModel
            ) as? RefreshingSectionControllerType
        questionnairesCtrl?.refreshContent(with: {
            if self.refreshCtrl.isRefreshing {
                self.refreshCtrl.endRefreshing()
            }
        })

        let topQuestionsCtrl =  listAdapter.sectionController(
            for: viewModel.topQuestionsViewModel
            ) as? RefreshingSectionControllerType
        topQuestionsCtrl?.refreshContent(with: {
            if self.refreshCtrl.isRefreshing {
                self.refreshCtrl.endRefreshing()
            }
        })
    }

    private func onUnauthorized() {
        DispatchQueue.main.async { [weak self] in
            User.current.logout()
            self?.step.accept(AppStep.unauthorized)
        }
    }

}

extension BIBoardViewController: ListAdapterDataSource {
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        let items = [
            viewModel.newsViewModel,
            viewModel.suggestionsViewModel,
            viewModel.questionnairesViewModel,
            viewModel.topQuestionsViewModel
        ] as [ListDiffable]

        return items
    }

    private func header(_ viewModel: NewsViewModel) -> ListSectionController {
        let section = BIBoardHeaderSectionController(viewModel: viewModel)
        section.onUnathorizedError = { [weak self] in
            guard let `self` = self else { return }
            self.onUnauthorized()
        }
        section.didSelectNews = { [weak self] id in
            self?.step.accept(AppStep.newsPicked(withId: id))
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
            self.parent?.showToast("Этот раздел еще в разработке. Нет дизайна.")
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
            self.parent?.showToast("Этот раздел еще в разработке. Нет дизайна.")
            print("View all questionnaires ...")
        }
        return section
    }

    private func employees(_ viewModel: StuffViewModel) -> ListSectionController {
        let section = EmployeesSectionController(viewModel: viewModel)
        section.onUnathorizedError = { [weak self] in
            guard let `self` = self else { return }
            self.onUnauthorized()
        }
        section.didSelectStuff = {
            print("Show stuff ...")
        }
        section.didSelectEmployee = { [weak self] employee in
            self?.step.accept(AppStep.employeePicked(employee: employee))
        }
        return section
    }

    private func topQuestions(_ viewModel: TopQuestionsViewModel) -> ListSectionController {
        let section = TopQuestionsSectionController(viewModel: viewModel)
        section.onUnathorizedError = { [weak self] in
            guard let `self` = self else { return }
            self.onUnauthorized()
        }
        section.didTapTop7 = { [weak self] id in
            self?.step.accept(AppStep.topQuestionPicked(withId: id))
        }
        return section
    }

    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        if let viewModel = object as? NewsViewModel {
            return header(viewModel)
        } else if let viewModel = object as? SuggestionsViewModel {
            return suggestions(viewModel)
        } else if let viewModel = object as? QuestionnairesViewModel {
            return questionnaires(viewModel)
        } else if let viewModel = object as? StuffViewModel {
            return employees(viewModel)
        } else if let viewModel = object as? TopQuestionsViewModel {
            return topQuestions(viewModel)
        }

        return ListSectionController()
    }

    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
}
