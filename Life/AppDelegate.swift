//
//  AppDelegate.swift
//  Life
//
//  Created by Shyngys Kassymov on 10.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import Kingfisher
import Lightbox
import RxSwift
import RxCocoa

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    let disposeBag = DisposeBag()
    
    // RxFlow
    var coordinator = Coordinator()
    var appFlow: AppFlow!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions
        launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .white
        window?.makeKeyAndVisible()

        guard let window = self.window else { return false }

        coordinator.rx.didNavigate.subscribe(onNext: { (flow, step) in
            print ("******** did navigate to flow=\(flow) and step=\(step)")
        }).disposed(by: self.disposeBag)

        self.appFlow = AppFlow(window: window)

        let loggedIn = User.current.isAuthenticated
        
        // ask the Coordinator to coordinate this Flow with a first Step
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

        IQKeyboardManager.sharedManager().enable = true

        LightboxConfig.loadImage = { imageView, url, completion in
            ImageDownloader.download(image: url.absoluteString, completion: { (image) in
                if let image = image {
                    imageView.image = image
                    completion?(image)
                }
            })
        }

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {}

    func applicationDidEnterBackground(_ application: UIApplication) {}

    func applicationWillEnterForeground(_ application: UIApplication) {}

    func applicationDidBecomeActive(_ application: UIApplication) {}

    func applicationWillTerminate(_ application: UIApplication) {}

    func application(_ application: UIApplication,
                     continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
            if let url = userActivity.webpageURL {
                let pathComponents = url.pathComponents
                let pathComponentCount = pathComponents.count
                if pathComponentCount > 2,
                    pathComponents[pathComponentCount - 2] == "news",
                    let newsId = pathComponents.last {
                    print("Open news with id - \(newsId)")
                } else if pathComponentCount > 2,
                    pathComponents[pathComponentCount - 2] == "suggestions",
                    let suggestionId = pathComponents.last {
                    print("Open suggestion with id - \(suggestionId)")
                } else if pathComponentCount > 2,
                    pathComponents[pathComponentCount - 2] == "questionnaires",
                    let questionnaireId = pathComponents.last {
                    print("Open questionnaire with id - \(questionnaireId)")
                }
            }
        }
        return true
    }

}







