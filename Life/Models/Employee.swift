//
//  Employee.swift
//  Life
//
//  Created by Shyngys Kassymov on 19.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation

struct Employee: Codable {

    var code: String
    var firstname: String
    var fullname: String
    var login: String
    var birthDate: String
    var jobPosition: String
    var email: String
    var company: String
    var companyName: String
    var departmentName: String
    var workPhoneNumber: String
    var mobilePhoneNumber: String
    var address: String
    var isBirthdayToday: Bool
    var hasAvatar: Bool

    // MARK: - Decodable

    enum CodingKeys: String, CodingKey {
        case code
        case firstname
        case fullname
        case login
        case birthDate
        case jobPosition
        case email
        case company
        case companyName
        case departmentName
        case workPhoneNumber
        case mobilePhoneNumber
        case address
        case isBirthdayToday
        case hasAvatar
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.code = try container.decodeWrapper(key: .code, defaultValue: UUID().uuidString)
        self.firstname = try container.decodeWrapper(key: .firstname, defaultValue: "")
        self.fullname = try container.decodeWrapper(key: .fullname, defaultValue: "")
        self.login = try container.decodeWrapper(key: .login, defaultValue: "")
        self.birthDate = try container.decodeWrapper(key: .birthDate, defaultValue: "")
        self.jobPosition = try container.decodeWrapper(key: .jobPosition, defaultValue: "")
        self.email = try container.decodeWrapper(key: .email, defaultValue: "")
        self.company = try container.decodeWrapper(key: .company, defaultValue: "")
        self.companyName = try container.decodeWrapper(key: .companyName, defaultValue: "")
        self.departmentName = try container.decodeWrapper(key: .departmentName, defaultValue: "")
        self.workPhoneNumber = try container.decodeWrapper(key: .workPhoneNumber, defaultValue: "")
        self.mobilePhoneNumber = try container.decodeWrapper(key: .mobilePhoneNumber, defaultValue: "")
        self.address = try container.decodeWrapper(key: .address, defaultValue: "")
        self.isBirthdayToday = try container.decodeWrapper(key: .isBirthdayToday, defaultValue: false)
        self.hasAvatar = try container.decodeWrapper(key: .hasAvatar, defaultValue: false)
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(code, forKey: "code")
        aCoder.encode(firstname, forKey: "firstname")
        aCoder.encode(fullname, forKey: "fullname")
        aCoder.encode(login, forKey: "login")
        aCoder.encode(birthDate, forKey: "birthDate")
        aCoder.encode(jobPosition, forKey: "jobPosition")
        aCoder.encode(email, forKey: "email")
        aCoder.encode(company, forKey: "company")
        aCoder.encode(companyName, forKey: "companyName")
        aCoder.encode(departmentName, forKey: "departmentName")
        aCoder.encode(workPhoneNumber, forKey: "workPhoneNumber")
        aCoder.encode(mobilePhoneNumber, forKey: "mobilePhoneNumber")
        aCoder.encode(address, forKey: "address")
        aCoder.encode(isBirthdayToday, forKey: "isBirthdayToday")
        aCoder.encode(hasAvatar, forKey: "hasAvatar")
    }

}

extension Employee: Persistable {
    public init(managedObject: EmployeeObject) {
        code = managedObject.code
        firstname = managedObject.firstname
        fullname = managedObject.fullname
        login = managedObject.login
        birthDate = managedObject.birthDate
        jobPosition = managedObject.jobPosition
        email = managedObject.email
        company = managedObject.company
        companyName = managedObject.companyName
        departmentName = managedObject.departmentName
        workPhoneNumber = managedObject.workPhoneNumber
        mobilePhoneNumber = managedObject.mobilePhoneNumber
        address = managedObject.address
        isBirthdayToday = managedObject.isBirthdayToday
        hasAvatar = managedObject.hasAvatar
    }

    public func managedObject() -> EmployeeObject {
        let employee = EmployeeObject()
        employee.code = code
        employee.firstname = firstname
        employee.fullname = fullname
        employee.login = login
        employee.birthDate = birthDate
        employee.jobPosition = jobPosition
        employee.email = email
        employee.company = company
        employee.companyName = companyName
        employee.departmentName = departmentName
        employee.workPhoneNumber = workPhoneNumber
        employee.mobilePhoneNumber = mobilePhoneNumber
        employee.address = address
        employee.isBirthdayToday = isBirthdayToday
        employee.hasAvatar = hasAvatar
        return employee
    }
}

extension Employee: Hashable {
    var hashValue: Int {
        return code.hashValue
    }

    static func == (lhs: Employee, rhs: Employee) -> Bool {
        return lhs.code == rhs.code
    }
}
