//
//  AppTabBarController.swift
//  Life
//
//  Created by Shyngys Kassymov on 14.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import Kingfisher
import Material
import RxSwift
import RxCocoa
import SnapKit

class AppTabBarController: UIViewController, TabBarDelegate, Stepper {

    private(set) lazy var containerView = UIView(frame: .zero)
    private(set) lazy var tabBar = TabBar(frame: .zero)

    private let disposeBag = DisposeBag()

    var viewControllers = [UIViewController]()
    private(set) var currentTabIndex = 0

    var didTapTab: ((Int) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        guard currentTabIndex < viewControllers.count else { return }
        viewControllers[currentTabIndex].beginAppearanceTransition(true, animated: animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard currentTabIndex < viewControllers.count else { return }
        viewControllers[currentTabIndex].endAppearanceTransition()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        guard currentTabIndex < viewControllers.count else { return }
        viewControllers[currentTabIndex].beginAppearanceTransition(false, animated: animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        guard currentTabIndex < viewControllers.count else { return }
        viewControllers[currentTabIndex].endAppearanceTransition()
    }

    // MARK: - Methods

    private func addChild(_ vc: UIViewController) {
        addChildViewController(vc)
        containerView.addSubview(vc.view)
        vc.view.snp.makeConstraints { [weak self] (make) in
            guard let `self` = self else { return }
            make.edges.equalTo(self.containerView)
        }
        vc.didMove(toParentViewController: self)
    }

    private func removeChild(_ vc: UIViewController) {
        vc.willMove(toParentViewController: nil)
        vc.view.removeFromSuperview()
        vc.removeFromParentViewController()
    }

    public func move(to: Int, animate: Bool = false) {
        if animate {
            tabBar.select(at: to)
        }

        if currentTabIndex == to ||
            currentTabIndex >= viewControllers.count ||
            to >= viewControllers.count {
            return
        }

        let oldVC = viewControllers[currentTabIndex]
        let newVC = viewControllers[to]

        removeChild(oldVC)
        addChild(newVC)

        currentTabIndex = to
    }

    // MARK: - UI

    private func setupUI() {
        view.backgroundColor = .white

        setupTabBar()
        setupContainerView()
        setupInitialVC()
    }

    private func setupTabBar() {
        view.addSubview(tabBar)
        tabBar.snp.makeConstraints { [weak self] (make) in
            guard let `self` = self else { return }
            make.left.equalTo(self.view)
            make.bottom.equalTo(self.bottomLayoutGuide.snp.top)
            make.right.equalTo(self.view)
            make.height.equalTo(App.Layout.tabBarHeight)
        }

        let tabItem1 = TabItem(image: #imageLiteral(resourceName: "board-inactive"), tintColor: App.Color.azure)
        tabItem1.tag = 0

//        let tabItem2 = TabItem(image: #imageLiteral(resourceName: "office-inactive"), tintColor: App.Color.azure)
//        tabItem2.tag = 1

        let tabItem3 = TabItem(image: #imageLiteral(resourceName: "feed-office-inactive"), tintColor: App.Color.azure)
        tabItem3.tag = 1

        let tabItem4 = TabItem(image: #imageLiteral(resourceName: "stuff-inactive"), tintColor: App.Color.azure)
        tabItem4.tag = 2

        let tabItem5 = TabItem(image: #imageLiteral(resourceName: "menu-inactive"), tintColor: App.Color.azure)
        tabItem5.tag = 3

        tabBar.tabItems = [
            tabItem1,
//            tabItem2,
            tabItem3,
            tabItem4,
            tabItem5
        ]

        tabBar.setLineColor(UIColor.clear, for: .selected)

        tabBar.setTabItemsColor(App.Color.coolGrey, for: .normal)
        tabBar.setTabItemsColor(App.Color.azure, for: .selected)
        tabBar.setTabItemsColor(App.Color.coolGrey, for: .highlighted)

        tabBar.tabBarStyle = .nonScrollable
        tabBar.dividerColor = nil
        tabBar.lineHeight = 0.0
        tabBar.lineAlignment = .bottom
        tabBar.backgroundColor = App.Color.white

        tabBar.shadowColor = App.Color.paleGreyTwo
        tabBar.depth = Depth(offset: Offset.init(horizontal: 0, vertical: -0.5), opacity: 1, radius: 0)

        tabBar.delegate = self
    }

    private func setupContainerView() {
        containerView.backgroundColor = .clear
        view.addSubview(containerView)
        view.sendSubview(toBack: containerView)
        containerView.snp.makeConstraints { [weak self] (make) in
            guard let `self` = self else { return }
            make.top.equalTo(self.topLayoutGuide.snp.bottom)
            make.left.equalTo(self.view)
            make.bottom.equalTo(self.tabBar.snp.top)
            make.right.equalTo(self.view)
        }
    }

    private func setupInitialVC() {
        currentTabIndex = 1
        if currentTabIndex < viewControllers.count {
            tabBar.select(at: currentTabIndex)
            addChild(viewControllers[currentTabIndex])
        }
    }

    // MARK: - TabBarDelegate

    func tabBar(tabBar: TabBar, didSelect tabItem: TabItem) {
        navigationController?.setNavigationBarHidden(tabItem.tag == 2, animated: false)

        if let didTapTab = didTapTab {
            didTapTab(tabItem.tag)
        }
        move(to: tabItem.tag)
    }

}
