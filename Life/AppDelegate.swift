//
//  AppDelegate.swift
//  Life
//
//  Created by Shyngys Kassymov on 10.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    let disposeBag = DisposeBag()
    var coordinator = Coordinator()
    var appFlow: AppFlow!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions
        launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .white
        window?.makeKeyAndVisible()

        guard let window = self.window else { return false }

        coordinator.rx.didNavigate.subscribe(onNext: { (flow, step) in
            print ("did navigate to flow=\(flow) and step=\(step)")
        }).disposed(by: self.disposeBag)

        self.appFlow = AppFlow(window: window)

        let loggedIn = User.currentUser.isAuthenticated
        if loggedIn {
            coordinator.coordinate(
                flow: self.appFlow,
                withStepper: OneStepper(withSingleStep: AppStep.mainMenu)
            )
        } else {
            coordinator.coordinate(
                flow: self.appFlow,
                withStepper: OneStepper(withSingleStep: AppStep.login)
            )
        }

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {}

    func applicationDidEnterBackground(_ application: UIApplication) {}

    func applicationWillEnterForeground(_ application: UIApplication) {}

    func applicationDidBecomeActive(_ application: UIApplication) {}

    func applicationWillTerminate(_ application: UIApplication) {}

}
