//
//  UserInfoProtocols.swift
//  Life
//
//  Created by 123 on 02.08.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit

enum UserInfoProfileViewModelItemType {
    case nameAndPicture
    case about
    case email
    case friend
    case attribute
}

protocol ProfileViewModelItem {
    var profile: UserProfile? { get }
    
    var type: UserInfoProfileViewModelItemType { get }
    var sectionTitle: String { get }
    var rowCount: Int { get }
    
    // is the section is collapsible or not
    // the current section state: collapsed/expanded
    var isCollapsible: Bool { get }
    var isCollapsed: Bool { get set }
}

// set default values
extension ProfileViewModelItem {
    var rowCount: Int {
        return 1
    }
    
    var isCollapsible: Bool {
        return true
    }
}

























