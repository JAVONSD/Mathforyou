//
//  MenuFlow.swift
//  Life
//
//  Created by Shyngys Kassymov on 14.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit

class MenuFlow: Flow {

    var root: Presentable {
        return self.rootViewController
    }

    private var rootViewController: AppToolbarController
    private var viewController: MenuViewController

    private unowned var topQuestionsViewModel: TopQuestionsViewModel
    private unowned var notificationsViewModel: NotificationsViewModel

    init(viewController: MenuViewController,
         topQuestionsViewModel: TopQuestionsViewModel,
         notificationsViewModel: NotificationsViewModel) {
        self.topQuestionsViewModel = topQuestionsViewModel
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

    func navigate(to step: Step) -> NextFlowItems {
        guard let step = step as? AppStep else { return NextFlowItems.stepNotHandled }

        switch step {
        case .menu:
            return NextFlowItems.one(
                flowItem: NextFlowItem(
                    nextPresentable: viewController,
                    nextStepper: viewController
                )
            )
        case .topQuestions:
            return navigationToTopQuestions()
        case .profile:
            return navigationToProfileScreen()
        case .notifications:
            return navigationToNotifications()
        case .notificationsDone:
            return navigationFromNotifications()
        default:
            return NextFlowItems.stepNotHandled
        }
    }

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

    private func navigationToTopQuestions() -> NextFlowItems {
        let viewController = TopQuestionsViewController(viewModel: topQuestionsViewModel)
        let flow = TopQuestionsFlow(
            viewController: viewController,
            topQuestionsViewModel: topQuestionsViewModel
        )
        rootViewController.pushViewController(viewController, animated: true)

        return NextFlowItems.one(flowItem: NextFlowItem(
            nextPresentable: flow,
            nextStepper: viewController)
        )
    }

}
