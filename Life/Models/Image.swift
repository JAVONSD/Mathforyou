//
//  Image.swift
//  Life
//
//  Created by Shyngys Kassymov on 19.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation

struct Image: Codable {

    var streamId: String
    var filename: String

    // MARK: - Decodable

    enum CodingKeys: String, CodingKey {
        case streamId
        case filename
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.streamId = try container.decodeWrapper(key: .streamId, defaultValue: UUID().uuidString)
        self.filename = try container.decodeWrapper(key: .filename, defaultValue: "")
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(streamId, forKey: "streamId")
        aCoder.encode(filename, forKey: "filename")
    }

}
