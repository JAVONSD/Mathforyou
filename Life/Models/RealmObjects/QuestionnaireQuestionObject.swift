//
//  QuestionnaireQuestionObject.swift
//  Life
//
//  Created by Shyngys Kassymov on 10.03.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation
import RealmSwift

class QuestionnaireQuestionObject: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var text: String = ""
    @objc dynamic var minAnswersQuantity: Int = 0
    @objc dynamic var maxAnswersQuantity: Int = 0
    let variants = List<QuestionnaireVariantObject>()
    let userAnswer = List<String>()
    @objc dynamic var userComment: String = ""
    @objc dynamic var canComment: Bool = false
    @objc dynamic var totalAnswers: Int = 0

    override static func primaryKey() -> String? {
        return "id"
    }
}

class QuestionnaireVariantObject: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var text: String = ""

    override static func primaryKey() -> String? {
        return "id"
    }
}
