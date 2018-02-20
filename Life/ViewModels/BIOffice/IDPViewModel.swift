//
//  IDPViewModel.swift
//  Life
//
//  Created by Shyngys Kassymov on 20.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation
import IGListKit

class IDPViewModel: NSObject, ListDiffable {
    var items = [ListDiffable]()
    var minimized = true

    func diffIdentifier() -> NSObjectProtocol {
        return self
    }

    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        if let object = object as? IDPViewModel {
            return self == object
        }
        return false
    }
}
