//
//  Attachment.swift
//  Life
//
//  Created by Shyngys Kassymov on 04.04.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation

struct Attachment {

    enum AttachmentType {
        case file
        case image
    }

    var url: URL
    var type = AttachmentType.file

    var extensionName: String {
        return url.pathExtension
    }

    var fileName: String {
        return url.lastPathComponent
    }

}

extension Attachment: Hashable {
    var hashValue: Int {
        return url.hashValue
    }

    public static func == (lhs: Attachment, rhs: Attachment) -> Bool {
        return lhs.url == rhs.url
    }
}
