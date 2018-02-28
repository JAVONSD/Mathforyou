//
//  URL+Extensions.swift
//  Life
//
//  Created by Shyngys Kassymov on 28.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation
import Moya

extension URL {

    public func multipartFormData(_ name: String) -> MultipartFormData {
        return MultipartFormData(provider: .file(self), name: name)
    }

}
