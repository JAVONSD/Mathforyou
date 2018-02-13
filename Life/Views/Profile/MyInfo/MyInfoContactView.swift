//
//  MyInfoContactView.swift
//  Life
//
//  Created by Shyngys Kassymov on 12.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import Material
import SnapKit

class MyInfoContactView: StackedView {

    private(set) var divisionButton: ImageTextButton?
    private(set) var cellPhoneButton: ImageTextButton?
    private(set) var emailButton: ImageTextButton?
    private(set) var officialPhoneButton: ImageTextButton?

    private(set) var detailedButton: ImageTextButton?

    enum DetailedViewState {
        case hidden, shown
    }

    private var currentDetailedViewState = DetailedViewState.hidden

    var didTapToggleDetailedView: ((DetailedViewState) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupDivisionButton()
        setupCellPhoneButton()
        setupEmailButton()
        setupOfficialPhoneButton()
        setupDetailedButton()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Actions

    @objc
    private func handleDetailButton() {
        currentDetailedViewState = currentDetailedViewState == .hidden ? .shown : .hidden

        if let didTapToggleDetailedView = didTapToggleDetailedView {
            didTapToggleDetailedView(currentDetailedViewState)
        }

        let detailedInfo = NSLocalizedString("detailed_info", comment: "")
        let hideDetailedInfo = NSLocalizedString("hide_detailed_info", comment: "")
        let title = currentDetailedViewState == .hidden ? detailedInfo : hideDetailedInfo
        detailedButton?.view?.titleLabel?.text = title
    }

    // MARK: - UI

    private func setupDivisionButton() {
        divisionButton = ImageTextButton(image: #imageLiteral(resourceName: "domain"), title: NSLocalizedString("division", comment: ""))

        guard let stackView = stackView,
            let divisionButton = divisionButton else {
                return
        }

        setup(button: divisionButton)
        stackView.addArrangedSubview(divisionButton)
    }

    private func setupCellPhoneButton() {
        cellPhoneButton = ImageTextButton(image: #imageLiteral(resourceName: "mobile"), title: NSLocalizedString("cell_phone", comment: ""))

        guard let stackView = stackView,
            let cellPhoneButton = cellPhoneButton else {
                return
        }

        setup(button: cellPhoneButton)
        stackView.addArrangedSubview(cellPhoneButton)
    }

    private func setupEmailButton() {
        emailButton = ImageTextButton(image: #imageLiteral(resourceName: "mail"), title: NSLocalizedString("email", comment: ""))

        guard let stackView = stackView,
            let emailButton = emailButton else {
                return
        }

        setup(button: emailButton)
        stackView.addArrangedSubview(emailButton)
    }

    private func setupOfficialPhoneButton() {
        officialPhoneButton = ImageTextButton(image: #imageLiteral(resourceName: "phone-inactive"),
                                              title: NSLocalizedString("official_phone", comment: ""))

        guard let stackView = stackView,
            let officialPhoneButton = officialPhoneButton else {
                return
        }

        setup(button: officialPhoneButton)
        officialPhoneButton.view?.dividerLeftOffset = 0
        stackView.addArrangedSubview(officialPhoneButton)
    }

    private func setupDetailedButton() {
        detailedButton = ImageTextButton(image: #imageLiteral(resourceName: "more-goriz"), title: NSLocalizedString("detailed_info", comment: ""))
        detailedButton?.button?.addTarget(self, action: #selector(handleDetailButton), for: .touchUpInside)

        guard let stackView = stackView,
            let detailedButton = detailedButton else {
                return
        }

        setup(button: detailedButton)
        detailedButton.view?.dividerView?.isHidden = true
        detailedButton.view?.titleLabel?.textColor = App.Color.azure
        stackView.addArrangedSubview(detailedButton)
    }

    private func setup(button: ImageTextButton) {
        button.view?.imageSize = CGSize(width: 22, height: 22)
        button.view?.imageRadius = 0
        button.view?.imageView?.backgroundColor = .clear
        button.view?.stackView?.stackView?.spacing = App.Layout.itemSpacingMedium
        let insets = UIEdgeInsets(top: App.Layout.itemSpacingMedium,
                                  left: 0,
                                  bottom: App.Layout.itemSpacingMedium,
                                  right: 0)
        button.view?.textStackView?.stackView?.layoutMargins = insets
        button.view?.textStackView?.stackView?.isLayoutMarginsRelativeArrangement = true
        button.view?.titleLabel?.font = App.Font.body
        button.view?.dividerView?.isHidden = false
    }

}
