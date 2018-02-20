//
//  KPIViewModel.swift
//  Life
//
//  Created by Shyngys Kassymov on 20.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation
import IGListKit

class KPIViewModel: NSObject, ListDiffable {
    var items = [ListDiffable]()
    var minimized = true

    func diffIdentifier() -> NSObjectProtocol {
        return self
    }

    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        if let object = object as? KPIViewModel {
            return self == object
        }
        return false
    }
}
