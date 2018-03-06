//
//  VacancyObject.swift
//  Life
//
//  Created by Shyngys Kassymov on 06.03.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation
import RealmSwift

class VacancyObject: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var jobPosition: String = ""
    @objc dynamic var companyName: String = ""
    @objc dynamic var createDate: String = ""
    @objc dynamic var departmentName: String = ""
    @objc dynamic var salary: String = ""
}
