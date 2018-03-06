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

    private var rootViewController: AppToolbarController
    private var viewController: LentaViewController

    private unowned var notificationsViewModel: NotificationsViewModel

    init(viewController: LentaViewController,
         notificationsViewModel: NotificationsViewModel) {
        self.notificationsViewModel = notificationsViewModel

        self.viewController = viewController
        rootViewController = AppToolbarController(rootViewController: viewController)

        rootViewController.setupToolbarButtons(for: viewController)
        rootViewController.didTapNotifications = { [weak self] in
            self?.viewController.step.accept(AppStep.notifications)
        }
        rootViewController.didTapProfile = { [weak self] in
            self?.viewController.step.accept(AppStep.profile)
        }
    }

    //swiftlint:disable cyclomatic_complexity
    func navigate(to step: Step) -> NextFlowItems {
        guard let step = step as? AppStep else { return NextFlowItems.stepNotHandled }

        switch step {
        case .lenta:
            return NextFlowItems.one(
                flowItem: NextFlowItem(
                    nextPresentable: viewController,
                    nextStepper: viewController
                )
            )
        case .profile:
            return navigationToProfileScreen()
        case .notifications:
            return navigationToNotifications()
        case .notificationsDone:
            return navigationFromNotifications()
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

    private func navigationToProfileScreen() -> NextFlowItems {
        let viewController = ProfileViewController.configuredVC
        let flow = ProfileFlow(viewController: viewController)
        self.rootViewController.pushViewController(viewController, animated: true)
        return NextFlowItems.one(flowItem:
            NextFlowItem(
                nextPresentable: flow,
                nextStepper: viewController)
        )
    }

    private func navigationToNotifications() -> NextFlowItems {
        let notificationsViewController = NotificationsViewController.instantiate(
            withViewModel: notificationsViewModel
        )
        self.rootViewController.present(notificationsViewController, animated: true, completion: nil)
        return NextFlowItems.one(flowItem:
            NextFlowItem(
                nextPresentable: notificationsViewController,
                nextStepper: notificationsViewController)
        )
    }

    private func navigationFromNotifications() -> NextFlowItems {
        self.rootViewController.visibleViewController?.dismiss(animated: true, completion: nil)
        return NextFlowItems.none
    }

    private func navigationToNewsDetail(_ id: String) -> NextFlowItems {
        let viewController = NewsViewController(
            viewModel: NewsItemViewModel(id: id)
        )
        self.rootViewController.present(viewController, animated: true, completion: nil)
        return NextFlowItems.one(flowItem:
            NextFlowItem(
                nextPresentable: viewController,
                nextStepper: viewController)
        )
    }

    private func navigationFromNewsDetail() -> NextFlowItems {
        self.rootViewController.visibleViewController?.dismiss(animated: true, completion: nil)
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
        self.rootViewController.visibleViewController?.dismiss(animated: true, completion: nil)
        return NextFlowItems.none
    }

    private func navigationToNewsForm(completion: @escaping ((News, ImageSize) -> Void)) -> NextFlowItems {
        let vc = NewsFormViewController()
        vc.didAddNews = completion
        self.rootViewController.present(vc, animated: true, completion: nil)
        return NextFlowItems.one(flowItem: NextFlowItem(nextPresentable: vc, nextStepper: vc))
    }

    private func navigationFromNewsForm() -> NextFlowItems {
        self.rootViewController.visibleViewController?.dismiss(animated: true, completion: nil)
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
        self.rootViewController.visibleViewController?.dismiss(animated: true, completion: nil)
        return NextFlowItems.none
    }

}
