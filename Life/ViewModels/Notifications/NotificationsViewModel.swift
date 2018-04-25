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
import RxCocoa

class NotificationsViewModel: NSObject, ViewModel {
    private(set) var notifications = BehaviorRelay<[NotificationViewModel]>(value: [])

    private let disposeBag = DisposeBag()

    let loading = BehaviorRelay<Bool>(value: false)
    let onError = PublishSubject<Error>()

    private let provider = MoyaProvider<NotificationsService>(
        plugins: [
            AuthPlugin(tokenClosure: {
                return User.current.token
            })
        ]
    )

    convenience init(notifications: [NotificationViewModel]) {
        self.init()
        self.notifications.accept(notifications)
    }

    // MARK: - Methods

    public func getNotifications() {
        loading.accept(true)

        returnNotificationsFromCache()

        provider
            .rx
            .request(.notifications)
            .filterSuccessfulStatusCodes()
            .subscribe { response in
                self.loading.accept(false)

                switch response {
                case .success(let json):
                    if let notifications = try? JSONDecoder().decode(
                        [Notification].self, from: json.data) {
                        self.notifications.accept(
                            notifications.map { NotificationViewModel(notification: $0) }
                        )

                        self.updateNotificationsCache(notifications)
                    }
                case .error(let error):
                    self.onError.onNext(error)
                }
            }
            .disposed(by: disposeBag)
    }

    public func readNotification(_ id: String) {
        self.notifications.accept(
            self.notifications.value.filter { $0.notification.id != id }
        )

        provider
            .rx
            .request(.readNotification(id: id))
            .filterSuccessfulStatusCodes()
            .subscribe { response in
                switch response {
                case .success:
                    self.deleteNotificationFromCache(id)
                case .error(let error):
                    self.onError.onNext(error)
                }
            }
            .disposed(by: disposeBag)
    }

    private func returnNotificationsFromCache() {
        DispatchQueue.global().async {
            do {
                let realm = try App.Realms.notifications()
                let cachedTaskObjects = realm.objects(NotificationObject.self)

                let cachedTasks = Array(cachedTaskObjects).map { Notification(managedObject: $0) }
                let items = cachedTasks.map { NotificationViewModel(notification: $0) }

                DispatchQueue.main.async {
                    if !items.isEmpty {
                        self.loading.accept(false)
                    }

                    self.notifications.accept(items)
                }
            } catch let error as NSError {
                print("Failed to access the Realm database with error - \(error.localizedDescription)")
            }
        }
    }

    private func updateNotificationsCache(_ notificationItems: [Notification]) {
        DispatchQueue.global().async {
            do {
                let realm = try App.Realms.notifications()
                realm.beginWrite()
                realm.delete(realm.objects(NotificationObject.self))
                for notification in notificationItems {
                    realm.add(notification.managedObject(), update: true)
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
                let realm = try App.Realms.notifications()
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
