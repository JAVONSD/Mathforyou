//
//  Like.swift
//  Life
//
//  Created by Shyngys Kassymov on 19.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation

enum UserVote: Int, Codable {
    case `default` = 0, liked = 1, disliked = -1
}
