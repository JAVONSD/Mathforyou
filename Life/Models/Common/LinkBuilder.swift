//
//  LinkBuilder.swift
//  Life
//
//  Created by Shyngys Kassymov on 08.04.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation

class LinkBuilder {

    public static func newsLink(for id: String) -> String {
        guard var baseUrl = URL(string: App.String.baseUrl) else { return "" }
        baseUrl.appendPathComponent("news")
        baseUrl.appendPathComponent(id)
        return baseUrl.absoluteString
    }

    public static func suggestionLink(for id: String) -> String {
        guard var baseUrl = URL(string: App.String.baseUrl) else { return "" }
        baseUrl.appendPathComponent("suggestions")
        baseUrl.appendPathComponent(id)
        return baseUrl.absoluteString
    }

    public static func questionnaireLink(for id: String) -> String {
        guard var baseUrl = URL(string: App.String.baseUrl) else { return "" }
        baseUrl.appendPathComponent("questionnaires")
        baseUrl.appendPathComponent(id)
        return baseUrl.absoluteString
    }

}





