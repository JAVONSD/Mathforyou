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
    
    case userProfile

    // MARK: - Tasks and Requests

    case tasksAndRequests
    case tasksAndRequestsDone
    case createRequest(category: Request.Category, didCreateRequest: (() -> Void))
    case createRequestDone
    case createTask(didCreateTask: (() -> Void))
    case createTaskDone

    // MARK: - News

    case createNews(completion: ((News, ImageSize) -> Void))
    case createNewsDone
    case createPost
    case newsPicked(withId: String)
    case newsDone
    case forumPostPicked(withId: String)

    // MARK: - Suggestions

    case createSuggestion(completion: ((Suggestion, ImageSize) -> Void))
    case createSuggestionDone
    case suggestionPicked(withId: String)
    case suggestionDone

    // MARK: - Questions

    case topQuestions
    case topQuestionPicked(withId: String)
    case topQuestionDone
    case createQuestion(didAddQuestion: ((Question) -> Void))
    case createQuestionDone
    case createAnswer(
        questions: [Question],
        isVideo: Bool,
        didCreateAnswer: ((Answer, [String]) -> Void))
    case createAnswerDone

    // MARK: - Employees

    case employeePicked(employee: Employee)
    case employeeDone

    // MARK: - Notifications

    case notifications
    case notificationsDone

    // MARK: - Global Search (Kanat)
    case newsSearch
    case suggestionSearch
    case questionSearch
}









