//
//  ForgotPasswordViewModel.swift
//  Life
//
//  Created by Shyngys Kassymov on 14.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation

struct ForgotPasswordViewModel: ViewModel {
    var submitErrorMessage: String?
    var login: String

    init(login: String) {
        self.login = login
    }
}
