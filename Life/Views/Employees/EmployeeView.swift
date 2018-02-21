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
    private(set) var loginView: ImageTextView?
    private(set) var birthdateView: ImageTextView?
    private(set) var chiefView: ImageTextView?
    private(set) var phoneView: ImageTextView?
    private(set) var emailView: ImageTextView?

    var didTapCloseButton: (() -> Void)?
    var didTapCallButton: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var image: String = "" {
        didSet {
            ImageDownloader.set(image: image, to: employeeHeaderView?.imageView)
        }
    }

    var fullname: String = "" {
        didSet {
            employeeHeaderView?.titleLabel?.text = fullname
        }
    }

    var position: String = "" {
        didSet {
            positionView?.titleLabel?.text = position
        }
    }

    var login: String = "" {
        didSet {
            loginView?.titleLabel?.text = login
        }
    }

    var birthdate: String = "" {
        didSet {
            birthdateView?.titleLabel?.text = birthdate
        }
    }

    var chief: String = "" {
        didSet {
            chiefView?.titleLabel?.text = chief
        }
    }

    var phone: String = "" {
        didSet {
            phoneView?.titleLabel?.text = phone
        }
    }

    var email: String = "" {
        didSet {
            emailView?.titleLabel?.text = email
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
        setupLogin()
        setupBirthdate()
        setupChief()
        setupPhone()
        setupEmail()
    }

    private func setupPosition() {
        positionView = ImageTextView(
            image: nil,
            title: NSLocalizedString("job_position", comment: ""),
            subtitle: "Главный бухгалтер Сервисной службы"
        )

        guard let scrollView = scrollView,
            let positionView = positionView else {
            return
        }

        setup(view: positionView)
        scrollView.stackView?.addArrangedSubview(positionView)
    }

    private func setupLogin() {
        loginView = ImageTextView(
            image: nil,
            title: NSLocalizedString("login_name", comment: ""),
            subtitle: "family.a"
        )

        guard let scrollView = scrollView,
            let loginView = loginView else {
                return
        }

        setup(view: loginView)
        scrollView.stackView?.addArrangedSubview(loginView)
    }

    private func setupBirthdate() {
        birthdateView = ImageTextView(
            image: nil,
            title: NSLocalizedString("birthdate", comment: ""),
            subtitle: "13 декабря 1989"
        )

        guard let scrollView = scrollView,
            let birthdateView = birthdateView else {
                return
        }

        setup(view: birthdateView)
        scrollView.stackView?.addArrangedSubview(birthdateView)
    }

    private func setupChief() {
        chiefView = ImageTextView(
            image: nil,
            title: NSLocalizedString("chief", comment: ""),
            subtitle: "Нугманова Айлида Рашидовна"
        )

        guard let scrollView = scrollView,
            let chiefView = chiefView else {
                return
        }

        setup(view: chiefView)
        scrollView.stackView?.addArrangedSubview(chiefView)
    }

    private func setupPhone() {
        phoneView = ImageTextView(
            image: nil,
            title: NSLocalizedString("phone", comment: ""),
            subtitle: "+7 771 777 77 77"
        )

        guard let scrollView = scrollView,
            let phoneView = phoneView else {
                return
        }

        setup(view: phoneView)
        scrollView.stackView?.addArrangedSubview(phoneView)
    }

    private func setupEmail() {
        emailView = ImageTextView(
            image: nil,
            title: NSLocalizedString("email", comment: ""),
            subtitle: "ailida@bi-group.org"
        )

        guard let scrollView = scrollView,
            let emailView = emailView else {
                return
        }

        setup(view: emailView)
        scrollView.stackView?.addArrangedSubview(emailView)
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
