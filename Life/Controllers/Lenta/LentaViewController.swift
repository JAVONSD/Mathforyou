//
//  LentaViewController.swift
//  Life
//
//  Created by Shyngys Kassymov on 14.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import DZNEmptyDataSet
import IGListKit
import Material
import Moya
import NVActivityIndicatorView
import PopupDialog
import RealmSwift
import RxSwift
import RxCocoa
import SnapKit

class LentaViewController: ASViewController<ASDisplayNode>, FABMenuDelegate, Stepper {

    private let topInset: CGFloat = 240

    private var listAdapter: ListAdapter!
    private(set) var collectionNode: ASCollectionNode!
    private(set) lazy var spinner = NVActivityIndicatorView(
        frame: .init(x: 0, y: 0, width: 44, height: 44),
        type: .circleStrokeSpin,
        color: App.Color.azure,
        padding: 0)
    private lazy var refreshCtrl = UIRefreshControl()

    private var spinnerNode: ASDisplayNode!

    private var fabButton: FABButton!
    private var fabMenu: FABMenu!

    var viewModel: LentaViewModel!

    private var disposeBag = DisposeBag()

    private let provider = MoyaProvider<UserProfileService>(plugins: [AuthPlugin(tokenClosure: {
        return User.current.token
    })])

    init() {
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
            self.setupFABButton()
            return self.fabMenu
        }
        addNode.backgroundColor = .clear
        addNode.style.preferredSize = CGSize(width: 56, height: 56)
        node.addSubnode(addNode)

        spinnerNode = ASDisplayNode(viewBlock: { () -> UIView in
            self.spinner.startAnimating()
            return self.spinner
        })
        spinnerNode.backgroundColor = .clear
        spinnerNode.style.preferredSize = CGSize(width: 24, height: 24)
        node.addSubnode(spinnerNode)

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
            let collectionSpec = ASOverlayLayoutSpec(child: self.collectionNode, overlay: relativeSpec)

            let spinnerSpec = ASStackLayoutSpec.vertical()
            spinnerSpec.children = [self.spinnerNode]
            spinnerSpec.alignItems = .center
            spinnerSpec.justifyContent = .center

            let spinnerInsetSpect = ASInsetLayoutSpec(
                insets: .init(top: self.topInset / 2, left: 0, bottom: 0, right: 0),
                child: spinnerSpec
            )

            return ASOverlayLayoutSpec(child: collectionSpec, overlay: spinnerInsetSpect)
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
            top: topInset,
            left: 0,
            bottom: 0,
            right: 0)
        collectionNode.view.emptyDataSetSource = self
        collectionNode.view.emptyDataSetDelegate = self

        refreshCtrl = UIRefreshControl()
        refreshCtrl.addTarget(self, action: #selector(refreshFeed), for: .valueChanged)
        refreshCtrl.tintColor = App.Color.azure
        collectionNode.view.addSubview(refreshCtrl)

        do {
            let realm = try App.Realms.default()
            let employeeObjects = realm.objects(EmployeeObject.self)
            let isEmployeeCacheEmpty = employeeObjects.isEmpty

            if isEmployeeCacheEmpty {
                showHUD(title: NSLocalizedString("loading_employees", comment: ""))
            }
            viewModel.stuffViewModel.employeesViewModel.onSuccess
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { [weak self] _ in
                    self?.hideHUD()
                })
                .disposed(by: disposeBag)
            downloadEmployees()
        } catch {
            print("Failed to access the Realm database")
        }

        syncUserProfile {
            DispatchQueue.main.async { [weak self] in
                User.current.logout()
                self?.step.accept(AppStep.unauthorized)
            }
        }

        refreshFeed(onlyHeader: true)
        addObservers()
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

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Observers

    private func addObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onSelectSuggestionsTab(_:)),
            name: .selectSuggestionsTab,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onSelectQuestionnairesTab(_:)),
            name: .selectQuestionnairesTab,
            object: nil
        )

        viewModel.loading
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] loading in
                guard let `self` = self else { return }

                if self.viewModel.currentFilter == .all {
                    if self.viewModel.items.isEmpty && loading {
                        self.spinner.startAnimating()
                    } else {
                        self.spinner.stopAnimating()
                    }
                }
            })
            .disposed(by: disposeBag)

        viewModel.newsViewModel.loading
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] loading in
                guard let `self` = self else { return }

                if self.viewModel.currentFilter == .news {
                    if self.viewModel.newsViewModel.news.isEmpty, loading {
                        self.spinner.startAnimating()
                    } else {
                        self.spinner.stopAnimating()
                    }
                }
            })
            .disposed(by: disposeBag)

        viewModel.suggestionsViewModel.loading
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] loading in
                guard let `self` = self else { return }

                if self.viewModel.currentFilter == .suggestions {
                    if self.viewModel.suggestionsViewModel.suggestions.isEmpty, loading {
                        self.spinner.startAnimating()
                    } else {
                        self.spinner.stopAnimating()
                    }
                }
            })
            .disposed(by: disposeBag)

        viewModel.questionnairesViewModel.loading
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] loading in
                guard let `self` = self else { return }

                if self.viewModel.currentFilter == .questionnaires {
                    if self.viewModel.questionnairesViewModel.questionnaires.isEmpty, loading {
                        self.spinner.startAnimating()
                    } else {
                        self.spinner.stopAnimating()
                    }
                }
            })
            .disposed(by: disposeBag)
    }

    @objc
    private func onSelectSuggestionsTab(_ notification: Foundation.Notification) {
        viewModel.currentFilter = .suggestions

        let secCtrl = listAdapter
            .sectionController(
                for: viewModel
            ) as? NewsSectionController
        secCtrl?.updateContents()

        collectionNode.reloadData()
    }

    @objc
    private func onSelectQuestionnairesTab(_ notification: Foundation.Notification) {
        viewModel.currentFilter = .questionnaires

        let secCtrl = listAdapter
            .sectionController(
                for: viewModel
            ) as? NewsSectionController
        secCtrl?.updateContents()

        collectionNode.reloadData()
    }

    // MARK: - Methods

    private func syncUserProfile(onUnauthorizedError: @escaping (() -> Void)) {
        provider
            .rx
            .request(.userProfile)
            .filterSuccessfulStatusCodes()
            .subscribe { response in
                switch response {
                case .success(let json):
                    if let profile = try? JSONDecoder().decode(UserProfile.self, from: json.data) {
                        User.current.profile = profile
                        User.current.save()
                    }
                case .error(let error):
                    if let moyaError = error as? MoyaError,
                        moyaError.response?.statusCode == 401 {
                        onUnauthorizedError()
                    }
                }
            }
            .disposed(by: disposeBag)
    }

    @objc
    private func refreshFeed(onlyHeader: Bool = false) {
        let newsCtrl = listAdapter.sectionController(
            for: viewModel.newsViewModel
            ) as? RefreshingSectionControllerType
        newsCtrl?.refreshContent {
            if self.refreshCtrl.isRefreshing {
                self.refreshCtrl.endRefreshing()
            }
        }

        if onlyHeader { return }

        let secCtrl = listAdapter
            .sectionController(
                for: viewModel
            ) as? RefreshingSectionControllerType
        secCtrl?.refreshContent {
            self.refreshCtrl.endRefreshing()
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
        let addNewsItem = setupFABMenuItem(
            title: NSLocalizedString("add_news", comment: ""),
            onTap: { [weak self] in
                self?.step.accept(
                    AppStep.createNews(completion: { [weak self] (news, imageSize) in
                        guard let `self` = self else { return }

                        var lentaItem = Lenta(news: news)
                        lentaItem.imageSize = imageSize
                        self.viewModel.add(item: lentaItem)

                        let newsSC = self.listAdapter.sectionController(
                            for: self.viewModel) as? NewsSectionController
                        newsSC?.updateContents()
                    })
                )
        })
        let addSuggestionItem = setupFABMenuItem(
            title: NSLocalizedString("new_suggestion", comment: ""),
            onTap: { [weak self] in
                self?.step.accept(
                    AppStep.createSuggestion(completion: { [weak self] (suggestion, imageSize) in
                        guard let `self` = self else { return }

                        var lentaItem = Lenta(suggestion: suggestion)
                        lentaItem.imageSize = imageSize
                        self.viewModel.add(item: lentaItem)

                        let newsSC = self.listAdapter.sectionController(
                            for: self.viewModel) as? NewsSectionController
                        newsSC?.updateContents()
                    })
                )
        })

        if User.current.canCreateNews {
            fabMenu.fabMenuItems = [addNewsItem, addSuggestionItem].reversed()
        } else {
            fabMenu.fabMenuItems = [addSuggestionItem].reversed()
        }
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

    private func downloadEmployees() {
        viewModel.stuffViewModel.employeesViewModel.getEmployees()
    }

    private func onUnauthorized() {
        DispatchQueue.main.async {
            User.current.logout()
            self.step.accept(AppStep.unauthorized)
        }
    }

    private func openQuestionnaire(id: String, loadOnlyStatistics: Bool) {
        let vc = QuestionnaireViewController(questionnaireId: id, loadOnlyStatistics: loadOnlyStatistics)
        present(vc, animated: true, completion: nil)
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

extension LentaViewController: ListAdapterDataSource {
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return [
            viewModel.newsViewModel,
            viewModel
        ]
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

    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        if let viewModel = object as? NewsViewModel {
            return header(viewModel)
        }

        let section = NewsSectionController(viewModel: viewModel)
        section.didTapNews = { [weak self] id in
            guard !(self?.fabMenu.isOpened ?? false) else { return }
            self?.step.accept(AppStep.newsPicked(withId: id))
        }
        section.didTapSuggestion = { [weak self] id in
            guard !(self?.fabMenu.isOpened ?? false) else { return }
            self?.step.accept(AppStep.suggestionPicked(withId: id))
        }
        section.didTapQuestionnaire = { [weak self] id in
            guard !(self?.fabMenu.isOpened ?? false) else { return }
            let vc = QuestionnairePreviewController(questionnaireId: id)
            vc.didTapViewStatistics = { [weak self] in
                self?.openQuestionnaire(id: id, loadOnlyStatistics: true)
            }
            vc.didTapPass = { [weak self] in
                self?.openQuestionnaire(id: id, loadOnlyStatistics: false)
            }
            let popup = PopupDialog(viewController: vc)
            let containerAppearance = PopupDialogContainerView.appearance()
            containerAppearance.cornerRadius = Float(App.Layout.cornerRadius)
            self?.present(popup, animated: true, completion: nil)
        }
        section.onUnathorizedError = { [weak self] in
            self?.onUnauthorized()
        }
        section.didUpdateContents = {
            DispatchQueue.main.async { [weak self] in
                self?.collectionNode.view.reloadEmptyDataSet()
            }
        }
        return section
    }

    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
}

extension LentaViewController: DZNEmptyDataSetSource {
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        var text = ""
        switch viewModel.currentFilter {
        case .all:
            text = NSLocalizedString("no_lenta_data", comment: "")
        case .news:
            text = NSLocalizedString("no_news_data", comment: "")
        case .suggestions:
            text = NSLocalizedString("no_suggestions_data", comment: "")
        case .questionnaires:
            text = NSLocalizedString("no_questionnaires_data", comment: "")
        }

        let attText = NSMutableAttributedString(string: text)

        let allRange = NSRange(location: 0, length: attText.length)
        attText.addAttribute(.font, value: App.Font.subhead, range: allRange)
        attText.addAttribute(.foregroundColor, value: App.Color.black, range: allRange)

        return attText
    }
}

extension LentaViewController: DZNEmptyDataSetDelegate {
    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView!) -> Bool {
        switch viewModel.currentFilter {
        case .all:
            return !viewModel.loading.value
                && viewModel.didLoad
        case .news:
            return !viewModel.newsViewModel.loading.value
                && viewModel.newsViewModel.didLoad
        case .suggestions:
            return !viewModel.suggestionsViewModel.loading.value
                && viewModel.suggestionsViewModel.didLoad
        case .questionnaires:
            return !viewModel.questionnairesViewModel.loading.value
                && viewModel.questionnairesViewModel.didLoad
        }
    }

    func emptyDataSetShouldBeForced(toDisplay scrollView: UIScrollView!) -> Bool {
        switch viewModel.currentFilter {
        case .all:
            return !viewModel.loading.value
                && viewModel.didLoad
                && viewModel.items.isEmpty
        case .news:
            return !viewModel.newsViewModel.loading.value
                && viewModel.newsViewModel.didLoad
                && viewModel.newsViewModel.news.isEmpty
        case .suggestions:
            return !viewModel.suggestionsViewModel.loading.value
                && viewModel.suggestionsViewModel.didLoad
                && viewModel.suggestionsViewModel.suggestions.isEmpty
        case .questionnaires:
            return !viewModel.questionnairesViewModel.loading.value
                && viewModel.questionnairesViewModel.didLoad
                && viewModel.questionnairesViewModel.questionnaires.isEmpty
        }
    }

    func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        return topInset / 2
    }

    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView!) -> Bool {
        return true
    }
}
