//
//  TaskFormViewModel.swift
//  Life
//
//  Created by Shyngys Kassymov on 06.03.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation
import IGListKit
import Moya
import RxSwift

class TaskFormViewModel: NSObject {

    private(set) unowned var employeesViewModel: EmployeesViewModel

    private let disposeBag = DisposeBag()

    let taskCreateIsPendingSubject = PublishSubject<Bool>()
    let taskCreatedSubject = PublishSubject<Int>()
    let taskCreatedWithErrorSubject = PublishSubject<Error>()

    var executor: Employee?

    let topicText = BehaviorSubject<String>(value: "")
    let taskText = BehaviorSubject<String>(value: "")
    let startDate = BehaviorSubject<Date>(value: Date())
    let endDate = BehaviorSubject<Date>(value: Date())
    let isAllDay = BehaviorSubject<Bool>(value: false)
    let reminder = BehaviorSubject<Int>(value: Task.Reminder.thirtyMins.rawValue)
    let attachments = BehaviorSubject<[URL]>(value: [])
    let type = BehaviorSubject<Int>(value: Task.TaskType.execute.rawValue)

    var participants = Set<Employee>()

    private let tasksProvider = MoyaProvider<TasksService>(
        plugins: [
            AuthPlugin(tokenClosure: {
                return User.current.token
            })
        ]
    )

    init(employeesViewModel: EmployeesViewModel) {
        self.employeesViewModel = employeesViewModel
    }

    // MARK: - Methods

    public func createTask() {
        guard let executor = executor,
            let topic = try? topicText.value(),
            let description = try? taskText.value(),
            let startDate = try? startDate.value(),
            let endDate = try? endDate.value(),
            let isAllDay = try? isAllDay.value(),
            let reminder = try? reminder.value(),
            let attachments = try? attachments.value(),
            let type = try? type.value() else {
                return
        }

        let participants = self.participants.map { $0.code }

        taskCreateIsPendingSubject.onNext(true)
        tasksProvider
            .rx
            .request(.createTask(
                executorCode: executor.code,
                topic: topic,
                description: description,
                isAllDay: isAllDay,
                location: "",
                startDateTime: startDate.serverDate,
                endDateTime: endDate.serverDate,
                reminder: reminder,
                participants: participants,
                type: type,
                attachments: attachments
                ))
            .filterSuccessfulStatusCodes()
            .subscribe { response in
                self.taskCreateIsPendingSubject.onNext(false)
                switch response {
                case .success(let json):
                    self.taskCreatedSubject.onNext(json.statusCode)
                case .error(let error):
                    self.taskCreatedWithErrorSubject.onNext(error)
                }
            }
            .disposed(by: disposeBag)
    }

}
