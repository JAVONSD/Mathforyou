//
//  BIBoardFlow.swift
//  Life
//
//  Created by Shyngys Kassymov on 14.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit

class BIBoardFlow: Flow {

    var root: Presentable {
        return self.rootViewController
    }

    private weak var navigationController: AppToolbarController?
    let rootViewController: BIBoardViewController

    private unowned var notificationsViewModel: NotificationsViewModel
    private unowned var topQuestionsViewModel: TopQuestionsViewModel

    init(navigationController: AppToolbarController,
         viewController: BIBoardViewController,
         notificationsViewModel: NotificationsViewModel,
         topQuestionsViewModel: TopQuestionsViewModel) {
        self.notificationsViewModel = notificationsViewModel
        self.topQuestionsViewModel = topQuestionsViewModel

        self.navigationController = navigationController
        self.rootViewController = viewController
    }

    //swiftlint:disable cyclomatic_complexity
    func navigate(to step: Step) -> NextFlowItems {
        guard let step = step as? AppStep else { return NextFlowItems.stepNotHandled }

        switch step {
        case .biBoard:
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
        case .createSuggestion(let completion):
            return navigationToSuggestionForm(completion: completion)
        case .createSuggestionDone:
            return navigationFromSuggestionForm()
        case .employeePicked(let employee):
            return navigationToEmployee(employee)
        case .employeeDone:
            return navigationFromEmployee()
        case .topQuestionPicked:
            // temp
            return navigationToTopQuestions()
        case .topQuestions:
            return navigationToTopQuestions()
        default:
            return NextFlowItems.stepNotHandled
        }
    }
    //swiftlint:enable cyclomatic_complexity

    private func navigationToTopQuestions() -> NextFlowItems {
        let viewController = TopQuestionsViewController(viewModel: topQuestionsViewModel)
        let flow = TopQuestionsFlow(
            viewController: viewController,
            topQuestionsViewModel: topQuestionsViewModel
        )
        navigationController?.pushViewController(viewController, animated: true)

        return NextFlowItems.one(flowItem: NextFlowItem(
            nextPresentable: flow,
            nextStepper: viewController
        ))
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

    private func navigationToEmployee(_ employee: Employee) -> NextFlowItems {
        let notificationsViewController = EmployeeViewController.instantiate(
            withViewModel: EmployeeViewModel(employee: employee)
        )
        self.rootViewController.present(notificationsViewController, animated: true, completion: nil)
        return NextFlowItems.one(flowItem:
            NextFlowItem(
                nextPresentable: notificationsViewController,
                nextStepper: notificationsViewController)
        )
    }

    private func navigationFromEmployee() -> NextFlowItems {
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
