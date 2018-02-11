//
//  Constants.swift
//  Life
//
//  Created by Shyngys Kassymov on 11.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import DynamicColor

struct App {

    // MARK: - Colors

    struct Color {
        static let coolGrey24 = UIColor(hexString: "#95989a").withAlphaComponent(0.24)
        static let azure = UIColor(hexString: "#108aeb")
        static let skyBlue = UIColor(hexString: "#4fc3f7")
        static let black24 = UIColor(hexString: "#333333").withAlphaComponent(0.24)
        static let midGreen = UIColor(hexString: "#4caf50")
        static let darkSlateBlue = UIColor(hexString: "#152957")
        static let silver = UIColor(hexString: "#d1d1d6")
        static let mango = UIColor(hexString: "#ffa726")
        static let white = UIColor(hexString: "#fefefe")
        static let blackDisable = UIColor(hexString: "#333333").withAlphaComponent(0.4)
        static let grapefruit = UIColor(hexString: "#ff5252")
        static let whiteTwo = UIColor(hexString: "#f7f7f7")
        static let paleGrey = UIColor(hexString: "#efeff4")
        static let black12 = UIColor(hexString: "#000000").withAlphaComponent(0.12)
        static let paleGreyTwo = UIColor(hexString: "#e5e8ef")
        static let steel = UIColor(hexString: "#8e8e93")
        static let shadows = UIColor(hexString: "#000000").withAlphaComponent(0.24)
        static let slateGrey = UIColor(hexString: "#6d6d72")
        static let greyishBrown = UIColor(hexString: "#444444")
        static let background = UIColor(hexString: "#fafafa")
        static let coolGrey = UIColor(hexString: "#bcbbc1")
        static let black = UIColor(hexString: "#333333")
        static let sky = UIColor(hexString: "#87cefa")
    }

    // MARK: - Fonts

    struct Font {

        static let titleAlts = regular(64)
        static let titleMedium = medium(34)
        static let titleSmall = medium(24)
        static let headline = medium(20)
        static let subheadAlts = medium(16)
        static let subhead = regular(16)
        static let subtitle = regular(16)
        static let navButton = medium(14)
        static let navButtonDisable = regular(14)
        static let bodyAlts = medium(14)
        static let body = regular(14)
        static let cardTitle = medium(14)
        static let button = medium(14)
        static let footnote = regular(13)
        static let captionAlts = medium(12)
        static let caption = regular(12)
        static let label = medium(12)
        static let buttonSmall = medium(12)

        // MARK: - Methods

        static func regular(_ size: CGFloat) -> UIFont {
            return UIFont(name: "Roboto-Regular", size: size) ??
                UIFont.systemFont(ofSize: size, weight: .regular)
        }

        static func medium(_ size: CGFloat) -> UIFont {
            return UIFont(name: "Roboto-Medium", size: size) ??
                UIFont.systemFont(ofSize: size, weight: .medium)
        }
    }

    // MARK: - Layout

    struct Layout {
        static let buttonHeight: CGFloat = 48

        static let sideOffset: CGFloat = 24
        static let itemSpacingSmall: CGFloat = 8
        static let itemSpacingBig: CGFloat = 16
    }

}
