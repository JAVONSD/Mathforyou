//
//  StuffViewController.swift
//  Life
//
//  Created by Shyngys Kassymov on 16.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation
import Material
import PopupDialog

class StuffViewController: TabsController, TabsControllerDelegate, Stepper {

    private var previousShadowHidden = false
    var needScrollToTop: ((Int) -> Void)?

    private var lastSelectedIndex = 0

    init(stuffViewModel: StuffViewModel) {
        let vc1 = EmployeesViewController(viewModel: stuffViewModel.employeesViewModel)

        let vc2 = BirthdaysViewController(viewModel: stuffViewModel.birthdaysViewModel)

        let vc3 = VacanciesViewController(viewModel: stuffViewModel.vacanciesViewModel)

        super.init(viewControllers: [vc1, vc2, vc3], selectedIndex: 0)

        vc1.onUnathorizedError = { [weak self] in
            User.current.logout()
            self?.step.accept(AppStep.unauthorized)
        }
        vc1.didSelectEmployee = { [weak self] employee in
            self?.step.accept(AppStep.employeePicked(employee: employee))
        }
        vc2.onUnathorizedError = { [weak self] in
            User.current.logout()
            self?.step.accept(AppStep.unauthorized)
        }
        vc2.didSelectBirthdate = { [weak self] employee in
            self?.step.accept(AppStep.employeePicked(employee: employee))
        }
        vc2.wantCongratulate = { [weak self] employee in
            let viewModel = CongratulateViewModel(employee: employee)
            let vc = CongratulateViewController(viewModel: viewModel)
            let popup = PopupDialog(viewController: vc)
            let containerAppearance = PopupDialogContainerView.appearance()
            containerAppearance.cornerRadius = Float(App.Layout.cornerRadius)
            self?.present(popup, animated: true, completion: nil)
        }
        vc3.onUnathorizedError = { [weak self] in
            User.current.logout()
            self?.step.accept(AppStep.unauthorized)
        }
        vc3.didSelectVacancy = { code in
            print("Vacancy picked with code - \(code)")
        }

        delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let tabVC = parent as? AppTabBarController {
            tabVC.didTapTab = { [weak self] idx in
                guard idx == 3, tabVC.currentTabIndex == idx else { return }
                self?.needScrollToTop?(self?.selectedIndex ?? 0)
            }
        }
    }

    override func prepare() {
        super.prepare()

        view.backgroundColor = App.Color.whiteSmoke

        tabBar.setLineColor(App.Color.azure, for: .selected)

        tabBar.setTabItemsColor(App.Color.slateGrey, for: .normal)
        tabBar.setTabItemsColor(UIColor.black, for: .selected)
        tabBar.setTabItemsColor(UIColor.black, for: .highlighted)

        tabBarAlignment = .top
        tabBar.tabBarStyle = .nonScrollable
        tabBar.dividerColor = nil
        tabBar.lineHeight = 2.0
        tabBar.lineAlignment = .bottom
        tabBar.backgroundColor = App.Color.white
        tabBar.tabItemsContentEdgeInsetsPreset = .none
        tabBar.tabItemsInterimSpacePreset = .none

        tabBar.shadowColor = App.Color.shadows
        tabBar.depth = Depth(offset: Offset.init(horizontal: 0, vertical: 1), opacity: 1, radius: 6)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }

    // MARK: - TabsControllerDelegate

    func tabBar(tabBar: TabBar, shouldSelect tabItem: TabItem) -> Bool {
        if let index = tabBar.tabItems.index(of: tabItem) {
            if lastSelectedIndex == index {
                needScrollToTop?(selectedIndex)
            }
        }
        return true
    }

    func tabsController(tabsController: TabsController, didSelect viewController: UIViewController) {
        lastSelectedIndex = selectedIndex
    }

}
