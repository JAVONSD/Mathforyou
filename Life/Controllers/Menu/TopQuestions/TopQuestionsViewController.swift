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

class TopQuestionsViewController: ASViewController<ASDisplayNode>, Stepper, FABMenuDelegate {

    private var listAdapter: ListAdapter!
    private var collectionNode: ASCollectionNode!
    private lazy var refreshCtrl = UIRefreshControl()

    private var fabButton: FABButton!
    private var fabMenu: FABMenu!

    private unowned var viewModel: TopQuestionsViewModel

    var onUnathorizedError: (() -> Void)?

    private func addCollectionNode(_ node: ASDisplayNode) {
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
    }

    init(viewModel: TopQuestionsViewModel) {
        self.viewModel = viewModel

        let node = ASDisplayNode()
        super.init(node: node)

        addCollectionNode(node)

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

        refreshCtrl = UIRefreshControl()
        refreshCtrl.addTarget(self, action: #selector(refreshFeed), for: .valueChanged)
        refreshCtrl.tintColor = App.Color.azure
        collectionNode.view.addSubview(refreshCtrl)

        refreshFeed()
    }

    // MARK: - Methods

    @objc
    private func refreshFeed() {
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
        DispatchQueue.main.async { [weak self] in
            User.current.logout()
            self?.step.accept(AppStep.unauthorized)
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

    // MARK: - UI

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
        let addQuestionItem = setupFABMenuItem(
            title: NSLocalizedString("add_question", comment: ""),
            onTap: { [weak self] in
                self?.step.accept(AppStep.createQuestion(didAddQuestion: { [weak self] question in
                    guard let `self` = self else { return }
                    let questionsSC = self.listAdapter.sectionController(
                        for: self.viewModel.questions
                        ) as? QuestionSectionController
                    questionsSC?.add(question: question)
                }))
        })
        let addAnswerItem = setupFABMenuItem(
            title: NSLocalizedString("add_answer", comment: ""),
            onTap: { [weak self] in
                guard let `self` = self else { return }
                self.step.accept(AppStep.createAnswer(
                    questions: self.viewModel.questions.questions.map { $0.question },
                    isVideo: false,
                    didCreateAnswer: { [weak self] (answer, ids) in
                        guard let `self` = self else { return }
                        let questionsSC = self.listAdapter.sectionController(
                            for: self.viewModel.questions
                            ) as? QuestionSectionController
                        questionsSC?.add(answer: answer, to: ids)
                    })
                )
        })
        let addVideoAnswerItem = setupFABMenuItem(
            title: NSLocalizedString("add_video_answer", comment: ""),
            onTap: { [weak self] in
                guard let `self` = self else { return }
                self.step.accept(AppStep.createAnswer(
                    questions: self.viewModel.questions.questions.map { $0.question },
                    isVideo: true,
                    didCreateAnswer: { [weak self] (answer, ids) in
                        guard let `self` = self else { return }
                        let questionsSC = self.listAdapter.sectionController(
                            for: self.viewModel.questions
                            ) as? QuestionSectionController
                        questionsSC?.add(answer: answer, to: ids)
                        self.refreshFeed()
                    })
                )
        })

        fabMenu.fabMenuItems = [addQuestionItem, addAnswerItem, addVideoAnswerItem].reversed()
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
        }).disposed(by: disposeBag)

        return menuItem
    }

    // MARK: - FABMenuDelegate

    func fabMenuWillOpen(fabMenu: FABMenu) {
        collectionNode.alpha = 0.15

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
