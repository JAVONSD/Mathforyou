//
//  QuestionnaireObject.swift
//  Life
//
//  Created by Shyngys Kassymov on 10.03.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation
import RealmSwift

class QuestionnaireObject: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var title: String = ""
    @objc dynamic var descriptionText: String = ""
    @objc dynamic var createDate: String = ""
    @objc dynamic var imageStreamId: String = ""
    @objc dynamic var imageSize: ImageSizeObject?
    @objc dynamic var authorCode: String = ""
    @objc dynamic var authorName: String = ""
    let secondaryImages = List<ImageObject>()
    let questions = List<QuestionnaireQuestionObject>()
    @objc dynamic var questionsQuantity: Int = 0
    @objc dynamic var isAnonymous: Bool = false
    @objc dynamic var answeredEmployeeQuantity: Int = 0

    override static func primaryKey() -> String? {
        return "id"
    }
}
