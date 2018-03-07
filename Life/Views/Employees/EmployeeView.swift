//
//  EmployeeView.swift
//  Life
//
//  Created by Shyngys Kassymov on 21.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import Kingfisher
import Material
import SnapKit

class EmployeeView: UIView {

    private(set) var headerView: NotificationHeaderView?
    private(set) var employeeHeaderView: EmployeeHeaderView?
    private(set) var scrollView: StackedScrollView?

    private(set) var positionView: ImageTextView?
    private(set) var administrativeChiefView: ImageTextView?
    private(set) var functionalChiefView: ImageTextView?
    private(set) var birthdateView: ImageTextView?
    private(set) var phoneView: ImageTextView?
    private(set) var emailButton: ImageTextButton?

    var didTapCloseButton: (() -> Void)?
    var didTapCallButton: (() -> Void)?
    var didTapEmailButton: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var image: String = "" {
        didSet {
            ImageDownloader.set(
                image: "",
                employeeCode: image,
                to: employeeHeaderView?.imageView
            )
        }
    }

    var fullname: String = "" {
        didSet {
            employeeHeaderView?.titleLabel?.text = fullname.onEmpty(
                NSLocalizedString("no_data", comment: ""))
        }
    }

    var position: String = "" {
        didSet {
            positionView?.subtitleLabel?.text = position.onEmpty(
                NSLocalizedString("no_data", comment: ""))
        }
    }

    var birthdate: String = "" {
        didSet {
            birthdateView?.subtitleLabel?.text = birthdate.onEmpty(
                NSLocalizedString("no_data", comment: ""))
        }
    }

    var administrativeChief: String = "" {
        didSet {
            administrativeChiefView?.subtitleLabel?.text = administrativeChief.onEmpty(
                NSLocalizedString("no_data", comment: ""))
        }
    }

    var functionalChief: String = "" {
        didSet {
            functionalChiefView?.subtitleLabel?.text = functionalChief.onEmpty(
                NSLocalizedString("no_data", comment: ""))
        }
    }

    var phone: String = "" {
        didSet {
            phoneView?.subtitleLabel?.text = phone.onEmpty(
                NSLocalizedString("no_data", comment: ""))
        }
    }

    var email: String = "" {
        didSet {
            emailButton?.view?.subtitleLabel?.text = email.onEmpty(
                NSLocalizedString("no_data", comment: ""))
        }
    }

    // MARK: - Actions

    @objc
    private func handleCloseButton() {
        if let didTapCloseButton = didTapCloseButton {
            didTapCloseButton()
        }
    }

    @objc
    private func handleCallButton() {
        if let didTapCallButton = didTapCallButton {
            didTapCallButton()
        }
    }

    @objc
    private func handleEmailButton() {
        if let didTapEmailButton = didTapEmailButton {
            didTapEmailButton()
        }
    }

    // MARK: - UI

    private func setupUI() {
        setupHeader()
        setupEmployeeHeader()
        setupScroll()
    }

    private func setupHeader() {
        headerView = NotificationHeaderView(
            image: nil,
            title: NSLocalizedString("employee", comment: ""),
            subtitle: nil
        )
        headerView?.closeButton?.addTarget(self, action: #selector(handleCloseButton), for: .touchUpInside)

        guard let headerView = headerView else { return }

        addSubview(headerView)
        headerView.snp.makeConstraints { (make) in
            make.top.equalTo(self)
            make.left.equalTo(self)
            make.right.equalTo(self)
        }
    }

    private func setupEmployeeHeader() {
        employeeHeaderView = EmployeeHeaderView(image: nil, title: "Фамилия\nИмя", subtitle: nil)

        guard let headerView = headerView,
            let employeeHeaderView = employeeHeaderView else { return }

        employeeHeaderView.callButton?.addTarget(
            self, action: #selector(handleCallButton), for: .touchUpInside)

        addSubview(employeeHeaderView)
        employeeHeaderView.snp.makeConstraints { (make) in
            make.top.equalTo(headerView.snp.bottom)
            make.left.equalTo(self)
            make.right.equalTo(self)
        }
    }

    private func setupScroll() {
        scrollView = StackedScrollView(direction: .vertical)

        guard let scrollView = scrollView,
            let employeeHeaderView = employeeHeaderView else { return }

        scrollView.contentInset = .init(
            top: App.Layout.itemSpacingSmall,
            left: 0,
            bottom: App.Layout.sideOffset,
            right: 0
        )
        addSubview(scrollView)
        scrollView.snp.makeConstraints { (make) in
            make.top.equalTo(employeeHeaderView.snp.bottom)
            make.left.equalTo(self)
            make.bottom.equalTo(self)
            make.right.equalTo(self)
        }

        setupPosition()
        setupBirthdate()
        setupAdministrativeChief()
        setupFunctionalChief()
        setupPhone()
        setupEmail()
    }

    private func setupPosition() {
        positionView = ImageTextView(
            image: nil,
            title: NSLocalizedString("job_position", comment: ""),
            subtitle: "-"
        )

        guard let scrollView = scrollView,
            let positionView = positionView else {
            return
        }

        setup(view: positionView)
        scrollView.stackView?.addArrangedSubview(positionView)
    }

    private func setupBirthdate() {
        birthdateView = ImageTextView(
            image: nil,
            title: NSLocalizedString("birthdate", comment: ""),
            subtitle: "-"
        )

        guard let scrollView = scrollView,
            let birthdateView = birthdateView else {
                return
        }

        setup(view: birthdateView)
        scrollView.stackView?.addArrangedSubview(birthdateView)
    }

    private func setupAdministrativeChief() {
        administrativeChiefView = ImageTextView(
            image: nil,
            title: NSLocalizedString("administrative_chief", comment: ""),
            subtitle: "-"
        )

        guard let scrollView = scrollView,
            let chiefView = administrativeChiefView else {
                return
        }

        setup(view: chiefView)
        scrollView.stackView?.addArrangedSubview(chiefView)
    }

    private func setupFunctionalChief() {
        functionalChiefView = ImageTextView(
            image: nil,
            title: NSLocalizedString("functional_chief", comment: ""),
            subtitle: "-"
        )

        guard let scrollView = scrollView,
            let chiefView = functionalChiefView else {
                return
        }

        setup(view: chiefView)
        scrollView.stackView?.addArrangedSubview(chiefView)
    }

    private func setupPhone() {
        phoneView = ImageTextView(
            image: nil,
            title: NSLocalizedString("phone", comment: ""),
            subtitle: "-"
        )

        guard let scrollView = scrollView,
            let phoneView = phoneView else {
                return
        }

        setup(view: phoneView)
        scrollView.stackView?.addArrangedSubview(phoneView)
    }

    private func setupEmail() {
        emailButton = ImageTextButton(
            image: nil,
            title: NSLocalizedString("email", comment: ""),
            subtitle: "-"
        )

        guard let scrollView = scrollView,
            let emailButton = emailButton,
            let view = emailButton.view else {
                return
        }

        emailButton.button?.addTarget(self, action: #selector(handleEmailButton), for: .touchUpInside)

        setup(view: view)
        scrollView.stackView?.addArrangedSubview(emailButton)
    }

    private func setup(view: ImageTextView) {
        view.stackView?.insets = .init(
            top: App.Layout.itemSpacingSmall,
            left: App.Layout.sideOffset,
            bottom: App.Layout.itemSpacingSmall,
            right: App.Layout.sideOffset
        )
        view.textStackView?.stackView?.spacing = 5

        view.imageView?.isHidden = true

        view.titleLabel?.font = App.Font.caption
        view.titleLabel?.textColor = App.Color.steel

        view.subtitleLabel?.font = App.Font.body
        view.subtitleLabel?.textColor = UIColor.black
    }

}
