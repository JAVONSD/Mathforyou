//
//  Constants.swift
//  Life
//
//  Created by Shyngys Kassymov on 11.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import Hue
import RealmSwift

struct App {

    // MARK: - Colors

    struct Color {

        static let coolGrey24 = UIColor(hex: "#95989a").withAlphaComponent(0.24)
        static let azure = UIColor(hex: "#108aeb")
        static let skyBlue = UIColor(hex: "#4fc3f7")
        static let black24 = UIColor(hex: "#333333").withAlphaComponent(0.24)
        static let midGreen = UIColor(hex: "#4caf50")
        static let darkSlateBlue = UIColor(hex: "#152957")
        static let silver = UIColor(hex: "#d1d1d6")
        static let mango = UIColor(hex: "#ffa726")
        static let white = UIColor(hex: "#fefefe")
        static let whiteSmoke = UIColor(hex: "#f5f5f5")
        static let blackDisable = UIColor(hex: "#333333").withAlphaComponent(0.4)
        static let grapefruit = UIColor(hex: "#ff5252")
        static let whiteTwo = UIColor(hex: "#f7f7f7")
        static let paleGrey = UIColor(hex: "#efeff4")
        static let black12 = UIColor(hex: "#000000").withAlphaComponent(0.12)
        static let paleGreyTwo = UIColor(hex: "#e5e8ef")
        static let steel = UIColor(hex: "#8e8e93")
        static let shadows = UIColor(hex: "#000000").withAlphaComponent(0.24)
        static let slateGrey = UIColor(hex: "#6d6d72")
        static let greyishBrown = UIColor(hex: "#444444")
        static let background = UIColor(hex: "#fafafa")
        static let coolGrey = UIColor(hex: "#bcbbc1")
        static let black = UIColor(hex: "#333333")
        static let sky = UIColor(hex: "#87cefa")

        static let blueGradient = [
            UIColor(hex: "#1a44a9"),
            UIColor(hex: "#175abe"),
            App.Color.azure
        ]

    }

    // MARK: - Fonts

    struct Font {

        static let titleAlts = regular(64)
        static let titleMedium = medium(34)
        static let titleSmall = medium(24)
        static let headline = medium(20)
        static let subheadAlts = medium(16)
        static let subhead = regular(16)
        static let subtitle = regular(16)
        static let navButton = medium(14)
        static let navButtonDisable = regular(14)
        static let bodyAlts = medium(14)
        static let body = regular(14)
        static let cardTitle = medium(14)
        static let button = medium(14)
        static let footnote = regular(13)
        static let captionAlts = medium(12)
        static let caption = regular(12)
        static let label = medium(12)
        static let buttonSmall = medium(12)

        // MARK: - Methods

        static func regular(_ size: CGFloat) -> UIFont {
            return UIFont(name: "Roboto-Regular", size: size) ??
                UIFont.systemFont(ofSize: size, weight: .regular)
        }

        static func medium(_ size: CGFloat) -> UIFont {
            return UIFont(name: "Roboto-Medium", size: size) ??
                UIFont.systemFont(ofSize: size, weight: .medium)
        }
    }

    // MARK: - Layout

    struct Layout {
        static let buttonHeight: CGFloat = 48
        static let tabBarHeight: CGFloat = 56

        static let sideOffset: CGFloat = 24
        static let itemSpacingSmall: CGFloat = 8
        static let itemSpacingMedium: CGFloat = 16
        static let itemSpacingBig: CGFloat = 21

        static let cornerRadius: CGFloat = 14
        static let cornerRadiusSmall: CGFloat = 8

        static let zPositionCommon: CGFloat = 5
    }

    // MARK: - Cell Identifiers

    struct CellIdentifier {

        // MARK: - Profile

        static let corporateResultsCellId = "corporateResultsCellId"
        static let educationResultsCellId = "educationResultsCellId"
        static let attestationResultsCellId = "attestationResultsCellId"

        static let kpiPlansCellId = "kpiPlansCellId"
        static let idpPlansCellId = "idpPlansCellId"
        static let vacationPlansCellId = "vacationPlansCellId"

        static let fitnessBenefitsCellId = "fitnessBenefitsCellId"
        static let accBenefitsCellId = "accBenefitsCellId"
        static let biClubBenefitsCellId = "biClubBenefitsCellId"
        static let biClubCollBenefitsCellId = "biClubCollBenefitsCellId"

        // MARK: - Employees

        static let employeeCellId = "employeeCellId"
        static let vacancyCellId = "vacancyCellId"

        // MARK: - Lenta

        static let lentaOverviewCellId = "lentaOverviewCellId"

        // MARK: - Notifications

        static let notificationsCellId = "notificationsCellId"

        // MARK: - Menu

        static let menuCellId = "menuCellId"

        // MARK: - Tasks And Requests

        static let taskOrReqeustCellId = "taskOrReqeustCellId"

        // MARK: - Common

        static let suggestionCellId = "suggestionCellId"
        static let checkboxCellId = "checkboxCellId"
        static let attachmentCellId = "attachmentCellId"
        static let imageCellId = "imageCellId"
        static let dummyCellId = "dummyCellId"

    }

    // MARK: - UserDefaults

    struct Key {
        static let userToken = "userToken"
        static let userLogin = "userLogin"
        static let userEmployeeCode = "userEmployeeCode"
        static let userProfile = "userProfile"
        static let userRoles = "userRoles"
    }

    // MARK: - Fields

    struct Field {
        static let `default` = "error"
        static let login = "Login"
        static let password = "Password"
    }

    // MARK: - Strings

    struct String {
        private static let devBaseUrl = "http://life.bi-group.org:8090"
        private static let prodBaseUrl = "https://life.bi-group.org"

        static var baseUrl: Swift.String {
            return Environment.current == .production ? prodBaseUrl : devBaseUrl
        }

        static var apiBaseUrl: Swift.String {
            return baseUrl + "/api"
        }
    }

    // MARK: - Environment

    enum Environment {
        case development
        case production

        static var current: Environment {
            return .development
        }
    }

    // MARK: - Realms & Configs

    struct RealmConfig {
        private static let schemaVersion: UInt64 = 5
        private static let docs = FileManager.default.urls(
            for: .documentDirectory, in: .userDomainMask).first!

        private static let migrationBlock: ((Migration, UInt64) -> Void) = { (migration, oldSchemaVersion) in
            print("Doing migration (\(migration)) the old schema version (\(oldSchemaVersion)")
        }

        static var `default`: Realm.Configuration {
            return Realm.Configuration(
                fileURL: docs.appendingPathComponent("Default.realm"),
                schemaVersion: schemaVersion,
                migrationBlock: migrationBlock)
        }

        static var birthdays: Realm.Configuration {
            return Realm.Configuration(
                fileURL: docs.appendingPathComponent("Birthdays.realm"),
                schemaVersion: schemaVersion,
                migrationBlock: migrationBlock)
        }

        static var inboxTasksAndRequests: Realm.Configuration {
            return Realm.Configuration(
                fileURL: docs.appendingPathComponent("InboxTasksAndRequests.realm"),
                schemaVersion: schemaVersion,
                migrationBlock: migrationBlock)
        }

        static var outboxTasksAndRequests: Realm.Configuration {
            return Realm.Configuration(
                fileURL: docs.appendingPathComponent("OutboxTasksAndRequests.realm"),
                schemaVersion: schemaVersion,
                migrationBlock: migrationBlock)
        }

        static var allQuestionnaires: Realm.Configuration {
            return Realm.Configuration(
                fileURL: docs.appendingPathComponent("AllQuestionnaires.realm"),
                schemaVersion: schemaVersion,
                migrationBlock: migrationBlock)
        }

        static var popularQuestionnaires: Realm.Configuration {
            return Realm.Configuration(
                fileURL: docs.appendingPathComponent("PopularQuestionnaires.realm"),
                schemaVersion: schemaVersion,
                migrationBlock: migrationBlock)
        }

        static var popularNews: Realm.Configuration {
            return Realm.Configuration(
                fileURL: docs.appendingPathComponent("PopularNews.realm"),
                schemaVersion: schemaVersion,
                migrationBlock: migrationBlock)
        }

        static var topNews: Realm.Configuration {
            return Realm.Configuration(
                fileURL: docs.appendingPathComponent("TopNews.realm"),
                schemaVersion: schemaVersion,
                migrationBlock: migrationBlock)
        }

        static var allSuggestions: Realm.Configuration {
            return Realm.Configuration(
                fileURL: docs.appendingPathComponent("AllSuggestions.realm"),
                schemaVersion: schemaVersion,
                migrationBlock: migrationBlock)
        }

        static var popularSuggestions: Realm.Configuration {
            return Realm.Configuration(
                fileURL: docs.appendingPathComponent("PopularSuggestions.realm"),
                schemaVersion: schemaVersion,
                migrationBlock: migrationBlock)
        }

        static var answers: Realm.Configuration {
            return Realm.Configuration(
                fileURL: docs.appendingPathComponent("Answers.realm"),
                schemaVersion: schemaVersion,
                migrationBlock: migrationBlock)
        }

        static var videoAnswers: Realm.Configuration {
            return Realm.Configuration(
                fileURL: docs.appendingPathComponent("VideoAnswers.realm"),
                schemaVersion: schemaVersion,
                migrationBlock: migrationBlock)
        }
    }

    struct Realms {
        static func `default`() throws -> Realm {
            do {
                let realm = try Realm(configuration: RealmConfig.default)
                return realm
            } catch {
                fatalError("Failed to initialize realm with configurations - \(RealmConfig.default)")
            }
        }

        static func birthdays() throws -> Realm {
            do {
                let realm = try Realm(configuration: RealmConfig.birthdays)
                return realm
            } catch {
                fatalError("Failed to initialize realm with configurations - \(RealmConfig.birthdays)")
            }
        }

        static func inboxTasksAndRequests() throws -> Realm {
            do {
                let realm = try Realm(configuration: RealmConfig.inboxTasksAndRequests)
                return realm
            } catch {
                fatalError(
                    "Failed to initialize realm with configurations - \(RealmConfig.inboxTasksAndRequests)"
                )
            }
        }

        static func outboxTasksAndRequests() throws -> Realm {
            do {
                let realm = try Realm(configuration: RealmConfig.outboxTasksAndRequests)
                return realm
            } catch {
                fatalError(
                    "Failed to initialize realm with configurations - \(RealmConfig.outboxTasksAndRequests)"
                )
            }
        }

        static func allQuestionnaires() throws -> Realm {
            do {
                let realm = try Realm(configuration: RealmConfig.allQuestionnaires)
                return realm
            } catch {
                fatalError(
                    "Failed to initialize realm with configurations - \(RealmConfig.allQuestionnaires)"
                )
            }
        }

        static func popularQuestionnaires() throws -> Realm {
            do {
                let realm = try Realm(configuration: RealmConfig.popularQuestionnaires)
                return realm
            } catch {
                fatalError(
                    "Failed to initialize realm with configurations - \(RealmConfig.popularQuestionnaires)"
                )
            }
        }

        static func popularNews() throws -> Realm {
            do {
                let realm = try Realm(configuration: RealmConfig.popularNews)
                return realm
            } catch {
                fatalError(
                    "Failed to initialize realm with configurations - \(RealmConfig.popularNews)"
                )
            }
        }

        static func topNews() throws -> Realm {
            do {
                let realm = try Realm(configuration: RealmConfig.topNews)
                return realm
            } catch {
                fatalError(
                    "Failed to initialize realm with configurations - \(RealmConfig.topNews)"
                )
            }
        }

        static func allSuggestions() throws -> Realm {
            do {
                let realm = try Realm(configuration: RealmConfig.allSuggestions)
                return realm
            } catch {
                fatalError(
                    "Failed to initialize realm with configurations - \(RealmConfig.allSuggestions)"
                )
            }
        }

        static func popularSuggestions() throws -> Realm {
            do {
                let realm = try Realm(configuration: RealmConfig.popularSuggestions)
                return realm
            } catch {
                fatalError(
                    "Failed to initialize realm with configurations - \(RealmConfig.popularSuggestions)"
                )
            }
        }

        static func answers() throws -> Realm {
            do {
                let realm = try Realm(configuration: RealmConfig.answers)
                return realm
            } catch {
                fatalError(
                    "Failed to initialize realm with configurations - \(RealmConfig.answers)"
                )
            }
        }

        static func videoAnswers() throws -> Realm {
            do {
                let realm = try Realm(configuration: RealmConfig.videoAnswers)
                return realm
            } catch {
                fatalError(
                    "Failed to initialize realm with configurations - \(RealmConfig.videoAnswers)"
                )
            }
        }
    }

}

// MARK: - Notifications

extension Foundation.Notification.Name {
    static let selectSuggestionsTab = Foundation.Notification.Name("selectSuggestionsTab")
    static let selectQuestionnairesTab = Foundation.Notification.Name("selectQuestionnairesTab")
}
