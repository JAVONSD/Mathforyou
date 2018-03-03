//
//  TopQuestionsViewController.swift
//  Life
//
//  Created by Shyngys Kassymov on 22.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import AVFoundation
import AVKit
import IGListKit
import Material
import SnapKit

class TopQuestionsViewController: ASViewController<ASDisplayNode>, Stepper {

    private var listAdapter: ListAdapter!
    private var collectionNode: ASCollectionNode!
    private lazy var refreshCtrl = UIRefreshControl()

    private var addButton: FABButton!

    private weak var viewModel: TopQuestionsViewModel?

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

        refreshFeed()
    }

    // MARK: - Actions

    @objc
    private func handleAddButton() {
        self.step.accept(AppStep.createQuestion(didAddQuestion: { [weak self] question in
            guard let `self` = self,
                let viewModel = self.viewModel else { return }
            let questionsSC = self.listAdapter.sectionController(
                for: viewModel.questions
            ) as? QuestionSectionController
            questionsSC?.add(question: question)
        }))
    }

    // MARK: - Methods

    @objc
    private func refreshFeed() {
        guard let viewModel = viewModel else {
            return
        }

        let secCtrl = listAdapter.sectionController(
            for: viewModel
        ) as? RefreshingSectionControllerType
        secCtrl?.refreshContent {
            self.refreshCtrl.endRefreshing()
        }

        let answersCtrl = listAdapter.sectionController(
            for: viewModel.answers
            ) as? RefreshingSectionControllerType
        answersCtrl?.refreshContent {
            self.refreshCtrl.endRefreshing()
        }

        let questionsCtrl = listAdapter.sectionController(
            for: viewModel.questions
            ) as? RefreshingSectionControllerType
        questionsCtrl?.refreshContent {
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

    private func play(video: String) {
        let token = User.current.token ?? ""
        let headers = ["Authorization": "Bearer \(token)"]

        if let url = URL(string: "\(App.String.apiBaseUrl)/Files/\(video)") {
            let asset = AVURLAsset(
                url: url,
                options: [
                    "AVURLAssetHTTPHeaderFieldsKey": headers
                ]
            )

            let playerItem = AVPlayerItem(asset: asset)
            let player = AVPlayer(playerItem: playerItem)
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            self.present(playerViewController, animated: true) {
                playerViewController.player!.play()
            }
        }
    }

}

extension TopQuestionsViewController: ListAdapterDataSource {
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        guard let viewModel = viewModel else {
            return []
        }
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
        section.didSelectVideo = { [weak self] video in
            self?.play(video: video)
        }
        return section
    }

    private func questionsSection(_ viewModel: QuestionsViewModel) -> ListSectionController {
        let section = QuestionSectionController(viewModel: viewModel)
        section.onUnathorizedError = { [weak self] in
            guard let `self` = self else { return }
            self.onUnauthorized()
        }
        section.didSelectVideo = { [weak self] video in
            self?.play(video: video)
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
