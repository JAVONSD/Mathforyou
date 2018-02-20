//
//  SliderViewModel.swift
//  Life
//
//  Created by Shyngys Kassymov on 19.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation

struct SliderViewModel {
    var title: String
    var label: String
    var image: String
}

// swiftlint:disable line_length

extension SliderViewModel: Mockable {
    typealias T = SliderViewModel

    static func sample() -> SliderViewModel {
        return SliderViewModel(
            title: "День открытых дверей пройдет в ЖК «Милано»",
            label: "новости",
            image: "https://images.pexels.com/photos/60006/spring-tree-flowers-meadow-60006.jpeg?w=1260&h=750&auto=compress&cs=tinysrgb"
        )
    }
}

// swiftlint:enable line_length
