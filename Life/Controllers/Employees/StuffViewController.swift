//
//  StuffViewController.swift
//  Life
//
//  Created by Shyngys Kassymov on 16.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation
import Material

class StuffViewController: TabsController, Stepper {

    private var previousShadowHidden = false

    init(stuffViewModel: StuffViewModel) {
        let vc1 = EmployeesViewController(viewModel: stuffViewModel.employeesViewModel)

        let vc2 = BirthdaysViewController(viewModel: stuffViewModel.birthdaysViewModel)

        let vc3 = VacanciesViewController(viewModel: stuffViewModel.vacanciesViewModel)

        super.init(viewControllers: [vc1, vc2, vc3], selectedIndex: 0)

        vc1.onUnathorizedError = { [weak self] in
            self?.step.accept(AppStep.unauthorized)
        }
        vc1.didSelectEmployee = { [weak self] employee in
            self?.step.accept(AppStep.employeePicked(employee: employee))
        }
        vc2.onUnathorizedError = { [weak self] in
            self?.step.accept(AppStep.unauthorized)
        }
        vc2.didSelectBirthdate = { [weak self] employee in
            self?.step.accept(AppStep.employeePicked(employee: employee))
        }
        vc3.onUnathorizedError = { [weak self] in
            self?.step.accept(AppStep.unauthorized)
        }
        vc3.didSelectVacancy = { code in
            print("Vacancy picked with code - \(code)")
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let navVC = navigationController as? AppToolbarController {
            previousShadowHidden = navVC.shadowHidden
            navVC.setShadow(hidden: true)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if let navVC = navigationController as? AppToolbarController {
            navVC.setShadow(hidden: previousShadowHidden)
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

}
