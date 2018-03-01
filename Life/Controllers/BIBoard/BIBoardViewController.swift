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

    var viewModel: BIBoardViewModel!

    let disposeBag = DisposeBag()

    var onUnathorizedError: (() -> Void)?
    var didTapTop7: ((String) -> Void)?
    var didTapAddSuggestion: (() -> Void)?
    var didSelectNews: ((String) -> Void)?

    init() {
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

        viewModel = BIBoardViewModel()

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

        getData()
    }

    // MARK: - Methods

    private func getData() {
        viewModel.newsViewModel.getTop3News { [weak self] error in
            if let moyaError = error as? MoyaError,
                moyaError.response?.statusCode == 401 {
                self?.onUnauthorized()
            }
        }
    }

    @objc
    private func refreshFeed() {
        guard let secCtrl = listAdapter
            .sectionController(for: viewModel.suggestionsViewModel) as? RefreshingSectionControllerType else {
                return
        }

        secCtrl.refreshContent {
            self.refreshCtrl.endRefreshing()
        }
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
        return [
            viewModel.newsViewModel,
            viewModel.suggestionsViewModel,
            viewModel.questionnairesViewModel,
            viewModel.stuffViewModel,
            viewModel.topQuestionsViewModel
        ]
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
