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

    // MARK: - Methods

    public func update(with employee: Employee) {
        firstname = employee.firstname.onEmpty(firstname)
        fullname = employee.fullname.onEmpty(fullname)
        login = employee.login.onEmpty(login)
        birthDate = employee.birthDate.onEmpty(birthDate)
        jobPosition = employee.jobPosition.onEmpty(jobPosition)
        email = employee.email.onEmpty(email)
        company = employee.company.onEmpty(company)
        companyName = employee.companyName.onEmpty(companyName)
        departmentName = employee.departmentName.onEmpty(departmentName)
        workPhoneNumber = employee.workPhoneNumber.onEmpty(workPhoneNumber)
        mobilePhoneNumber = employee.mobilePhoneNumber.onEmpty(mobilePhoneNumber)
        address = employee.address.onEmpty(address)
        isBirthdayToday = employee.isBirthdayToday
        hasAvatar = employee.hasAvatar
        if employee.administrativeChiefName != nil {
            administrativeChiefName = employee.administrativeChiefName
        }
        if employee.functionalChiefName != nil {
            functionalChiefName = employee.functionalChiefName
        }
    }
}
