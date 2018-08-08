//
//  UserInfoProtocols.swift
//  Life
//
//  Created by 123 on 02.08.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit

enum ProfileViewModelItemType {
    case bigPicture
    case nameAndPicture
    case personal
    case workexperiance
    case medical
    case education
    case history
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

class ProfileViewModePictureItem: ProfileViewModelItem {
    
    var type: ProfileViewModelItemType {
        return .bigPicture
    }
    
    var sectionTitle: String {
        return ""
    }
    
    var isCollapsed: Bool = false
    
    var isCollapsible: Bool = false
    
    var rowCount: Int {
        return 1
    }
    
    init() { }
}

class ProfileViewModeHeaderItem: ProfileViewModelItem {
    
    var type: ProfileViewModelItemType {
        return .nameAndPicture
    }
    
    var sectionTitle: String {
        return ""
    }
    
    var isCollapsed: Bool = false
    
    var isCollapsible: Bool = false
    
    var rowCount: Int {
        return 4
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

class ProfileViewModelWorkActivitiesItem: ProfileViewModelItem {
    
    var type: ProfileViewModelItemType {
        return .workexperiance
    }
    
    var sectionTitle: String {
        return NSLocalizedString("Трудовая деятельность", comment: "")
    }
    
    var isCollapsed = true
    
    var rowCount: Int {
        return 2
    }
    
    init() { }
}

class ProfileViewModelMedicalItem: ProfileViewModelItem {
    
    var type: ProfileViewModelItemType {
        return .medical
    }
    
    var sectionTitle: String {
        return NSLocalizedString("Медосмотр", comment: "")
    }
    
    var isCollapsed = true
    
    var rowCount: Int {
        return 1
    }
    
    init() { }
}

class ProfileViewModelEducationItem: ProfileViewModelItem {
    
    var type: ProfileViewModelItemType {
        return .education
    }
    
    var sectionTitle: String {
        return NSLocalizedString("Образование и квалификация", comment: "")
    }
    
    var isCollapsed = true
    var isCollapsible = true
    
    var rowCount: Int {
        print("profile.educations.count", profile.educations.count)

        return profile.educations.count
    }
    
    
    var profile: UserProfile
    
    init(profile: UserProfile) {
        self.profile = profile
    }
}

class ProfileViewModelHistoryItem: ProfileViewModelItem {
    
    var type: ProfileViewModelItemType {
        return .history
    }
    
    var sectionTitle: String {
        return NSLocalizedString("Перемещения", comment: "")
    }
    
    var isCollapsed = true
    var isCollapsible = true
    
    var rowCount: Int {
        return profile.history.count
    }
    
    var profile: UserProfile
    
    init(profile: UserProfile) {
        self.profile = profile
    }
}

































