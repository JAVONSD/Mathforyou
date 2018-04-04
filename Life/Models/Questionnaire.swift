//
//  Questionnaire.swift
//  Life
//
//  Created by Shyngys Kassymov on 19.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation

struct Questionnaire: Codable, Hashable {

    var id: String
    var title: String
    var description: String
    var createDate: String
    var imageStreamId: String
    var imageSize: ImageSize
    var authorCode: String
    var authorName: String
    var secondaryImages: [Image]
    var questions: [QuestionnaireQuestion]
    var questionsQuantity: Int
    var isAnonymous: Bool
    var isPublishedAsGroup: Bool
    var answeredEmployeeQuantity: Int
    var interviewedUsersQuantity: Int
    var isCurrentUserInterviewed: Bool

    // MARK: - Decodable

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case createDate
        case imageStreamId
        case imageSize
        case authorCode
        case authorName
        case secondaryImages
        case questions
        case questionsQuantity
        case isAnonymous
        case isPublishedAsGroup
        case answeredEmployeeQuantity
        case interviewedUsersQuantity
        case isCurrentUserInterviewed
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.id = try container.decodeWrapper(key: .id, defaultValue: UUID().uuidString)
        self.title = try container.decodeWrapper(key: .title, defaultValue: "")
        self.description = try container.decodeWrapper(key: .description, defaultValue: "")
        self.createDate = try container.decodeWrapper(key: .createDate, defaultValue: "")
        self.imageStreamId = try container.decodeWrapper(key: .imageStreamId, defaultValue: "")
        self.imageSize = try container.decodeWrapper(
            key: .imageSize,
            defaultValue: ImageSize(width: 200, height: 200)
        )
        self.authorCode = try container.decodeWrapper(key: .authorCode, defaultValue: "")
        self.authorName = try container.decodeWrapper(key: .authorName, defaultValue: "")
        self.secondaryImages = try container.decodeWrapper(key: .secondaryImages, defaultValue: [])
        self.questions = try container.decodeWrapper(key: .questions, defaultValue: [])
        self.questionsQuantity = try container.decodeWrapper(key: .questionsQuantity, defaultValue: 0)
        self.isAnonymous = try container.decodeWrapper(key: .isAnonymous, defaultValue: false)
        self.isPublishedAsGroup = try container.decodeWrapper(key: .isPublishedAsGroup, defaultValue: false)
        self.answeredEmployeeQuantity = try container.decodeWrapper(
            key: .answeredEmployeeQuantity,
            defaultValue: 0
        )
        self.interviewedUsersQuantity = try container.decodeWrapper(
            key: .interviewedUsersQuantity,
            defaultValue: 0
        )
        self.isCurrentUserInterviewed = try container.decodeWrapper(key: .isCurrentUserInterviewed, defaultValue: false)
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: "id")
        aCoder.encode(title, forKey: "title")
        aCoder.encode(description, forKey: "description")
        aCoder.encode(createDate, forKey: "createDate")
        aCoder.encode(imageStreamId, forKey: "imageStreamId")
        aCoder.encode(imageSize, forKey: "imageSize")
        aCoder.encode(authorCode, forKey: "authorCode")
        aCoder.encode(authorName, forKey: "authorName")
        aCoder.encode(secondaryImages, forKey: "secondaryImages")
        aCoder.encode(questions, forKey: "questions")
        aCoder.encode(questionsQuantity, forKey: "questionsQuantity")
        aCoder.encode(isAnonymous, forKey: "isAnonymous")
        aCoder.encode(isPublishedAsGroup, forKey: "isPublishedAsGroup")
        aCoder.encode(answeredEmployeeQuantity, forKey: "answeredEmployeeQuantity")
        aCoder.encode(interviewedUsersQuantity, forKey: "interviewedUsersQuantity")
        aCoder.encode(isCurrentUserInterviewed, forKey: "isCurrentUserInterviewed")
    }

    // MARK: - Hashable

    var hashValue: Int {
        return id.hashValue
    }

    static func == (lhs: Questionnaire, rhs: Questionnaire) -> Bool {
        return lhs.id == rhs.id
    }

}

// MARK: - Persistable

extension Questionnaire: Persistable {
    init(managedObject: QuestionnaireObject) {
        id = managedObject.id
        title = managedObject.title
        description = managedObject.descriptionText
        createDate = managedObject.createDate
        imageStreamId = managedObject.imageStreamId

        let imageSize = managedObject.imageSize ?? ImageSizeObject()
        self.imageSize = ImageSize(managedObject: imageSize)

        authorCode = managedObject.authorCode
        authorName = managedObject.authorName
        secondaryImages = managedObject.secondaryImages.map { Image(managedObject: $0) }
        questions = managedObject.questions.map { QuestionnaireQuestion(managedObject: $0) }
        questionsQuantity = managedObject.questionsQuantity
        isAnonymous = managedObject.isAnonymous
        isPublishedAsGroup = managedObject.isPublishedAsGroup
        answeredEmployeeQuantity = managedObject.answeredEmployeeQuantity
        interviewedUsersQuantity = managedObject.interviewedUsersQuantity
        isCurrentUserInterviewed = managedObject.isCurrentUserInterviewed
    }

    func managedObject() -> QuestionnaireObject {
        let object = QuestionnaireObject()
        object.id = id
        object.title = title
        object.descriptionText = description
        object.createDate = createDate
        object.imageStreamId = imageStreamId
        object.imageSize = imageSize.managedObject()
        object.authorCode = authorCode
        object.authorName = authorName
        object.secondaryImages.append(objectsIn: secondaryImages.map { $0.managedObject() })
        object.questions.append(objectsIn: questions.map { $0.managedObject() })
        object.questionsQuantity = questionsQuantity
        object.isAnonymous = isAnonymous
        object.isPublishedAsGroup = isPublishedAsGroup
        object.answeredEmployeeQuantity = answeredEmployeeQuantity
        object.interviewedUsersQuantity = interviewedUsersQuantity
        object.isCurrentUserInterviewed = isCurrentUserInterviewed
        return object
    }
}
