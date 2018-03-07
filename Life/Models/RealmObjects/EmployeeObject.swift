//
//  EmployeeObject.swift
//  Life
//
//  Created by Shyngys Kassymov on 24.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation
import RealmSwift

final class EmployeeObject: Object {
    @objc dynamic var code: String = UUID().uuidString
    @objc dynamic var firstname: String = ""
    @objc dynamic var fullname: String = ""
    @objc dynamic var login: String = ""
    @objc dynamic var birthDate: String = ""
    @objc dynamic var jobPosition: String = ""
    @objc dynamic var email: String = ""
    @objc dynamic var company: String = ""
    @objc dynamic var companyName: String = ""
    @objc dynamic var departmentName: String = ""
    @objc dynamic var workPhoneNumber: String = ""
    @objc dynamic var mobilePhoneNumber: String = ""
    @objc dynamic var address: String = ""
    @objc dynamic var isBirthdayToday: Bool = false
    @objc dynamic var hasAvatar: Bool = false
    @objc dynamic var administrativeChiefName: String?
    @objc dynamic var functionalChiefName: String?

    override static func primaryKey() -> String? {
        return "code"
    }
}
