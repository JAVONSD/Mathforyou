//
//  MyInfoDetailedView.swift
//  Life
//
//  Created by Shyngys Kassymov on 12.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import Material
import SnapKit

class MyInfoDetailedView: StackedView {

    private(set) var personalAndFamilyInfoView: ImageTextView?
    private(set) var iinView: ImageTextView?
    private(set) var familyStatusView: ImageTextView?
    private(set) var childrenCountView: ImageTextView?
    private(set) var birthdateView: ImageTextView?
    private(set) var genderView: ImageTextView?
    private(set) var clothingSizeView: ImageTextView?

    private(set) var workInfoView: ImageTextView?
    private(set) var workExperienceView: ImageTextView?
    private(set) var corporateExperienceView: ImageTextView?

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI

    private func setupUI() {
        setupPersonalAndFamilyInfoView()
        setupWorkInfoView()
    }

    private func setupPersonalAndFamilyInfoView() {
        personalAndFamilyInfoView = ImageTextView(
            title: NSLocalizedString("personal_and_family_info", comment: "")
        )

        guard let stackView = stackView,
            let pafiView = personalAndFamilyInfoView else {
                return
        }

        pafiView.imageView?.isHidden = true
        pafiView.titleLabel?.font = App.Font.subheadAlts
        pafiView.dividerView?.isHidden = false
        pafiView.dividerLeftOffset = 0

        stackView.addArrangedSubview(pafiView)

        let horizStackView = StackedView(frame: .zero)
        horizStackView.stackView?.distribution = .fillEqually
        horizStackView.stackView?.axis = .horizontal

        let firstColStackView = StackedView(frame: .zero)
        let insets = UIEdgeInsets(top: 0,
                                  left: 0,
                                  bottom: App.Layout.itemSpacingMedium,
                                  right: 0)
        firstColStackView.stackView?.layoutMargins = insets
        firstColStackView.stackView?.isLayoutMarginsRelativeArrangement = true
        horizStackView.stackView?.addArrangedSubview(firstColStackView)

        let secondColStackView = StackedView(frame: .zero)
        secondColStackView.stackView?.layoutMargins = insets
        secondColStackView.stackView?.isLayoutMarginsRelativeArrangement = true
        horizStackView.stackView?.addArrangedSubview(secondColStackView)

        pafiView.textStackView?.stackView?.addArrangedSubview(horizStackView)

        guard let fStackView = firstColStackView.stackView,
            let sStackView = secondColStackView.stackView else {
                return
        }

        setupIinView(stackView: fStackView)
        setupFamilyStatusView(stackView: fStackView)
        setupChildrenCountView(stackView: fStackView)
        setupBirthdateView(stackView: sStackView)
        setupGenderView(stackView: sStackView)
        setupClothingSizeView(stackView: sStackView)
    }

    private func setupIinView(stackView: UIStackView) {
        iinView = ImageTextView(title: NSLocalizedString("iin", comment: ""), subtitle: "000900800666")

        guard let iinView = iinView else { return }

        setup(subview: iinView)
        stackView.addArrangedSubview(iinView)
    }

    private func setupFamilyStatusView(stackView: UIStackView) {
        familyStatusView = ImageTextView(
            title: NSLocalizedString("family_status", comment: ""),
            subtitle: "В браке"
        )

        guard let familyStatusView = familyStatusView else { return }

        setup(subview: familyStatusView)
        stackView.addArrangedSubview(familyStatusView)
    }

    private func setupChildrenCountView(stackView: UIStackView) {
        childrenCountView = ImageTextView(
            title: NSLocalizedString("children", comment: ""),
            subtitle: "Двое"
        )

        guard let childrenCountView = childrenCountView else { return }

        setup(subview: childrenCountView)
        stackView.addArrangedSubview(childrenCountView)
    }

    private func setupBirthdateView(stackView: UIStackView) {
        birthdateView = ImageTextView(
            title: NSLocalizedString("birthdate", comment: ""),
            subtitle: "13 декабря 1989"
        )

        guard let birthdateView = birthdateView else { return }

        setup(subview: birthdateView)
        stackView.addArrangedSubview(birthdateView)
    }

    private func setupGenderView(stackView: UIStackView) {
        genderView = ImageTextView(
            title: NSLocalizedString("gender", comment: ""),
            subtitle: "Мужской"
        )

        guard let genderView = genderView else { return }

        setup(subview: genderView)
        stackView.addArrangedSubview(genderView)
    }

    private func setupClothingSizeView(stackView: UIStackView) {
        clothingSizeView = ImageTextView(
            title: NSLocalizedString("clothing_size", comment: ""),
            subtitle: "42 - 48"
        )

        guard let clothingSizeView = clothingSizeView else { return }

        setup(subview: clothingSizeView)
        stackView.addArrangedSubview(clothingSizeView)
    }

    private func setupWorkInfoView() {
        workInfoView = ImageTextView(title: NSLocalizedString("work_info", comment: ""))

        guard let stackView = stackView,
            let workInfoView = workInfoView else {
                return
        }

        workInfoView.imageView?.isHidden = true
        let insets = UIEdgeInsets(top: App.Layout.itemSpacingSmall,
                                  left: 0,
                                  bottom: App.Layout.itemSpacingSmall,
                                  right: 0)
        workInfoView.textStackView?.stackView?.layoutMargins = insets
        workInfoView.textStackView?.stackView?.isLayoutMarginsRelativeArrangement = true
        workInfoView.titleLabel?.font = App.Font.subheadAlts

        stackView.addArrangedSubview(workInfoView)

        guard let wStackView = workInfoView.textStackView?.stackView else {
            return
        }

        setupWorkExperienceView(stackView: wStackView)
        setupCorporateExperienceView(stackView: wStackView)
    }

    private func setupWorkExperienceView(stackView: UIStackView) {
        workExperienceView = ImageTextView(
            title: NSLocalizedString("work_experience", comment: ""),
            subtitle: "5 лет"
        )

        guard let workExperienceView = workExperienceView else { return }

        setup(subview: workExperienceView)
        stackView.addArrangedSubview(workExperienceView)
    }

    private func setupCorporateExperienceView(stackView: UIStackView) {
        corporateExperienceView = ImageTextView(
            title: NSLocalizedString("corporate_experience", comment: ""),
            subtitle: "2 года"
        )

        guard let corporateExperienceView = corporateExperienceView else { return }

        setup(subview: corporateExperienceView)
        stackView.addArrangedSubview(corporateExperienceView)
    }

    private func setup(subview: ImageTextView) {
        subview.imageView?.isHidden = true
        let insets = UIEdgeInsets(top: App.Layout.itemSpacingSmall,
                                  left: 0,
                                  bottom: App.Layout.itemSpacingSmall,
                                  right: 0)
        subview.textStackView?.stackView?.layoutMargins = insets
        subview.textStackView?.stackView?.isLayoutMarginsRelativeArrangement = true
        subview.textStackView?.stackView?.spacing = 5
        subview.titleLabel?.font = App.Font.caption
        subview.titleLabel?.textColor = App.Color.steel
        subview.subtitleLabel?.font = App.Font.body
        subview.subtitleLabel?.textColor = UIColor.black
    }

}
