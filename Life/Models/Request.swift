//
//  Request.swift
//  Life
//
//  Created by Shyngys Kassymov on 19.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation

struct Request: Codable {

    var id: String
    var surname: String
    var name: String
    var taskNumber: String
    var registrationDate: String
    var dateofdelivery: String
    var taskStatus: String
    var shortDescription: String
    var customer: String
    var comment: String
    var fullname: String
    var topic: String
    var executorName: String
    var authorName: String
    var isExpired: Bool
    var isRequest: Bool
    var endDate: String
    var statusCode: Int

    // MARK: - Decodable

    enum CodingKeys: String, CodingKey {
        case id
        case surname
        case name
        case taskNumber
        case registrationDate
        case dateofdelivery
        case taskStatus
        case shortDescription
        case customer
        case comment
        case fullname
        case topic
        case executorName
        case authorName
        case isExpired
        case isRequest
        case endDate
        case statusCode
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.id = try container.decodeWrapper(key: .id, defaultValue: UUID().uuidString)
        self.surname = try container.decodeWrapper(key: .surname, defaultValue: "")
        self.name = try container.decodeWrapper(key: .name, defaultValue: "")
        self.taskNumber = try container.decodeWrapper(key: .taskNumber, defaultValue: "")
        self.registrationDate = try container.decodeWrapper(key: .registrationDate, defaultValue: "")
        self.dateofdelivery = try container.decodeWrapper(key: .dateofdelivery, defaultValue: "")
        self.taskStatus = try container.decodeWrapper(key: .taskStatus, defaultValue: "")
        self.shortDescription = try container.decodeWrapper(key: .shortDescription, defaultValue: "")
        self.customer = try container.decodeWrapper(key: .customer, defaultValue: "")
        self.comment = try container.decodeWrapper(key: .comment, defaultValue: "")
        self.fullname = try container.decodeWrapper(key: .fullname, defaultValue: "")
        self.topic = try container.decodeWrapper(key: .topic, defaultValue: "")
        self.executorName = try container.decodeWrapper(key: .executorName, defaultValue: "")
        self.authorName = try container.decodeWrapper(key: .authorName, defaultValue: "")
        self.isExpired = try container.decodeWrapper(key: .isExpired, defaultValue: false)
        self.isRequest = try container.decodeWrapper(key: .isRequest, defaultValue: false)
        self.endDate = try container.decodeWrapper(key: .endDate, defaultValue: "")
        self.statusCode = try container.decodeWrapper(key: .statusCode, defaultValue: 0)
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: "id")
        aCoder.encode(surname, forKey: "surname")
        aCoder.encode(name, forKey: "name")
        aCoder.encode(taskNumber, forKey: "taskNumber")
        aCoder.encode(registrationDate, forKey: "registrationDate")
        aCoder.encode(dateofdelivery, forKey: "dateofdelivery")
        aCoder.encode(taskStatus, forKey: "taskStatus")
        aCoder.encode(shortDescription, forKey: "shortDescription")
        aCoder.encode(customer, forKey: "customer")
        aCoder.encode(comment, forKey: "comment")
        aCoder.encode(fullname, forKey: "fullname")
        aCoder.encode(topic, forKey: "topic")
        aCoder.encode(executorName, forKey: "executorName")
        aCoder.encode(authorName, forKey: "authorName")
        aCoder.encode(isExpired, forKey: "isExpired")
        aCoder.encode(isRequest, forKey: "isRequest")
        aCoder.encode(endDate, forKey: "endDate")
        aCoder.encode(statusCode, forKey: "statusCode")
    }

}