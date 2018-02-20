//
//  Event.swift
//  Life
//
//  Created by Shyngys Kassymov on 19.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation

struct Event: Codable {

    var id: String
    var title: String
    var allDay: Bool
    var startDate: String
    var endDate: String
    var location: String
    var participants: String
    var desc: String
    var organizer: String
    var isLongEvent: Bool
    var color: String

    // MARK: - Decodable

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case allDay
        case startDate
        case endDate
        case location
        case participants
        case desc
        case organizer
        case isLongEvent
        case color
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.id = try container.decodeWrapper(key: .id, defaultValue: UUID().uuidString)
        self.title = try container.decodeWrapper(key: .title, defaultValue: "")
        self.allDay = try container.decodeWrapper(key: .allDay, defaultValue: false)
        self.startDate = try container.decodeWrapper(key: .startDate, defaultValue: "")
        self.endDate = try container.decodeWrapper(key: .endDate, defaultValue: "")
        self.location = try container.decodeWrapper(key: .location, defaultValue: "")
        self.participants = try container.decodeWrapper(key: .participants, defaultValue: "")
        self.desc = try container.decodeWrapper(key: .desc, defaultValue: "")
        self.organizer = try container.decodeWrapper(key: .organizer, defaultValue: "")
        self.isLongEvent = try container.decodeWrapper(key: .isLongEvent, defaultValue: false)
        self.color = try container.decodeWrapper(key: .color, defaultValue: "")
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: "id")
        aCoder.encode(title, forKey: "title")
        aCoder.encode(allDay, forKey: "allDay")
        aCoder.encode(startDate, forKey: "startDate")
        aCoder.encode(endDate, forKey: "endDate")
        aCoder.encode(location, forKey: "location")
        aCoder.encode(participants, forKey: "participants")
        aCoder.encode(desc, forKey: "desc")
        aCoder.encode(organizer, forKey: "organizer")
        aCoder.encode(isLongEvent, forKey: "isLongEvent")
        aCoder.encode(color, forKey: "color")
    }

}
