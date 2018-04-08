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

    var didUpdateContents: (() -> Void)?

    var didTapNews: ((String) -> Void)?
    var didTapSuggestion: ((String) -> Void)?
    var didTapQuestionnaire: ((String) -> Void)?

    var didFinishLoad: (() -> Void)?

    var didTapShare: ((Lenta) -> Void)?

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
            } else if news.item.entityType.code == .questionnaire,
                let didTapQuestionnaire = didTapQuestionnaire {
                didTapQuestionnaire(news.item.id)
            }
        } else if let news = items[index] as? NewsItemViewModel,
            let didTapNews = didTapNews {
            didTapNews(news.news.id)
        } else if let suggestion = items[index] as? SuggestionItemViewModel,
            let didTapSuggestion = didTapSuggestion {
            didTapSuggestion(suggestion.suggestion.id)
        } else if let questionnaire = items[index] as? QuestionnaireViewModel,
            let didTapQuestionnaire = didTapQuestionnaire {
            didTapQuestionnaire(questionnaire.questionnaire.id)
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

        didUpdateContents?()
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
    }

    private func loadQuestionnaires() {
        let questionnaires = (viewModel?.questionnairesViewModel.questionnaires ?? [])
        let items = questionnaires.map {
            LentaItemViewModel(lenta: Lenta(questionnaire: $0.questionnaire, authorIsCurrent: false))
        } as [ListDiffable]
        set(items: items, animated: false, completion: nil)
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
                cell.didTapShare = self.didTapShare
                return cell
            }
        }

        return {
            let cell = LentaOverviewCell(viewModel: viewModel)
            return cell
        }
    }

    //swiftlint:disable cyclomatic_complexity
    func beginBatchFetch(with context: ASBatchContext) {
        guard let viewModel = viewModel else {
            context.completeBatchFetching(true)
            return
        }

        DispatchQueue.main.async {
            if viewModel.currentFilter == .news {
                viewModel.newsViewModel.fetchNextPage({ [weak self] (error) in
                    self?.didUpdateContents?()

                    guard let `self` = self,
                        let viewModel = self.viewModel,
                        !viewModel.newsViewModel.loading.value else { return }

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
                    })
                })
                return
            }

            if viewModel.currentFilter == .suggestions {
                viewModel.suggestionsViewModel.fetchNextPage({ [weak self] (error) in
                    self?.didUpdateContents?()

                    guard let `self` = self,
                        let viewModel = self.viewModel,
                        !viewModel.suggestionsViewModel.loading.value else { return }

                    if let didFinishLoad = self.didFinishLoad {
                        didFinishLoad()
                    }

                    if let moyaError = error as? MoyaError,
                        moyaError.response?.statusCode == 401,
                        let onUnathorizedError = self.onUnathorizedError {
                        onUnathorizedError()
                    }

                    guard viewModel.currentFilter == .suggestions else {
                        context.completeBatchFetching(true)
                        return
                    }

                    let items = viewModel.suggestionsViewModel.suggestions.map {
                        LentaItemViewModel(lenta: Lenta(suggestion: $0.suggestion, authorIsCurrent: false))
                        } as [ListDiffable]

                    self.set(items: items, animated: false, completion: {
                        context.completeBatchFetching(true)
                    })
                })
                return
            }

            if viewModel.currentFilter == .questionnaires {
                viewModel.questionnairesViewModel.fetchNextPage({ [weak self] (error) in
                    self?.didUpdateContents?()

                    guard let `self` = self,
                        let viewModel = self.viewModel,
                        !viewModel.questionnairesViewModel.loading.value else { return }

                    if let didFinishLoad = self.didFinishLoad {
                        didFinishLoad()
                    }

                    if let moyaError = error as? MoyaError,
                        moyaError.response?.statusCode == 401,
                        let onUnathorizedError = self.onUnathorizedError {
                        onUnathorizedError()
                    }

                    guard viewModel.currentFilter == .questionnaires else {
                        context.completeBatchFetching(true)
                        return
                    }

                    let items = viewModel.questionnairesViewModel.questionnaires.map {
                        LentaItemViewModel(
                            lenta: Lenta(questionnaire: $0.questionnaire, authorIsCurrent: false)
                        )
                    } as [ListDiffable]

                    self.set(items: items, animated: false, completion: {
                        context.completeBatchFetching(true)
                    })
                })
                return
            }

            viewModel.fetchNextPage({ [weak self] (error) in
                self?.didUpdateContents?()

                guard let `self` = self,
                    let viewModel = self.viewModel,
                    !viewModel.loading.value else { return }

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
                })
            })
        }
    }
    //swiftlint:enable cyclomatic_complexity

    func shouldBatchFetch() -> Bool {
        guard let viewModel = viewModel else { return false }

        if !Connectivity.isConnectedToInternet {
            switch viewModel.currentFilter {
            case .all:
                if !viewModel.didLoadFromCache
                    && items.isEmpty {
                    return true
                }
                return false
            case .news:
                if !viewModel.newsViewModel.didLoadFromRealmCache
                    && items.isEmpty {
                    return true
                }
                return false
            case .suggestions:
                if !viewModel.suggestionsViewModel.didLoadFromCache
                    && items.isEmpty {
                    return true
                }
                return false
            case .questionnaires:
                if !viewModel.questionnairesViewModel.didLoadFromCache
                    && items.isEmpty {
                    return true
                }
                return false
            }
        }

        switch viewModel.currentFilter {
        case .all:
            return viewModel.canLoadMore
        case .news:
            return viewModel.newsViewModel.canLoadMore
        case .suggestions:
            return viewModel.suggestionsViewModel.canLoadMore
        case .questionnaires:
            return viewModel.questionnairesViewModel.canLoadMore
        }
    }
}

extension NewsSectionController: RefreshingSectionControllerType {
    func refreshContent(with completion: (() -> Void)?) {
        guard let viewModel = viewModel else {
            return
        }

        if viewModel.currentFilter == .news {
            viewModel.newsViewModel.reload { [weak self] (error) in
                self?.didUpdateContents?()

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
            viewModel.suggestionsViewModel.reload { [weak self] (error) in
                self?.didUpdateContents?()

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
            viewModel.questionnairesViewModel.reload { [weak self] (error) in
                self?.didUpdateContents?()

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
            self?.didUpdateContents?()

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
