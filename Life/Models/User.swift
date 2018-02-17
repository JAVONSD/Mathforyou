//
//  User.swift
//  Life
//
//  Created by Shyngys Kassymov on 14.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation

struct User: Codable {

    var token: String?
    var login: String
    var employeeCode: String

    // MARK: - Codable

    enum CodingKeys: String, CodingKey {
        case token
        case login
        case employeeCode
    }

    // MARK: - Methods

    private static var _current: User?
    static var current: User {
        get {
            if _current != nil {
                return _current!
            }

            let token = UserDefaults.standard.string(forKey: App.Key.userToken)
            let login = UserDefaults.standard.string(forKey: App.Key.userLogin) ?? ""
            let employeeCode = UserDefaults.standard.string(forKey: App.Key.userEmployeeCode) ?? ""
            _current = User(token: token, login: login, employeeCode: employeeCode)
            return _current!
        }
        set(newValue) {
            _current = newValue
        }
    }

    var isAuthenticated: Bool {
        return token != nil
    }

    public func save() {
        if let token = token {
            UserDefaults.standard.set(token, forKey: App.Key.userToken)
        }
        UserDefaults.standard.set(login, forKey: App.Key.userLogin)
        UserDefaults.standard.set(employeeCode, forKey: App.Key.userEmployeeCode)
        UserDefaults.standard.synchronize()
    }

    public func logout() {
        UserDefaults.standard.set(nil, forKey: App.Key.userToken)
        UserDefaults.standard.set(login, forKey: App.Key.userLogin)
        UserDefaults.standard.set(nil, forKey: App.Key.userEmployeeCode)
        UserDefaults.standard.synchronize()
    }

}

struct UserProfile {
    var fullname: String
    var employeeCode: String
    var jobPosition: String
    var company: String
    var iin: String
    var birthDate: String
    var gender: String
    var familyStatus: String
    var childrenQuantit: String
    var clothingSiz: String
    var shoeSize: String
    var email: String
    var workPhoneNumber: String
    var mobilePhoneNumber: String
    var address: String
    var totalExperienc: String
    var corporateExperienc: String
    var administrativeChiefName: String?
    var functionalChiefName: String?
    var educationTypeName: String
    var institutionName: String
    var graduationYear: String
    var adLogin: String
}
