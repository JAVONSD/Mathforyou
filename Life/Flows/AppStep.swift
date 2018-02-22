//
//  AppStep.swift
//  Life
//
//  Created by Shyngys Kassymov on 14.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation

enum AppStep: Step {

    // MARK: - Login

    case login
    case forgotPassword(login: String)
    case forgotPasswordCancel
    case resetPassword
    case unauthorized

    // MARK: - Main tab bar

    case mainMenu

    case biOffice
    case biBoard
    case lenta
    case employees
    case menu

    // MARK: - Profile

    case profile
    case resultPicked(withId: String)
    case planPicked(withId: String)

    // MARK: - Tasks and Requests

    case tasksAndRequests
    case tasksAndRequestsDone
    case createRequest

    // MARK: - News

    case createNews
    case createPost
    case newsPicked(withId: String)
    case forumPostPicked(withId: String)

    // MARK: - Suggestions

    case createSuggestion
    case suggestionPicked(withId: String)

    // MARK: - Questions

    case topQuestions
    case createQuestion

    // MARK: - Employees

    case employeePicked(withId: String)
    case employeeDone

    // MARK: - Notifications

    case notifications
    case notificationsDone

}