//
//  TaskFormView.swift
//  Life
//
//  Created by Shyngys Kassymov on 05.03.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import Material
import SnapKit
import TTGTagCollectionView

class TaskFormView: UIView {

    private(set) lazy var headerView = NotificationHeaderView(
        image: nil,
        title: NSLocalizedString("new_task", comment: ""),
        subtitle: nil
    )
    private(set) lazy var scrollView = UIScrollView()
    private(set) lazy var contentView = UIView()
    private(set) lazy var topicField = TextField(frame: .zero)
    private(set) lazy var isAllDayButton = FlatButton(
        title: NSLocalizedString("all_day", comment: ""),
        titleColor: App.Color.steel
    )
    private(set) lazy var reminderField = TextField(frame: .zero)
    private(set) lazy var startDateField = TextField(frame: .zero)
    private(set) lazy var endDateField = TextField(frame: .zero)
    private(set) lazy var executorField = TextField(frame: .zero)
    private(set) lazy var participantsField = TextField(frame: .zero)
    private(set) lazy var tagsCollectionView = TTGTextTagCollectionView()
    private(set) lazy var typeField = TextField(frame: .zero)
    private(set) lazy var textField = TextView(frame: .zero)
    private(set) lazy var attachmentsView = AttachmentsView()
    private(set) lazy var addAttachmentButton = FlatButton(
        title: NSLocalizedString("attach", comment: ""),
        titleColor: UIColor.black
    )
    private(set) lazy var sendButton = Button(
        title: NSLocalizedString("send", comment: "").uppercased()
    )

    private var attachmentButtonTopConstraint: Constraint?

    var didDeleteParticipant: ((String) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Methods

    public func add(attachments: [Attachment]) {
        if attachmentsView.isHidden {
            attachmentsView.isHidden = false

            let offset = AttachmentCollectionViewCell.height() + 2 * App.Layout.itemSpacingSmall
            attachmentButtonTopConstraint?.update(offset: offset)
        }

        attachmentsView.add(attachments: attachments)
    }

    // MARK: - UI

    private func setupUI() {
        setupHeaderView()
        setupScrollView()
    }

    private func setupHeaderView() {
        addSubview(headerView)
        headerView.snp.makeConstraints { (make) in
            make.top.equalTo(self)
            make.left.equalTo(self)
            make.right.equalTo(self)
        }
    }

    private func setupScrollView() {
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = false
        addSubview(scrollView)
        scrollView.snp.makeConstraints { (make) in
            make.top.equalTo(self.headerView.snp.bottom)
            make.left.equalTo(self)
            make.bottom.equalTo(self)
            make.right.equalTo(self)
        }

        setupContentView()
    }

    private func setupContentView() {
        scrollView.addSubview(contentView)
        sendSubview(toBack: scrollView)
        contentView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.scrollView)
            make.width.equalTo(self.scrollView)
        }

        setupTopicField()
        setupReminderField()
        setupIsAllDayButton()
        setupStartDateField()
        setupEndDateField()
        setupExecutorField()
        setupParticipantsField()
        setupTagsCollectionView()
        setupTypeField()
        setupTextField()
        setupAttachmentsView()
        setupAddAttachmentButton()
        setupSendButton()
    }

    private func setupTopicField() {
        topicField.placeholder = NSLocalizedString("topic", comment: "")
        contentView.addSubview(topicField)
        topicField.snp.makeConstraints { (make) in
            make.top.equalTo(self.contentView).inset(App.Layout.sideOffset)
            make.left.equalTo(self.contentView).inset(App.Layout.sideOffset)
            make.right.equalTo(self.contentView).inset(App.Layout.sideOffset)
        }
    }

    private func setupReminderField() {
        let detailView = UIImageView(frame: .init(x: 0, y: 0, width: 24, height: 8))
        detailView.contentMode = .scaleAspectFit
        detailView.tintColor = App.Color.silver
        detailView.image = #imageLiteral(resourceName: "expand_arrow")

        reminderField.placeholder = NSLocalizedString("reminder", comment: "")
        reminderField.rightView = detailView
        reminderField.rightViewMode = .always
        let reminders = Task.Reminder.all().map { $0.name }
        let selectedIdx = reminders.index(of: Task.Reminder.thirtyMins.name) ?? -1
        reminderField.setAsPicker(with: reminders, setText: true, selectedIdx: selectedIdx)
        contentView.addSubview(reminderField)
        reminderField.snp.makeConstraints { (make) in
            make.top.equalTo(self.topicField.snp.bottom).offset(App.Layout.sideOffset)
            make.right.equalTo(self.contentView).inset(App.Layout.sideOffset)
        }
    }

    private func setupIsAllDayButton() {
        isAllDayButton.setImage(#imageLiteral(resourceName: "checkbox_empty"), for: .normal)
        isAllDayButton.setImage(#imageLiteral(resourceName: "checkbox_tick"), for: .selected)
        isAllDayButton.setImage(#imageLiteral(resourceName: "checkbox_tick"), for: .highlighted)
        isAllDayButton.tintColor = App.Color.coolGrey
        isAllDayButton.titleEdgeInsets = .init(top: 0, left: 4, bottom: 0, right: 0)
        isAllDayButton.titleLabel?.font = App.Font.caption
        isAllDayButton.titleLabel?.textColor = App.Color.steel
        isAllDayButton.contentHorizontalAlignment = .left
        contentView.addSubview(isAllDayButton)
        isAllDayButton.snp.makeConstraints { (make) in
            make.left.equalTo(self.contentView).inset(App.Layout.sideOffset)
            make.right.equalTo(self.reminderField.snp.left).offset(-App.Layout.itemSpacingSmall)
            make.height.equalTo(40)
            make.width.equalTo(self.reminderField)
            make.centerY.equalTo(self.reminderField)
        }
    }

    private func setupStartDateField() {
        startDateField.placeholder = NSLocalizedString("start_date", comment: "")
        startDateField.setAsDatePicker()
        contentView.addSubview(startDateField)
        startDateField.snp.makeConstraints { (make) in
            make.top.equalTo(self.reminderField.snp.bottom).offset(App.Layout.sideOffset)
            make.left.equalTo(self.contentView).inset(App.Layout.sideOffset)
            make.right.equalTo(self.contentView).inset(App.Layout.sideOffset)
        }
    }

    private func setupEndDateField() {
        endDateField.placeholder = NSLocalizedString("end_date", comment: "")
        endDateField.setAsDatePicker()
        contentView.addSubview(endDateField)
        endDateField.snp.makeConstraints { (make) in
            make.top.equalTo(self.startDateField.snp.bottom).offset(App.Layout.sideOffset)
            make.left.equalTo(self.contentView).inset(App.Layout.sideOffset)
            make.right.equalTo(self.contentView).inset(App.Layout.sideOffset)
        }
    }

    private func setupExecutorField() {
        let detailView = UIImageView(frame: .init(x: 0, y: 0, width: 24, height: 8))
        detailView.contentMode = .scaleAspectFit
        detailView.tintColor = App.Color.silver
        detailView.image = #imageLiteral(resourceName: "expand_arrow")

        executorField.placeholder = NSLocalizedString("select_executor", comment: "")
        executorField.rightView = detailView
        executorField.rightViewMode = .always
        contentView.addSubview(executorField)
        executorField.snp.makeConstraints { (make) in
            make.top.equalTo(self.endDateField.snp.bottom).offset(App.Layout.sideOffset)
            make.left.equalTo(self.contentView).inset(App.Layout.sideOffset)
            make.right.equalTo(self.contentView).inset(App.Layout.sideOffset)
        }
    }

    private func setupParticipantsField() {
        let detailView = UIImageView(frame: .init(x: 0, y: 0, width: 24, height: 8))
        detailView.contentMode = .scaleAspectFit
        detailView.tintColor = App.Color.silver
        detailView.image = #imageLiteral(resourceName: "expand_arrow")

        participantsField.placeholder = NSLocalizedString("add_participants", comment: "")
        participantsField.rightView = detailView
        participantsField.rightViewMode = .always
        contentView.addSubview(participantsField)
        participantsField.snp.makeConstraints { (make) in
            make.top.equalTo(self.executorField.snp.bottom).offset(App.Layout.sideOffset)
            make.left.equalTo(self.contentView).inset(App.Layout.sideOffset)
            make.right.equalTo(self.contentView).inset(App.Layout.sideOffset)
        }
    }

    private func setupTagsCollectionView() {
        tagsCollectionView.delegate = self
        tagsCollectionView.showsVerticalScrollIndicator = false
        tagsCollectionView.horizontalSpacing = 6.0
        tagsCollectionView.verticalSpacing = 8.0
        contentView.addSubview(tagsCollectionView)

        let config = tagsCollectionView.defaultConfig
        config?.tagTextFont = App.Font.body
        config?.tagTextColor = .white
        config?.tagSelectedTextColor = .white
        config?.tagBackgroundColor = App.Color.azure
        config?.tagSelectedBackgroundColor = App.Color.azure
        config?.tagBorderColor = .clear
        config?.tagSelectedBorderColor = .clear
        config?.tagBorderWidth = 0
        config?.tagSelectedBorderWidth = 0
        config?.tagShadowColor = .clear
        config?.tagShadowOffset = .zero
        config?.tagShadowOpacity = 0
        config?.tagShadowRadius = 0
        config?.tagCornerRadius = App.Layout.cornerRadiusSmall / 2

        tagsCollectionView.snp.makeConstraints { (make) in
            make.top
                .equalTo(self.participantsField.snp.bottom)
                .offset(App.Layout.itemSpacingSmall)
            make.left.equalTo(self.contentView).inset(App.Layout.sideOffset)
            make.right.equalTo(self.contentView).inset(App.Layout.sideOffset)
        }
    }

    private func setupTypeField() {
        let detailView = UIImageView(frame: .init(x: 0, y: 0, width: 24, height: 8))
        detailView.contentMode = .scaleAspectFit
        detailView.tintColor = App.Color.silver
        detailView.image = #imageLiteral(resourceName: "expand_arrow")

        typeField.placeholder = NSLocalizedString("task_type", comment: "")
        typeField.rightView = detailView
        typeField.rightViewMode = .always
        let taskTypes = Task.TaskType.all().map { $0.name }
        let selectedIdx = taskTypes.index(of: Task.TaskType.execute.name) ?? -1
        typeField.setAsPicker(with: taskTypes, setText: true, selectedIdx: selectedIdx)
        contentView.addSubview(typeField)
        typeField.snp.makeConstraints { (make) in
            make.top.equalTo(self.tagsCollectionView.snp.bottom).offset(App.Layout.itemSpacingMedium)
            make.left.equalTo(self.contentView).inset(App.Layout.sideOffset)
            make.right.equalTo(self.contentView).inset(App.Layout.sideOffset)
        }
    }

    private func setupTextField() {
        textField.backgroundColor = App.Color.paleGrey
        textField.layer.borderColor = App.Color.coolGrey.cgColor
        textField.layer.borderWidth = 0.5
        textField.layer.cornerRadius = App.Layout.cornerRadius
        textField.layer.masksToBounds = true
        textField.placeholder = NSLocalizedString("write_text", comment: "")
        textField.textContainerInsets = EdgeInsets(
            top: 14,
            left: App.Layout.itemSpacingMedium,
            bottom: 14,
            right: App.Layout.itemSpacingMedium
        )
        contentView.addSubview(textField)
        textField.snp.makeConstraints { (make) in
            make.top.equalTo(self.typeField.snp.bottom).offset(App.Layout.itemSpacingBig)
            make.left.equalTo(self.contentView).inset(App.Layout.sideOffset)
            make.right.equalTo(self.contentView).inset(App.Layout.sideOffset)
            make.height.equalTo(71)
        }
    }

    private func setupAttachmentsView() {
        attachmentsView.isHidden = true
        contentView.addSubview(attachmentsView)
        attachmentsView.snp.makeConstraints { (make) in
            make.top.equalTo(self.textField.snp.bottom).offset(App.Layout.itemSpacingSmall)
            make.left.equalTo(self.contentView)
            make.right.equalTo(self.contentView)
        }
    }

    private func setupAddAttachmentButton() {
        addAttachmentButton.image = #imageLiteral(resourceName: "attach-file")
        addAttachmentButton.tintColor = App.Color.steel
        addAttachmentButton.titleEdgeInsets = .init(top: 0, left: 4, bottom: 0, right: 0)
        addAttachmentButton.titleLabel?.font = App.Font.subheadAlts
        addAttachmentButton.titleLabel?.textColor = .black
        addAttachmentButton.contentHorizontalAlignment = .left
        contentView.addSubview(addAttachmentButton)
        addAttachmentButton.snp.makeConstraints { (make) in
            self.attachmentButtonTopConstraint = make.top.equalTo(self.textField.snp.bottom).offset(App.Layout.itemSpacingSmall).constraint
            make.left.equalTo(self.contentView).inset(App.Layout.sideOffset)
            make.right.equalTo(self.contentView).inset(App.Layout.sideOffset)
            make.height.equalTo(40)
        }
    }

    private func setupSendButton() {
        contentView.addSubview(sendButton)
        sendButton.snp.makeConstraints { (make) in
            make.top.equalTo(self.addAttachmentButton.snp.bottom).offset(App.Layout.itemSpacingMedium)
            make.left.equalTo(self.contentView).inset(App.Layout.sideOffset)
            make.bottom.equalTo(self.contentView).inset(App.Layout.sideOffset)
            make.right.equalTo(self.contentView).inset(App.Layout.sideOffset)
        }
    }

}

extension TaskFormView: TTGTextTagCollectionViewDelegate {
    //swiftlint:disable line_length
    func textTagCollectionView(_ textTagCollectionView: TTGTextTagCollectionView!, didTapTag tagText: String!, at index: UInt, selected: Bool) {
        textTagCollectionView.removeTag(at: index)

        if let didDeleteParticipant = didDeleteParticipant {
            didDeleteParticipant(tagText)
        }
    }
    //swiftlint:enable line_length
}
