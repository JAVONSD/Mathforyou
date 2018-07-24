//
//  LentaFlow.swift
//  Life
//
//  Created by Shyngys Kassymov on 14.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit

class LentaFlow: Flow {

    var root: Presentable {
        return self.rootViewController
    }

    private var rootViewController: LentaViewController

    private unowned var notificationsViewModel: NotificationsViewModel

    init(viewController: LentaViewController,
         notificationsViewModel: NotificationsViewModel) {
        self.notificationsViewModel = notificationsViewModel
        self.rootViewController = viewController
    }

    //swiftlint:disable cyclomatic_complexity
    func navigate(to step: Step) -> NextFlowItems {
        guard let step = step as? AppStep else { return NextFlowItems.stepNotHandled }

        switch step {
        case .lenta:
            // the “navigate(to:)” function transforms Step into NextFlowItem - Rx paradigma
            return NextFlowItems.one(
                flowItem: NextFlowItem(
                    nextPresentable: rootViewController,
                    nextStepper: rootViewController
                )
            )
        case .newsPicked(let id):
            return navigationToNewsDetail(id)
        case .newsDone:
            return navigationFromNewsDetail()
        case .suggestionPicked(let id):
            return navigationToSuggestion(id)
        case .suggestionDone:
            return navigationFromSuggestion()
        case .createNews(let completion):
            return navigationToNewsForm(completion: completion)
        case .createNewsDone:
            return navigationFromNewsForm()
        case .createSuggestion(let completion):
            return navigationToSuggestionForm(completion: completion)
        case .createSuggestionDone:
            return navigationFromSuggestionForm()
        default:
            return NextFlowItems.stepNotHandled
        }
    }
    //swiftlint:enable cyclomatic_complexity

    private func navigationToNewsDetail(_ id: String) -> NextFlowItems {
        let viewController = NewsViewController(
            viewModel: NewsItemViewModel(id: id)
        )
        // side effect
        self.rootViewController.present(viewController, animated: true, completion: nil)
        
        // NextFlowItems are produced. Therefore, Presentables and Steppers are registered into the Coordinator
        return NextFlowItems.one(flowItem:
            NextFlowItem(
                nextPresentable: viewController,
                nextStepper: viewController /* Steppers emit new Steps and here we go again */ )
        )
    }

    private func navigationFromNewsDetail() -> NextFlowItems {
        self.rootViewController.presentedViewController?.dismiss(animated: true, completion: nil)
        return NextFlowItems.none
    }

    private func navigationToSuggestion( _ id: String) -> NextFlowItems {
        let viewController = SuggestionViewController(
            viewModel: SuggestionItemViewModel(id: id)
        )
        self.rootViewController.present(viewController, animated: true, completion: nil)
        return NextFlowItems.one(flowItem:
            NextFlowItem(
                nextPresentable: viewController,
                nextStepper: viewController)
        )
    }

    private func navigationFromSuggestion() -> NextFlowItems {
        self.rootViewController.presentedViewController?.dismiss(animated: true, completion: nil)
        return NextFlowItems.none
    }

    private func navigationToNewsForm(completion: @escaping ((News, ImageSize) -> Void)) -> NextFlowItems {
        let vc = NewsFormViewController()
        vc.didAddNews = completion
        self.rootViewController.present(vc, animated: true, completion: nil)
        return NextFlowItems.one(flowItem: NextFlowItem(nextPresentable: vc, nextStepper: vc))
    }

    private func navigationFromNewsForm() -> NextFlowItems {
        self.rootViewController.presentedViewController?.dismiss(animated: true, completion: nil)
        return NextFlowItems.none
    }

    private func navigationToSuggestionForm(
        completion: @escaping ((Suggestion, ImageSize) -> Void)) -> NextFlowItems {
        let vc = SuggestionFormViewController()
        vc.didAddSuggestion = completion
        self.rootViewController.present(vc, animated: true, completion: nil)
        return NextFlowItems.one(flowItem: NextFlowItem(nextPresentable: vc, nextStepper: vc))
    }

    private func navigationFromSuggestionForm() -> NextFlowItems {
        self.rootViewController.presentedViewController?.dismiss(animated: true, completion: nil)
        return NextFlowItems.none
    }

}
