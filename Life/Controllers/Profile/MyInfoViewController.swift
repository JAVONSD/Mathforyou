//
//  MyInfoViewController.swift
//  Life
//
//  Created by Shyngys Kassymov on 12.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import Kingfisher
import Material
import RxSwift
import RxCocoa
import SnapKit

class MyInfoViewController: UIViewController {

    private var myInfoView: MyInfoView!

    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        bind()
    }

    // MARK: - Bind

    private func bind() {
        User.current.updated.asDriver().drive(onNext: { [weak self] profile in
            guard let `self` = self else { return }

            ImageDownloader.set(
                image: "",
                employeeCode: (profile?.employeeCode ?? ""),
                to: self.myInfoView.mainView?.infoView?.imageView,
                placeholderImage: #imageLiteral(resourceName: "ic-user")
            )

            self.updateUI(with: profile)
        }).disposed(by: disposeBag)
    }

    // MARK: - UI

    private func setupUI() {
        view.backgroundColor = App.Color.whiteSmoke

        setupTabItem()
        setupMyInfoView()
    }

    private func setupTabItem() {
        tabItem.title = NSLocalizedString("info", comment: "").uppercased()
        tabItem.titleLabel?.font = App.Font.buttonSmall
    }

    private func setupMyInfoView() {
        myInfoView = MyInfoView(frame: .zero)
        view.addSubview(myInfoView)
        myInfoView.snp.makeConstraints({ [weak self] (make) in
            guard let `self` = self else { return }
            make.edges.equalTo(self.view)
        })
    }

    private func updateUI(with profile: UserProfile?) {
        self.myInfoView.mainView?
            .infoView?.titleLabel?.text = profile?.fullname
        self.myInfoView.mainView?
            .infoView?.subtitleLabel?.text = profile?.jobPosition

        self.myInfoView.contactView?
            .divisionButton?.view?.titleLabel?.text = profile?.company
        self.myInfoView.contactView?
            .cellPhoneButton?.view?.titleLabel?.text = profile?.mobilePhoneNumber
        self.myInfoView.contactView?
            .emailButton?.view?.titleLabel?.text = profile?.email
        self.myInfoView.contactView?
            .officialPhoneButton?.view?.titleLabel?.text = profile?.workPhoneNumber

        self.myInfoView.detailedView?
            .iinView?.subtitleLabel?.text = profile?.iin
        self.myInfoView.detailedView?
            .familyStatusView?.subtitleLabel?.text = profile?.familyStatus
        self.myInfoView.detailedView?
            .childrenCountView?.subtitleLabel?.text = profile?.childrenQuantity
        self.myInfoView.detailedView?
            .birthdateView?.subtitleLabel?.text = profile?.birthDate
                .prettyDateString(format: "dd MMMM yyyy")
        self.myInfoView.detailedView?
            .genderView?.subtitleLabel?.text = profile?.gender
        self.myInfoView.detailedView?
            .clothingSizeView?.subtitleLabel?.text = profile?.clothingSize

        self.myInfoView.detailedView?
            .workExperienceView?.subtitleLabel?.text = profile?.totalExperience
        self.myInfoView.detailedView?
            .corporateExperienceView?.subtitleLabel?.text = profile?.corporateExperience

        let lastDate = profile?.medicalExamination.last?.prettyDateString(format: "dd.MM.yyyy")
        self.myInfoView.detailedView?
            .lastMedicalView?.subtitleLabel?.text = lastDate
            ?? NSLocalizedString("no_data", comment: "")

        let nextDate = profile?.medicalExamination.next?.prettyDateString(format: "dd.MM.yyyy")
        self.myInfoView.detailedView?
            .nextMedicalView?.subtitleLabel?.text = nextDate
            ?? NSLocalizedString("no_data", comment: "")
    }

}
