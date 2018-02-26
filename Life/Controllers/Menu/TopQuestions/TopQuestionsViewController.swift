//
//  TopQuestionsViewController.swift
//  Life
//
//  Created by Shyngys Kassymov on 22.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import IGListKit
import Material
import SnapKit

class TopQuestionsViewController: ASViewController<ASDisplayNode>, Stepper {

    private var listAdapter: ListAdapter!
    private var collectionNode: ASCollectionNode!
    private lazy var refreshCtrl = UIRefreshControl()

    private var addButton: FABButton!

    var viewModel: TopQuestionsViewModel!

    var onUnathorizedError: (() -> Void)?

    init(viewModel: TopQuestionsViewModel) {
        self.viewModel = viewModel

        let node = ASDisplayNode()
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
            self.addButton = FABButton(image: Icon.cm.add, tintColor: .white)
            self.addButton.addTarget(self, action: #selector(self.handleAddButton), for: .touchUpInside)
            self.addButton.backgroundColor = App.Color.azure
            self.addButton.snp.makeConstraints { (make) in
                make.size.equalTo(CGSize(width: 56, height: 56))
            }
            return self.addButton
        }
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

        refreshCtrl = UIRefreshControl()
        refreshCtrl.addTarget(self, action: #selector(refreshFeed), for: .valueChanged)
        refreshCtrl.tintColor = App.Color.azure
        collectionNode.view.addSubview(refreshCtrl)
    }

    // MARK: - Actions

    @objc
    private func handleAddButton() {
        self.step.accept(AppStep.createQuestion)
    }

    // MARK: - Methods

    @objc
    private func refreshFeed() {
        guard let secCtrl = listAdapter
            .sectionController(for: viewModel.topAnswerAuthors) as? RefreshingSectionControllerType else {
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

extension TopQuestionsViewController: ListAdapterDataSource {
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return [
            viewModel,
            viewModel.answers,
            viewModel.questions
        ]
    }

    private func authorsSection(_ viewModel: TopQuestionsViewModel) -> ListSectionController {
        let section = AuthorsSectionController(viewModel: viewModel)
        section.onUnathorizedError = { [weak self] in
            guard let `self` = self else { return }
            self.onUnauthorized()
        }
        return section
    }

    private func answersSection(_ viewModel: AnswersViewModel) -> ListSectionController {
        let section = AnswersSectionController(viewModel: viewModel)
        section.onUnathorizedError = { [weak self] in
            guard let `self` = self else { return }
            self.onUnauthorized()
        }
        return section
    }

    private func questionsSection(_ viewModel: QuestionsViewModel) -> ListSectionController {
        let section = QuestionSectionController(viewModel: viewModel)
        section.onUnathorizedError = { [weak self] in
            guard let `self` = self else { return }
            self.onUnauthorized()
        }
        return section
    }

    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        switch object {
        case let viewModel as TopQuestionsViewModel:
            return authorsSection(viewModel)
        case let viewModel as AnswersViewModel:
            return answersSection(viewModel)
        case let viewModel as QuestionsViewModel:
            return questionsSection(viewModel)
        default:
            break
        }

        return ListSectionController()
    }

    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
}
