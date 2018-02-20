//
//  DateCell.swift
//  Life
//
//  Created by Shyngys Kassymov on 20.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import DateToolsSwift
import IGListKit

class DateCell: NSObject, ListDiffable {

    private(set) var dateUpdated = Date()
    private let identifier = NSString(string: "DateCell")

    func update() {
        dateUpdated = Date()
    }

    func diffIdentifier() -> NSObjectProtocol {
        return identifier
    }

    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        if let object = object as? DateCell {
            return self.dateUpdated.compare(object.dateUpdated) == .orderedSame
        }
        return false
    }

}
