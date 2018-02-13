//
//  Mockable.swift
//  Life
//
//  Created by Shyngys Kassymov on 13.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation

protocol Mockable {
    associatedtype T

    static func sample() -> T
}
