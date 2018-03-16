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

    private weak var navigationController: AppToolbarController?
    private var rootViewController: MenuViewController

    private unowned var topQuestionsViewModel: TopQuestionsViewModel
    private unowned var notificationsViewModel: NotificationsViewModel

    init(navigationController: AppToolbarController,
         viewController: MenuViewController,
         topQuestionsViewModel: TopQuestionsViewModel,
         notificationsViewModel: NotificationsViewModel) {
        self.topQuestionsViewModel = topQuestionsViewModel
        self.notificationsViewModel = notificationsViewModel

        self.navigationController = navigationController
        self.rootViewController = viewController
    }

    func navigate(to step: Step) -> NextFlowItems {
        guard let step = step as? AppStep else { return NextFlowItems.stepNotHandled }

        switch step {
        case .menu:
            return NextFlowItems.one(
                flowItem: NextFlowItem(
                    nextPresentable: rootViewController,
                    nextStepper: rootViewController
                )
            )
        case .topQuestions:
            return navigationToTopQuestions()
        default:
            return NextFlowItems.stepNotHandled
        }
    }

    private func navigationToTopQuestions() -> NextFlowItems {
        let viewController = TopQuestionsViewController(viewModel: topQuestionsViewModel)
        let flow = TopQuestionsFlow(
            viewController: viewController,
            topQuestionsViewModel: topQuestionsViewModel
        )
        navigationController?.pushViewController(viewController, animated: true)

        return NextFlowItems.one(flowItem: NextFlowItem(
            nextPresentable: flow,
            nextStepper: viewController)
        )
    }

}
