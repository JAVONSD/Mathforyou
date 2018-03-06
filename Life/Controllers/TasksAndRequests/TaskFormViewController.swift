//
//  TaskFormViewController.swift
//  Life
//
//  Created by Shyngys Kassymov on 05.03.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import FileProvider
import RxSwift
import RxCocoa
import SnapKit
import UITextField_AutoSuggestion

class TaskFormViewController: UIViewController, Stepper {

    private(set) lazy var taskFormView = TaskFormView(frame: .zero)

    private(set) var viewModel: TaskFormViewModel

    let disposeBag = DisposeBag()

    var didCreateTask: (() -> Void)?

    init(viewModel: TaskFormViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    // MARK: - Methods

    private func pickAttachments() {
        let fileExplorer = FileExplorerViewController()
        fileExplorer.canChooseFiles = true
        fileExplorer.allowsMultipleSelection = true
        fileExplorer.delegate = self
        fileExplorer.fileFilters = [
            Filter.extension("png"),
            Filter.extension("jpg"),
            Filter.extension("jpeg")
        ]
        self.present(fileExplorer, animated: true, completion: nil)
    }

    // MARK: - UI

    private func setupUI() {
        view.backgroundColor = .white

        setupQuestionFormView()
    }

    private func setupQuestionFormView() {
        view.addSubview(taskFormView)
        taskFormView.snp.makeConstraints { (make) in
            make.top.equalTo(self.topLayoutGuide.snp.bottom)
            make.left.equalTo(self.view)
            make.bottom.equalTo(self.view)
            make.right.equalTo(self.view)
        }

        bindCloseButton()
        bindTopicField()
        bindIsAllDayButton()
        bindReminderField()
        bindStartDateField()
        bindEndDateField()
        bindExecutorAndParticipantsFields()
        bindTypeField()
        bindTextField()
        bindAttachmentButton()
        bindSendButton()
        bindOnRequestFinish()
    }

    private func bindOnRequestFinish() {
        viewModel.taskCreatedSubject.subscribe(onNext: { [weak self] statusCode in
            guard let `self` = self else { return }
            if statusCode == 200 {
                self.step.accept(AppStep.createTaskDone)
                if let didCreateTask = self.didCreateTask {
                    didCreateTask()
                }
            }
        }).disposed(by: disposeBag)
        viewModel.taskCreatedWithErrorSubject.subscribe(onNext: { [weak self] error in
            guard let `self` = self else { return }
            let errorMessages = error.parseMessages()
            if let key = errorMessages.keys.first,
                let message = errorMessages[key] {
                self.showToast(message)
            }
        }).disposed(by: disposeBag)
    }

    private func bindCloseButton() {
        taskFormView.headerView.closeButton?.rx.tap
            .asDriver()
            .throttle(0.5)
            .drive(onNext: { [weak self] in
                self?.step.accept(AppStep.createTaskDone)
            })
            .disposed(by: disposeBag)
    }

    private func bindTopicField() {
        taskFormView.topicField.rx
            .text
            .orEmpty
            .bind(to: viewModel.topicText)
            .disposed(by: disposeBag)
    }

    private func bindIsAllDayButton() {
        taskFormView.isAllDayButton
            .rx
            .tap
            .asDriver()
            .drive(onNext: { [weak self] in
                let isAllDayButton = self?.taskFormView.isAllDayButton
                let isAllDay = isAllDayButton?.isSelected ?? false
                isAllDayButton?.isSelected = !isAllDay
                isAllDayButton?.tintColor = !isAllDay ? App.Color.azure : App.Color.coolGrey
                self?.viewModel.isAllDay.onNext(!isAllDay)
            })
            .disposed(by: disposeBag)
    }

    private func bindReminderField() {
        taskFormView.reminderField.rx
            .text
            .orEmpty
            .subscribe(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                let reminders = Task.Reminder.all()
                let idx = self.taskFormView.reminderField.pickerView.selectedRow(inComponent: 0)
                self.viewModel.reminder.onNext(reminders[idx].rawValue)
            })
            .disposed(by: disposeBag)
    }

    private func bindStartDateField() {
        taskFormView.startDateField.rx
            .text
            .orEmpty
            .subscribe(onNext: { [weak self] text in
                guard let `self` = self else { return }
                let date = self.taskFormView.startDateField.dateFormatter.date(from: text) ?? Date()
                self.viewModel.startDate.onNext(date)
            })
            .disposed(by: disposeBag)
    }

    private func bindEndDateField() {
        taskFormView.endDateField.rx
            .text
            .orEmpty
            .subscribe(onNext: { [weak self] text in
                guard let `self` = self else { return }
                let date = self.taskFormView.endDateField.dateFormatter.date(from: text) ?? Date()
                self.viewModel.endDate.onNext(date)
            })
            .disposed(by: disposeBag)
    }

    private func bindExecutorAndParticipantsFields() {
        if viewModel.employeesViewModel.employees.isEmpty {
            viewModel.employeesViewModel.getEmployees(completion: { _ in
            })
        }

        viewModel.employeesViewModel.itemsChangeSubject.subscribe(onNext: { [weak self] _ in
            self?.taskFormView.participantsField.reloadContents()
            if self?.taskFormView.participantsField.isFirstResponder ?? false {
                self?.taskFormView.participantsField.setLoading(
                    self?.viewModel.employeesViewModel.loading ?? false
                )
            }

            self?.taskFormView.executorField.reloadContents()
            if self?.taskFormView.executorField.isFirstResponder ?? false {
                self?.taskFormView.executorField.setLoading(
                    self?.viewModel.employeesViewModel.loading ?? false
                )
            }
        }).disposed(by: disposeBag)

        taskFormView.didDeleteParticipant = { [weak self] fullname in
            guard let `self` = self else { return }
            self.viewModel.participants = self.viewModel.participants.filter({ employee -> Bool in
                return employee.fullname != fullname
            })
        }

        taskFormView.participantsField.autoSuggestionDataSource = self
        taskFormView.participantsField.observeChanges()

        taskFormView.executorField.autoSuggestionDataSource = self
        taskFormView.executorField.observeChanges()
    }

    private func bindTypeField() {
        taskFormView.typeField.rx
            .text
            .orEmpty
            .subscribe(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                let taskTypes = Task.TaskType.all()
                let idx = self.taskFormView.typeField.pickerView.selectedRow(inComponent: 0)
                self.viewModel.reminder.onNext(taskTypes[idx].rawValue)
            })
            .disposed(by: disposeBag)
    }

    private func bindTextField() {
        taskFormView.textField.rx
            .text
            .orEmpty
            .bind(to: viewModel.taskText)
            .disposed(by: disposeBag)
    }

    private func bindAttachmentButton() {
        taskFormView.addAttachmentButton.rx.tap.asDriver().throttle(0.5).drive(onNext: { [weak self] in
            self?.pickAttachments()
        }).disposed(by: disposeBag)
    }

    private func bindSendButton() {
        viewModel.taskCreateIsPendingSubject.subscribe(onNext: { [weak self] isPending in
            guard let `self` = self else { return }
            self.taskFormView.sendButton.buttonState = isPending ? .loading : .normal
        }).disposed(by: disposeBag)

        taskFormView.sendButton.rx.tap.asDriver().throttle(0.5).drive(onNext: { [weak self] in
            self?.viewModel.createTask()
        }).disposed(by: disposeBag)
    }

}

extension TaskFormViewController: FileExplorerViewControllerDelegate {
    func fileExplorerViewControllerDidFinish(_ controller: FileExplorerViewController) {
        print("File explorer did finish ...")
    }

    func fileExplorerViewController(_ controller: FileExplorerViewController, didChooseURLs urls: [URL]) {
        print("Attached files with urls - \(urls)")
        viewModel.attachments.onNext(urls)
    }
}

//swiftlint:disable line_length
extension TaskFormViewController: UITextFieldAutoSuggestionDataSource {
    func autoSuggestionField(_ field: UITextField!, tableView: UITableView!, cellForRowAt indexPath: IndexPath!, forText text: String!) -> UITableViewCell! {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: App.CellIdentifier.suggestionCellId)

        let cell = tableView.dequeueReusableCell(withIdentifier: App.CellIdentifier.suggestionCellId, for: indexPath)
        let employees = viewModel.employeesViewModel.filteredEmployees
        if employees.count > indexPath.row {
            cell.textLabel?.text = employees[indexPath.row].employee.fullname
        }
        return cell
    }

    func autoSuggestionField(_ field: UITextField!, tableView: UITableView!, numberOfRowsInSection section: Int, forText text: String!) -> Int {
        return viewModel.employeesViewModel.filteredEmployees.count
    }

    func autoSuggestionField(_ field: UITextField!, tableView: UITableView!, didSelectRowAt indexPath: IndexPath!, forText text: String!) {
        let employees = viewModel.employeesViewModel.filteredEmployees
        if employees.count > indexPath.row {
            if field == taskFormView.participantsField {
                viewModel.participants.insert(employees[indexPath.row].employee)
                taskFormView.tagsCollectionView.addTag(employees[indexPath.row].employee.fullname)
                taskFormView.participantsField.text = nil
            } else {
                viewModel.executor = employees[indexPath.row].employee
                taskFormView.executorField.text = employees[indexPath.row].employee.fullname
            }
        }
    }

    func autoSuggestionField(_ field: UITextField!, textChanged text: String!) {
        viewModel.employeesViewModel.filter(with: text)
    }
}
//swiftlint:enable line_length
