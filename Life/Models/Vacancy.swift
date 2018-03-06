//
//  Vacancy.swift
//  Life
//
//  Created by Shyngys Kassymov on 19.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation

struct Vacancy: Codable {

    var id: String
    var jobPosition: String
    var companyName: String
    var createDate: String
    var departmentName: String
    var salary: String

    // MARK: - Decodable

    enum CodingKeys: String, CodingKey {
        case id
        case jobPosition
        case companyName
        case createDate
        case departmentName
        case salary
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.id = try container.decodeWrapper(key: .id, defaultValue: UUID().uuidString)
        self.jobPosition = try container.decodeWrapper(key: .jobPosition, defaultValue: "")
        self.companyName = try container.decodeWrapper(key: .companyName, defaultValue: "")
        self.createDate = try container.decodeWrapper(key: .createDate, defaultValue: "")
        self.departmentName = try container.decodeWrapper(key: .departmentName, defaultValue: "")
        self.salary = try container.decodeWrapper(key: .salary, defaultValue: "")
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: "id")
        aCoder.encode(jobPosition, forKey: "jobPosition")
        aCoder.encode(companyName, forKey: "companyName")
        aCoder.encode(createDate, forKey: "createDate")
        aCoder.encode(departmentName, forKey: "departmentName")
        aCoder.encode(salary, forKey: "salary")
    }

}

extension Vacancy: Persistable {
    init(managedObject: VacancyObject) {
        id = managedObject.id
        jobPosition = managedObject.jobPosition
        companyName = managedObject.companyName
        createDate = managedObject.createDate
        departmentName = managedObject.departmentName
        salary = managedObject.salary
    }

    func managedObject() -> VacancyObject {
        let object = VacancyObject()
        object.id = id
        object.jobPosition = jobPosition
        object.companyName = companyName
        object.createDate = createDate
        object.departmentName = departmentName
        object.salary = salary
        return object
    }
}
