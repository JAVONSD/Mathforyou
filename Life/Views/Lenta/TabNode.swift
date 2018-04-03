//
//  TabNode.swift
//  Life
//
//  Created by Shyngys Kassymov on 02.04.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import Material

class TabNode: ASCellNode {

    private(set) var tabNode: ASDisplayNode!
    private(set) var tabBar: TabBar!

    var didSelectTab: ((Int) -> Void)?
    var selectedIdx = 0

    override init() {
        super.init()

        tabNode = ASDisplayNode(viewBlock: { () -> UIView in
            self.setupTabBar()
            return self.tabBar
        })
        addSubnode(tabNode)
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        tabNode.style.minSize = CGSize(
            width: constrainedSize.max.width,
            height: 40
        )

        return ASInsetLayoutSpec(insets: .init(
            top: 0,
            left: 0,
            bottom: App.Layout.itemSpacingMedium,
            right: 0), child: tabNode)
    }

    // MARK: - UI

    private func setupTabBar() {
        tabBar = TabBar(frame: .init(
            x: 0,
            y: 0,
            width: UIScreen.main.bounds.size.width,
            height: 40)
        )

        let titles = [
            NSLocalizedString("all", comment: ""),
            NSLocalizedString("news", comment: ""),
            NSLocalizedString("suggestions", comment: ""),
            NSLocalizedString("questionnaires", comment: "")
        ]

        var tabItems = [TabItem]()
        for idx in 0..<titles.count {
            let title = titles[idx]
            let tabItem = TabItem(
                title: title,
                titleColor: .black
            )
            tabItem.titleLabel?.font = App.Font.buttonSmall
            tabItem.tag = idx
            tabItems.append(tabItem)
        }

        tabBar.tabItems = tabItems

        tabBar.setLineColor(App.Color.azure, for: .selected)

        tabBar.setTabItemsColor(App.Color.slateGrey, for: .normal)
        tabBar.setTabItemsColor(UIColor.black, for: .selected)
        tabBar.setTabItemsColor(App.Color.slateGrey, for: .highlighted)

        tabBar.tabBarStyle = .nonScrollable
        tabBar.dividerColor = nil
        tabBar.lineHeight = 2.0
        tabBar.lineAlignment = .bottom
        tabBar.backgroundColor = App.Color.whiteSmoke

        tabBar.shadowColor = UIColor.black.withAlphaComponent(0.16)
        tabBar.depth = Depth(offset: Offset.init(horizontal: 0, vertical: 1), opacity: 1, radius: 6)

        tabBar.delegate = self
    }

    override func didLoad() {
        super.didLoad()

        tabBar.setNeedsLayout()
        tabBar.layoutIfNeeded()

        tabBar.select(at: selectedIdx)
    }

}

extension TabNode: TabBarDelegate {
    func tabBar(tabBar: TabBar, didSelect tabItem: TabItem) {
        if let didSelectTab = didSelectTab {
            didSelectTab(tabItem.tag)
        }
    }
}
