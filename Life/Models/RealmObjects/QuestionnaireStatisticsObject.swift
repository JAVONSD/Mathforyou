//
//  QuestionnaireStatisticsObject.swift
//  Life
//
//  Created by Shyngys Kassymov on 10.03.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation
import RealmSwift

class QuestionnaireStatisticsObject: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var createDate: String = ""
    @objc dynamic var authorCode: String = ""
    @objc dynamic var authorName: String = ""
    @objc dynamic var name: String = ""
    let questions = List<QuestionnaireQuestionStatisticsObject>()

    override static func primaryKey() -> String? {
        return "id"
    }
}

class QuestionnaireQuestionStatisticsObject: Object {
    @objc dynamic var questionText: String = ""
    let variants = List<QuestionnaireVariantStatisticsObject>()
    @objc dynamic var commentVariant: QuestionnaireVariantStatisticsObject?
    @objc dynamic var totalVotes: Int = 0
}

class QuestionnaireVariantStatisticsObject: Object {
    @objc dynamic var variantText: String = ""
    @objc dynamic var percentage: Int = 0
}
