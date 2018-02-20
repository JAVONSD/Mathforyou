//
//  Message.swift
//  Life
//
//  Created by Shyngys Kassymov on 19.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation

struct Message: Codable {
    
    var authorCode: String
    var authorName: String
    var message: String
    var createDate: String
    var isFromCurrentUser: Bool

    // MARK: - Decodable

    enum CodingKeys: String, CodingKey {
        case authorCode
        case authorName
        case message
        case createDate
        case isFromCurrentUser
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.authorCode = try container.decodeWrapper(key: .authorCode, defaultValue: UUID().uuidString)
        self.authorName = try container.decodeWrapper(key: .authorName, defaultValue: "")
        self.message = try container.decodeWrapper(key: .message, defaultValue: "")
        self.createDate = try container.decodeWrapper(key: .createDate, defaultValue: "")
        self.isFromCurrentUser = try container.decodeWrapper(key: .isFromCurrentUser, defaultValue: false)
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(authorCode, forKey: "authorCode")
        aCoder.encode(authorName, forKey: "authorName")
        aCoder.encode(message, forKey: "message")
        aCoder.encode(createDate, forKey: "createDate")
        aCoder.encode(isFromCurrentUser, forKey: "isFromCurrentUser")
    }

}
