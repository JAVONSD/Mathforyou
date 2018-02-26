//
//  MainMenuFlow.swift
//  Life
//
//  Created by Shyngys Kassymov on 15.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import Material

class MainMenuFlow: Flow {

    var root: Presentable {
        return self.rootViewController
    }

    private let rootViewController: AppToolbarController
    private let tabBarController: AppTabBarController

    init(tabBarController: AppTabBarController) {
        self.tabBarController = tabBarController
        self.rootViewController = AppToolbarController(rootViewController: self.tabBarController)
    }

    //swiftlint:disable cyclomatic_complexity
    func navigate(to step: Step) -> NextFlowItems {
        guard let step = step as? AppStep else { return NextFlowItems.stepNotHandled }

        switch step {
        case .login:
            return navigationToLoginScreen()
        case .mainMenu:
            return navigationToMainMenuScreen()
        case .profile:
            return navigationToProfileScreen()
        case .notifications:
            return navigationToNotifications()
        case .notificationsDone:
            return navigationFromNotifications()
        case .tasksAndRequests:
            return navigationToTasksAndRequests()
        case .tasksAndRequestsDone:
            return navigationFromTasksAndRequests()
        case .employeePicked(let employee):
            return navigationToEmployee(employee)
        case .employeeDone:
            return navigationFromEmployee()
        case .topQuestions:
            return navigationToTopQuestions()
        case .topQuestionPicked:
            // temp
            return navigationToTopQuestions()
        case .newsPicked(let id):
            return navigationToNewsDetail(id)
        case .newsDone:
            return navigationFromNewsDetail()
        case .suggestionPicked(let id):
            return navigationToSuggestion(id)
        case .suggestionDone:
            return navigationFromSuggestion()
        case .createNews:
            return navigationToNewsForm()
        case .createNewsDone:
            return navigationFromNewsForm()
        case .createSuggestion:
            return navigationToSuggestionForm()
        case .createSuggestionDone:
            return navigationFromSuggestionForm()
        case .createQuestion:
            return navigationToQuestionForm()
        case .createQuestionDone:
            return navigationFromQuestionForm()
        case .createRequest:
            return navigationToRequestForm()
        case .createRequestDone:
            return navigationFromRequestForm()
        default:
            return NextFlowItems.stepNotHandled
        }
    }
    //swiftlint:enable cyclomatic_complexity

    // MARK: - Navigation

    private func navigateToLoginScreen(isUnathorized: Bool = false) {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            let step = isUnathorized ? AppStep.unauthorized : AppStep.login
            appDelegate.coordinator.coordinate(
                flow: appDelegate.appFlow,
                withStepper: OneStepper(withSingleStep: step)
            )
        }
    }

    private func navigationToLoginScreen() -> NextFlowItems {
        navigateToLoginScreen()
        return NextFlowItems.none
    }

    private func navigationToMainMenuScreen() -> NextFlowItems {
        let biBoardVC = configuredBIBoard()
        let biOfficeVC = configuredBIOffice()
        let lentaVC = configuredLenta()
        let stuffVC = configuredStuff()
        let menuVC = configuredMenu()

        tabBarController.viewControllers = [
            biOfficeVC,
            biBoardVC,
            lentaVC,
            stuffVC,
            menuVC
        ]

        return NextFlowItems.one(flowItem: NextFlowItem(
            nextPresentable: rootViewController,
            nextStepper: rootViewController
        ))
    }

    private func navigationToProfileScreen() -> NextFlowItems {
        let viewController = ProfileViewController.configuredVC
        self.rootViewController.pushViewController(viewController, animated: true)
        return NextFlowItems.none
    }

    private func navigationToNotifications() -> NextFlowItems {
        let notificationsViewController = NotificationsViewController.instantiate(
            withViewModel: NotificationsViewModel()
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

    private func navigationToTasksAndRequests() -> NextFlowItems {
        let tasksAndRequestsViewController = TasksAndRequestsViewController.instantiate(
            withViewModel: TasksAndRequestsViewModel.sample()
        )
        let fabController = TasksAndRequestsFABController(
            rootViewController: tasksAndRequestsViewController
        )
        fabController.didTapAddButton = {
            tasksAndRequestsViewController.step.accept(AppStep.createRequest)
        }
        self.rootViewController.present(fabController, animated: true, completion: nil)
        return NextFlowItems.one(flowItem:
            NextFlowItem(
                nextPresentable: tasksAndRequestsViewController,
                nextStepper: tasksAndRequestsViewController)
        )
    }

    private func navigationFromTasksAndRequests() -> NextFlowItems {
        self.rootViewController.visibleViewController?.dismiss(animated: true, completion: nil)
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
        self.rootViewController.visibleViewController?.dismiss(animated: true, completion: nil)
        return NextFlowItems.none
    }

    private func navigationToTopQuestions() -> NextFlowItems {
        let viewController = TopQuestionsViewController(viewModel: TopQuestionsViewModel.sample())
        rootViewController.pushViewController(viewController, animated: true)
        return NextFlowItems.one(flowItem:
            NextFlowItem(
                nextPresentable: viewController,
                nextStepper: viewController)
        )
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

    private func navigationToNewsForm() -> NextFlowItems {
        let vc = NewsFormViewController()
        self.rootViewController.present(vc, animated: true, completion: nil)
        return NextFlowItems.one(flowItem: NextFlowItem(nextPresentable: vc, nextStepper: vc))
    }

    private func navigationFromNewsForm() -> NextFlowItems {
        self.rootViewController.visibleViewController?.dismiss(animated: true, completion: nil)
        return NextFlowItems.none
    }

    private func navigationToSuggestionForm() -> NextFlowItems {
        let vc = SuggestionFormViewController()
        self.rootViewController.present(vc, animated: true, completion: nil)
        return NextFlowItems.one(flowItem: NextFlowItem(nextPresentable: vc, nextStepper: vc))
    }

    private func navigationFromSuggestionForm() -> NextFlowItems {
        self.rootViewController.visibleViewController?.dismiss(animated: true, completion: nil)
        return NextFlowItems.none
    }

    private func navigationToQuestionForm() -> NextFlowItems {
        let vc = QuestionFormViewController()
        self.rootViewController.present(vc, animated: true, completion: nil)
        return NextFlowItems.one(flowItem: NextFlowItem(nextPresentable: vc, nextStepper: vc))
    }

    private func navigationFromQuestionForm() -> NextFlowItems {
        self.rootViewController.visibleViewController?.dismiss(animated: true, completion: nil)
        return NextFlowItems.none
    }

    private func navigationToRequestForm() -> NextFlowItems {
        let vc = RequestFormViewController()
        self.rootViewController.visibleViewController?.present(vc, animated: true, completion: nil)
        return NextFlowItems.one(flowItem: NextFlowItem(nextPresentable: vc, nextStepper: vc))
    }

    private func navigationFromRequestForm() -> NextFlowItems {
        self.rootViewController.visibleViewController?.dismiss(animated: true, completion: nil)
        return NextFlowItems.none
    }

    // MARK: - Methods

    private func configuredBIBoard() -> BIBoardViewController {
        let biBoardVC = BIBoardViewController()
        biBoardVC.onUnathorizedError = {
            self.navigateToLoginScreen(isUnathorized: true)
        }
        biBoardVC.didTapTop7 = { id in
            self.rootViewController.step.accept(AppStep.topQuestionPicked(withId: id))
        }
        biBoardVC.didTapAddSuggestion = {
            self.rootViewController.step.accept(AppStep.createSuggestion)
        }
        return biBoardVC
    }

    private func configuredBIOffice() -> BIOfficeViewController {
        let biOfficeVC = BIOfficeViewController()
        var biOfficeViewModel = BIOfficeViewModel()
        biOfficeViewModel.tasksAndRequestsViewModel = TasksAndRequestsViewModel()
        biOfficeVC.viewModel = biOfficeViewModel
        biOfficeVC.onUnathorizedError = {
            self.navigateToLoginScreen(isUnathorized: true)
        }
        biOfficeVC.didTapAddRequest = {
            self.rootViewController.step.accept(AppStep.createRequest)
        }
        return biOfficeVC
    }

    private func configuredLenta() -> LentaViewController {
        let lentaVC = LentaViewController()
        lentaVC.didTapNews = { newsId in
            self.rootViewController.step.accept(AppStep.newsPicked(withId: newsId))
        }
        lentaVC.didTapSuggestion = { id in
            self.rootViewController.step.accept(AppStep.suggestionPicked(withId: id))
        }
        lentaVC.didTapAddNews = {
            self.rootViewController.step.accept(AppStep.createNews)
        }
        lentaVC.onUnathorizedError = {
            self.navigateToLoginScreen(isUnathorized: true)
        }
        return lentaVC
    }

    private func configuredStuff() -> StuffViewController {
        let stuffVC = StuffViewController(
            employeesViewModel: EmployeesViewModel(),
            birthdaysViewModel: BirthdaysViewModel(employees: []),
            vacanciesViewModel: VacanciesViewModel()
        )
        stuffVC.didSelectEmployee = { employee in
            self.rootViewController.step.accept(AppStep.employeePicked(employee: employee))
        }
        stuffVC.didSelectBirthdate = { employee in
            self.rootViewController.step.accept(AppStep.employeePicked(employee: employee))
        }
        stuffVC.didSelectVacancy = { code in

        }
        stuffVC.onUnathorizedError = {
            self.navigateToLoginScreen(isUnathorized: true)
        }
        return stuffVC
    }

    private func configuredMenu() -> MenuViewController {
        let menuVC = MenuViewController.instantiate(withViewModel: MenuViewModel())
        menuVC.topQuestionTapped = {
            self.rootViewController.step.accept(AppStep.topQuestions)
        }
        menuVC.onUnathorizedError = {
            self.navigateToLoginScreen(isUnathorized: true)
        }
        return menuVC
    }

}
