//
//  NotificationsViewModel.swift
//  Life
//
//  Created by Shyngys Kassymov on 17.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation

struct NotificationsViewModel: ViewModel {
    var notifications = [NotificationViewModel]()
}

extension NotificationsViewModel: Mockable {
    typealias T = NotificationsViewModel

    static func sample() -> NotificationsViewModel {
        var notificationsViewModel = NotificationsViewModel()

        let notification = NotificationViewModel(
            title: "Type something notification",
            date: "5 minutes ago",
            image: ""
        )
        notificationsViewModel.notifications = [
            notification,
            notification,
            notification,
            notification
        ]

        return notificationsViewModel
    }
}

struct NotificationViewModel: ViewModel {
    var title: String
    var date: String
    var image: String
}
