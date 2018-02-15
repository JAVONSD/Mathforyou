//
//  Bundle+Extensions.swift
//  Life
//
//  Created by Shyngys Kassymov on 14.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation

extension Bundle {

    public func stubJSONWith(name: String) -> Data {
        guard let jsonPath = path(forResource: name, ofType: "json"),
            let url = URL(string: jsonPath),
            let data = try? Data(contentsOf: url) else {
                return "{}".utf8Encoded
        }
        return data
    }

}
