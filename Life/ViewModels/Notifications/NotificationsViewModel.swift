//
//  NotificationsViewModel.swift
//  Life
//
//  Created by Shyngys Kassymov on 17.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation
import Moya
import RealmSwift
import RxSwift

class NotificationsViewModel: NSObject, ViewModel {
    private(set) var notifications = [NotificationViewModel]()

    private let disposeBag = DisposeBag()

    private let provider = MoyaProvider<NotificationsService>(
        plugins: [
            AuthPlugin(tokenClosure: {
                return User.current.token
            })
        ]
    )

    convenience init(notifications: [NotificationViewModel]) {
        self.init()
        self.notifications = notifications
    }

    // MARK: - Methods

    public func getNotifications(completion: @escaping ((Error?) -> Void)) {
        returnNotificationsFromCache(completion: completion)

        provider
            .rx
            .request(.notifications)
            .filterSuccessfulStatusCodes()
            .subscribe { response in
                switch response {
                case .success(let json):
                    if let notifications = try? JSONDecoder().decode(
                        [Notification].self, from: json.data) {
                        self.notifications = notifications.map { NotificationViewModel(notification: $0) }

                        completion(nil)

                        self.updateNotificationsCache(notifications)
                    } else {
                        completion(nil)
                    }
                case .error(let error):
                    completion(error)
                }
            }
            .disposed(by: disposeBag)
    }

    public func readNotification(_ id: String, completion: @escaping ((Error?) -> Void)) {
        notifications = notifications.filter { $0.notification.id != id }

        provider
            .rx
            .request(.readNotification(id: id))
            .filterSuccessfulStatusCodes()
            .subscribe { response in
                switch response {
                case .success:
                    completion(nil)

                    self.deleteNotificationFromCache(id)
                case .error(let error):
                    completion(error)
                }
            }
            .disposed(by: disposeBag)
    }

    private func returnNotificationsFromCache(completion: @escaping ((Error?) -> Void)) {
        DispatchQueue.global().async {
            do {
                let realm = try App.Realms.default()
                let cachedTaskObjects = realm.objects(NotificationObject.self)

                let cachedTasks = Array(cachedTaskObjects).map { Notification(managedObject: $0) }
                let items = cachedTasks.map { NotificationViewModel(notification: $0) }

                self.notifications = items

                DispatchQueue.main.async {
                    completion(nil)
                }
            } catch let error as NSError {
                print("Failed to access the Realm database with error - \(error.localizedDescription)")
            }
        }
    }

    private func updateNotificationsCache(_ notificationItems: [Notification]) {
        DispatchQueue.global().async {
            do {
                let realm = try App.Realms.default()
                realm.beginWrite()
                for notification in notificationItems {
                    realm.add(notification.managedObject(), update: true)
                }
                for notificationObject in realm.objects(NotificationObject.self).reversed() {
                    if !notificationItems.contains(Notification(managedObject: notificationObject)),
                        let notificationObjectToDelete = realm.object(
                            ofType: NotificationObject.self,
                            forPrimaryKey: notificationObject.id) {
                        realm.delete(notificationObjectToDelete)
                    }
                }
                try realm.commitWrite()
            } catch {
                print("Failed to access the Realm database")
            }
        }
    }

    private func deleteNotificationFromCache(_ id: String) {
        DispatchQueue.global().async {
            do {
                let realm = try App.Realms.default()
                realm.beginWrite()
                if let notificationObjectToDelete = realm.object(
                    ofType: NotificationObject.self,
                    forPrimaryKey: id) {
                    realm.delete(notificationObjectToDelete)
                }
                try realm.commitWrite()
            } catch {
                print("Failed to access the Realm database")
            }
        }
    }
}

extension NotificationsViewModel: Mockable {
    typealias T = NotificationsViewModel

    static func sample() -> NotificationsViewModel {
        var notifications = [NotificationViewModel]()
        for _ in 0..<5 {
            let json = [
                "id": UUID().uuidString,
                "message": "Создано предложение",
                "eventType": 40,
                "authorCode": "KPO102505",
                "authorName": "Жакупова Арайлым Биржанкызы",
                "createDate": "2018-02-14T10:32:03.76",
                "entityId": "0fd1878c-ef2c-4eb5-9801-6b9d56dca642"
                ] as [String : Any]
            if let notification = try? JSONDecoder().decode(Notification.self, from: json.toJSONData()) {
                notifications.append(NotificationViewModel(notification: notification))
            }
        }

        return NotificationsViewModel(notifications: notifications)
    }
}

struct NotificationViewModel: ViewModel {
    var notification: Notification
}
