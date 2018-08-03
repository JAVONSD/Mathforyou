//
//  UserInfoProtocols.swift
//  Life
//
//  Created by 123 on 02.08.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit

enum ProfileViewModelItemType {
    case nameAndPicture
    case personal
    case workexperiance
    case medical
    case education
    case movement 
}

protocol ProfileViewModelItem {
    var type: ProfileViewModelItemType { get }
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

class ProfileViewModelWorkActivitiesItem: ProfileViewModelItem {
    
    var type: ProfileViewModelItemType {
        return .workexperiance
    }
    
    var sectionTitle: String {
        return NSLocalizedString("Трудовая деятельность", comment: "")
    }
    
    var isCollapsed = true
    
    var rowCount: Int {
        return 3
    }
    
    init() { }
}

class ProfileViewModelMedicalItem: ProfileViewModelItem {
    
    var type: ProfileViewModelItemType {
        return .personal
    }
    
    var sectionTitle: String {
        return NSLocalizedString("Медосмотр", comment: "")
    }
    
    var isCollapsed = true
    
    var rowCount: Int {
        return 3
    }
    
    init() { }
}

class ProfileViewModelPersonalItem: ProfileViewModelItem {
    
    var type: ProfileViewModelItemType {
        return .personal
    }
    
    var sectionTitle: String {
        return NSLocalizedString("Личные и семья", comment: "")
    }
    
    var isCollapsed = true
    
    var rowCount: Int {
        return 3
    }
    
    init() { }
}






























