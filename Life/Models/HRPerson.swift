//
//  HRPerson.swift
//  Life
//
//  Created by 123 on 07.08.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation
import Moya_ModelMapper
import RxOptional
import Mapper

struct HRPerson: Mappable {
    
    let code: String
    let name: String
    let fullname: String
    let jobPosition: String
    
    
    init(map: Mapper) throws {
        try code = map.from("code")
        try name = map.from("name")
        try fullname = map.from("fullname")
        try jobPosition = map.from("jobPosition")
    }
}
