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

class BIBoardViewController: ASViewController<ASCollectionNode> {

    private var listAdapter: ListAdapter!
    private var collectionNode: ASCollectionNode {
        return node
    }
    private lazy var refreshCtrl = UIRefreshControl()

    var viewModel: BIBoardViewModel

    let disposeBag = DisposeBag()

    var onUnathorizedError: (() -> Void)?
    var didTapTop7: ((String) -> Void)?
    var didTapAtSuggestion: ((String) -> Void)?
    var didTapAddSuggestion: (() -> Void)?
    var didSelectNews: ((String) -> Void)?
    var didSelectStuff: (() -> Void)?
    var didSelectEmployee: ((Employee) -> Void)?

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

        if let stuffViewModel = viewModel.stuffViewModel {
            let stuffCtrl =  listAdapter.sectionController(
                for: stuffViewModel
                ) as? RefreshingSectionControllerType
            stuffCtrl?.refreshContent(with: {
                if self.refreshCtrl.isRefreshing {
                    self.refreshCtrl.endRefreshing()
                }
            })
        }

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
        DispatchQueue.main.async {
            User.current.logout()
            if let onUnathorizedError = self.onUnathorizedError {
                onUnathorizedError()
            }
        }
    }

}

extension BIBoardViewController: ListAdapterDataSource {
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        var items = [
            viewModel.newsViewModel,
            viewModel.suggestionsViewModel,
            viewModel.questionnairesViewModel
        ] as [ListDiffable]

        if let stuffViewModel = viewModel.stuffViewModel {
            items.append(stuffViewModel)
        }
        if let topQuestionsViewModel = viewModel.topQuestionsViewModel {
            items.append(topQuestionsViewModel)
        }

        return items
    }

    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        if let viewModel = object as? NewsViewModel {
            let section = BIBoardHeaderSectionController(viewModel: viewModel)
            section.onUnathorizedError = { [weak self] in
                guard let `self` = self else { return }
                self.onUnauthorized()
            }
            section.didSelectNews = didSelectNews
            return section
        } else if let viewModel = object as? SuggestionsViewModel {
            let section = SuggestionsSectionController(viewModel: viewModel)
            section.onUnathorizedError = { [weak self] in
                guard let `self` = self else { return }
                self.onUnauthorized()
            }
            section.didTapAtSuggestion = didTapAtSuggestion
            section.didTapAddSuggestion = didTapAddSuggestion
            return section
        } else if let viewModel = object as? QuestionnairesViewModel {
            let section = QuestionnairesSectionController(viewModel: viewModel)
            section.onUnathorizedError = { [weak self] in
                guard let `self` = self else { return }
                self.onUnauthorized()
            }
            return section
        } else if let viewModel = object as? StuffViewModel {
            let section = EmployeesSectionController(viewModel: viewModel)
            section.onUnathorizedError = { [weak self] in
                guard let `self` = self else { return }
                self.onUnauthorized()
            }
            section.didSelectStuff = didSelectStuff
            section.didSelectEmployee = didSelectEmployee
            return section
        } else if let viewModel = object as? TopQuestionsViewModel {
            let section = TopQuestionsSectionController(viewModel: viewModel)
            section.onUnathorizedError = { [weak self] in
                guard let `self` = self else { return }
                self.onUnauthorized()
            }
            section.didTapTop7 = didTapTop7
            return section
        }

        return ListSectionController()
    }

    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
}
