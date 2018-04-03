//
//  NewsSectionController.swift
//  Life
//
//  Created by Shyngys Kassymov on 16.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import IGListKit
import Moya

protocol RefreshingSectionControllerType {
    func refreshContent(with completion: (() -> Void)?)
}

class NewsSectionController: ASCollectionSectionController {
    private(set) weak var viewModel: LentaViewModel?

    var onUnathorizedError: (() -> Void)?

    var didTapNews: ((String) -> Void)?
    var didTapSuggestion: ((String) -> Void)?

    var didFinishLoad: (() -> Void)?

    init(viewModel: LentaViewModel) {
        self.viewModel = viewModel

        super.init()

        supplementaryViewSource = self
    }

    override func didUpdate(to object: Any) {
        viewModel = object as? LentaViewModel
        updateContents()
    }

    override func cellForItem(at index: Int) -> UICollectionViewCell {
        return ASIGListSectionControllerMethods.cellForItem(at: index, sectionController: self)
    }

    override func sizeForItem(at index: Int) -> CGSize {
        return ASIGListSectionControllerMethods.sizeForItem(at: index)
    }

    override func didSelectItem(at index: Int) {
        if let news = items[index] as? LentaItemViewModel {
            if news.item.entityType.code == .news,
                let didTapNews = didTapNews {
                didTapNews(news.item.id)
            } else if news.item.entityType.code == .suggestion,
                let didTapSuggestion = didTapSuggestion {
                didTapSuggestion(news.item.id)
            }
        } else if let news = items[index] as? NewsItemViewModel,
            let didTapNews = didTapNews {
            didTapNews(news.news.id)
        } else if let suggestion = items[index] as? SuggestionItemViewModel,
            let didTapSuggestion = didTapSuggestion {
            didTapSuggestion(suggestion.suggestion.id)
        }
    }

    public func updateContents() {
        guard let viewModel = viewModel else { return }
        switch viewModel.currentFilter {
        case .all:
            loadAll()
        case .news:
            loadNews()
        case .suggestions:
            loadSuggestions()
        case .questionnaires:
            loadQuestionnaires()
        }
    }

    private func loadAll() {
        let items = (viewModel?.items ?? []) as [ListDiffable]
        set(items: items, animated: false, completion: nil)
    }


    private func loadNews() {
        let news = (viewModel?.newsViewModel.news ?? [])
        let items = news.map {
            LentaItemViewModel(lenta: Lenta(news: $0.news, authorIsCurrent: false))
        } as [ListDiffable]
        set(items: items, animated: false, completion: nil)
    }


    private func loadSuggestions() {
        let suggestions = (viewModel?.suggestionsViewModel.suggestions ?? [])
        let items = suggestions.map {
            LentaItemViewModel(lenta: Lenta(suggestion: $0.suggestion, authorIsCurrent: false))
        } as [ListDiffable]

        set(items: items, animated: false, completion: nil)

        if items.isEmpty && !(viewModel?.suggestionsViewModel.didLoad ?? false) {
            refreshContent(with: nil)
        }
    }

    private func loadQuestionnaires() {
        let questionnaires = (viewModel?.questionnairesViewModel.questionnaires ?? [])
        let items = questionnaires.map {
            LentaItemViewModel(lenta: Lenta(questionnaire: $0.questionnaire, authorIsCurrent: false))
        } as [ListDiffable]

        set(items: items, animated: false, completion: nil)

        if items.isEmpty && !(viewModel?.questionnairesViewModel.didLoad ?? false) {
            refreshContent(with: nil)
        }
    }
}

extension NewsSectionController: ASSectionController {
    func nodeBlockForItem(at index: Int) -> ASCellNodeBlock {
        guard index < items.count,
            let viewModel = self.viewModel else {
            return {
                return ASCellNode()
            }
        }

        if let object = items[index] as? LentaItemViewModel {
            return {
                let cell = NewsCell(viewModel: object)
                return cell
            }
        }

        return {
            let cell = LentaOverviewCell(viewModel: viewModel)
            return cell
        }
    }

    func beginBatchFetch(with context: ASBatchContext) {
        guard let viewModel = viewModel,
            viewModel.currentFilter != .suggestions
                && viewModel.currentFilter != .questionnaires else {
            context.completeBatchFetching(true)
            return
        }

        DispatchQueue.main.async {
            let itemsCount = self.items.count

            if viewModel.currentFilter == .news {
                viewModel.newsViewModel.fetchNextPage({ [weak self] (error) in
                    guard let `self` = self,
                        let viewModel = self.viewModel,
                        !viewModel.newsViewModel.loading else { return }

                    if let didFinishLoad = self.didFinishLoad {
                        didFinishLoad()
                    }

                    if let moyaError = error as? MoyaError,
                        moyaError.response?.statusCode == 401,
                        let onUnathorizedError = self.onUnathorizedError {
                        onUnathorizedError()
                    }

                    guard viewModel.currentFilter == .news else {
                        context.completeBatchFetching(true)
                        return
                    }

                    let items = viewModel.newsViewModel.news.map {
                        LentaItemViewModel(lenta: Lenta(news: $0.news, authorIsCurrent: false))
                        } as [ListDiffable]

                    self.set(items: items, animated: false, completion: {
                        context.completeBatchFetching(true)

                        if itemsCount == 0 {
                            if let vc = self.viewController as? LentaViewController {
                                vc.collectionNode.reloadData()
                            }
                        }
                    })
                })
                return
            }

            viewModel.fetchNextPage({ [weak self] (error) in
                guard let `self` = self,
                    let viewModel = self.viewModel,
                    !viewModel.loading else { return }

                if let didFinishLoad = self.didFinishLoad {
                    didFinishLoad()
                }

                if let moyaError = error as? MoyaError,
                    moyaError.response?.statusCode == 401,
                    let onUnathorizedError = self.onUnathorizedError {
                    onUnathorizedError()
                }

                guard viewModel.currentFilter == .all else {
                    context.completeBatchFetching(true)
                    return
                }

                self.set(items: viewModel.items, animated: false, completion: {
                    context.completeBatchFetching(true)

                    if itemsCount == 0 {
                        if let vc = self.viewController as? LentaViewController {
                            vc.collectionNode.reloadData()
                        }
                    }
                })
            })
        }
    }

    func shouldBatchFetch() -> Bool {
        guard let viewModel = viewModel else { return false }
        switch viewModel.currentFilter {
        case .all:
            return viewModel.canLoadMore
        case .news:
            return viewModel.newsViewModel.canLoadMore
        case .suggestions:
            return false
        case .questionnaires:
            return false
        }
    }
}

extension NewsSectionController: RefreshingSectionControllerType {
    func refreshContent(with completion: (() -> Void)?) {
        guard let viewModel = viewModel else {
            return
        }

        if viewModel.currentFilter == .news {
            viewModel.newsViewModel.reload { [weak self]  (error) in
                guard let `self` = self,
                    let viewModel = self.viewModel else { return }

                if let moyaError = error as? MoyaError,
                    moyaError.response?.statusCode == 401,
                    let onUnathorizedError = self.onUnathorizedError {
                    onUnathorizedError()
                }

                guard viewModel.currentFilter == .news else {
                    return
                }

                let items = viewModel.newsViewModel.news.map {
                    LentaItemViewModel(lenta: Lenta(news: $0.news, authorIsCurrent: false))
                    } as [ListDiffable]
                self.set(items: items, animated: true, completion: completion)
            }

            return
        }

        if viewModel.currentFilter == .suggestions {
            viewModel.suggestionsViewModel.getSuggestions { [weak self]  (error) in
                guard let `self` = self,
                    let viewModel = self.viewModel else { return }

                if let moyaError = error as? MoyaError,
                    moyaError.response?.statusCode == 401,
                    let onUnathorizedError = self.onUnathorizedError {
                    onUnathorizedError()
                }

                guard viewModel.currentFilter == .suggestions else {
                    return
                }

                let items = viewModel.suggestionsViewModel.suggestions.map {
                    LentaItemViewModel(lenta: Lenta(suggestion: $0.suggestion, authorIsCurrent: false))
                    } as [ListDiffable]
                self.set(items: items, animated: true, completion: completion)
            }

            return
        }

        if viewModel.currentFilter == .questionnaires {
            viewModel.questionnairesViewModel.getQuestionnaires { [weak self]  (error) in
                guard let `self` = self,
                    let viewModel = self.viewModel else { return }

                if let moyaError = error as? MoyaError,
                    moyaError.response?.statusCode == 401,
                    let onUnathorizedError = self.onUnathorizedError {
                    onUnathorizedError()
                }

                guard viewModel.currentFilter == .questionnaires else {
                    return
                }

                let items = viewModel.questionnairesViewModel.questionnaires.map {
                    LentaItemViewModel(lenta: Lenta(questionnaire: $0.questionnaire, authorIsCurrent: false))
                    } as [ListDiffable]
                self.set(items: items, animated: true, completion: completion)
            }

            return
        }

        viewModel.reload { [weak self] (error) in
            guard let `self` = self,
                let viewModel = self.viewModel else { return }

            if let moyaError = error as? MoyaError,
                moyaError.response?.statusCode == 401,
                let onUnathorizedError = self.onUnathorizedError {
                onUnathorizedError()
            }

            guard viewModel.currentFilter == .all else {
                return
            }

            self.set(items: viewModel.items, animated: true, completion: completion)
        }
    }
}

extension NewsSectionController: ASSupplementaryNodeSource {
    func nodeBlockForSupplementaryElement(ofKind elementKind: String, at index: Int) -> ASCellNodeBlock {
        return {
            let tabNode = TabNode()
            tabNode.selectedIdx = self.viewModel?.currentFilter.rawValue ?? 0
            tabNode.didSelectTab = { [weak self] idx in
                self?.viewModel?.currentFilter = LentaViewModel.FilterType(rawValue: idx) ?? .all
                self?.updateContents()
            }
            return tabNode
        }
    }

    func sizeRangeForSupplementaryElement(ofKind elementKind: String, at index: Int) -> ASSizeRange {
        if elementKind == UICollectionElementKindSectionHeader {
            return ASSizeRangeUnconstrained
        } else {
            return ASSizeRangeZero
        }
    }
}

extension NewsSectionController: ListSupplementaryViewSource {
    func supportedElementKinds() -> [String] {
        return [UICollectionElementKindSectionHeader]
    }

    func viewForSupplementaryElement(ofKind elementKind: String, at index: Int) -> UICollectionReusableView {
        return ASIGListSupplementaryViewSourceMethods
            .viewForSupplementaryElement(
                ofKind: elementKind,
                at: index,
                sectionController: self)
    }

    func sizeForSupplementaryView(ofKind elementKind: String, at index: Int) -> CGSize {
        return ASIGListSupplementaryViewSourceMethods.sizeForSupplementaryView(ofKind: elementKind, at: index)
    }

}
