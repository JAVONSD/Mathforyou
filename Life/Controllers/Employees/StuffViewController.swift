//
//  StuffViewController.swift
//  Life
//
//  Created by Shyngys Kassymov on 16.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation
import Material

class StuffViewController: TabsController {

    var onUnathorizedError: (() -> Void)?

    var didSelectEmployee: ((Employee) -> Void)?
    var didSelectBirthdate: ((Employee) -> Void)?
    var didSelectVacancy: ((String) -> Void)?

    private var previousShadowHidden = false

    init(employeesViewModel: EmployeesViewModel,
         birthdaysViewModel: BirthdaysViewModel,
         vacanciesViewModel: VacanciesViewModel) {
        let vc1 = EmployeesViewController.instantiate(withViewModel: employeesViewModel)

        let vc2 = BirthdaysViewController.instantiate(withViewModel: birthdaysViewModel)
        vc2.onUnathorizedError = onUnathorizedError

        let vc3 = VacanciesViewController.instantiate(withViewModel: vacanciesViewModel)

        super.init(viewControllers: [vc1, vc2, vc3], selectedIndex: 0)

        vc1.didSelectEmployee = { employee in
            if let didSelectEmployee = self.didSelectEmployee {
                didSelectEmployee(employee)
            }
        }
        vc2.didSelectBirthdate = { employee in
            if let didSelectBirthdate = self.didSelectBirthdate {
                didSelectBirthdate(employee)
            }
        }
        vc3.didSelectVacancy = { code in
            if let didSelectVacancy = self.didSelectVacancy {
                didSelectVacancy(code)
            }
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
