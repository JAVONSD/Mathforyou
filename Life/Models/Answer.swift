//
//  Answer.swift
//  Life
//
//  Created by Shyngys Kassymov on 19.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation

struct Answer: Codable {
    var questionText: String
    var answerText: String
    var likesQuantity: Int
}

struct VideoAnswer: Codable {
    var videoStreamId: String
    var createDate: String
    var answersQuantity: Int
}
