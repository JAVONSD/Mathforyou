//
//  CommentViewModel.swift
//  Life
//
//  Created by Shyngys Kassymov on 22.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation
import IGListKit

class CommentViewModel: NSObject, ListDiffable {
    var comment: Comment

    init(comment: Comment) {
        self.comment = comment
    }

    func diffIdentifier() -> NSObjectProtocol {
        return NSString(string: comment.id)
    }

    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        if let item = object as? CommentViewModel {
            return comment.id == item.comment.id
        }
        return false
    }
}
