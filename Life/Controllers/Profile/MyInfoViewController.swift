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

    var didTapAvatar: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        bind()
    }

    // MARK: - Bind

    private func bind() {
        User.current.updated.asDriver().drive(onNext: { [weak self] profile in
            guard let `self` = self else { return }

            self.updateUI(with: profile)
        }).disposed(by: disposeBag)

        ImageDownloader.set(
            image: "",
            employeeCode: User.current.employeeCode,
            to: self.myInfoView.mainView?.infoView?.imageView,
            placeholderImage: #imageLiteral(resourceName: "ic-user"),
            size: CGSize(width: 96, height: 96)
        )
    }

    // MARK: - Actions

    @objc
    private func handleAvatarTap() {
        if let didTapAvatar = didTapAvatar {
            didTapAvatar()
        }
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
        fillMainInfo(from: profile)
        fillContactInfo(from: profile)
        fillDetailedInfo(from: profile)
    }

    private func fillMainInfo(from profile: UserProfile?) {
        let tapGr = UITapGestureRecognizer(target: self, action: #selector(handleAvatarTap))
        tapGr.numberOfTapsRequired = 1
        tapGr.numberOfTouchesRequired = 1

        myInfoView.mainView?.infoView?.imageView?.isUserInteractionEnabled = true
        myInfoView.mainView?.infoView?.imageView?.addGestureRecognizer(tapGr)

        myInfoView.mainView?
            .infoView?.titleLabel?.text = profile?.fullname
                .onEmpty(NSLocalizedString("no_data", comment: ""))
        myInfoView.mainView?
            .infoView?.subtitleLabel?.text = profile?.jobPosition
                .onEmpty(NSLocalizedString("no_data", comment: ""))
    }

    private func fillContactInfo(from profile: UserProfile?) {
        myInfoView.contactView?
            .divisionButton?.view?.titleLabel?.text = profile?.company
                .onEmpty(NSLocalizedString("no_data", comment: ""))
        myInfoView.contactView?
            .cellPhoneButton?.view?.titleLabel?.text = profile?.mobilePhoneNumber
                .onEmpty(NSLocalizedString("no_data", comment: ""))
        myInfoView.contactView?
            .emailButton?.view?.titleLabel?.text = profile?.email
                .onEmpty(NSLocalizedString("no_data", comment: ""))
        myInfoView.contactView?
            .officialPhoneButton?.view?.titleLabel?.text = profile?.workPhoneNumber
                .onEmpty(NSLocalizedString("no_data", comment: ""))
    }

    private func fillDetailedInfo(from profile: UserProfile?) {
        myInfoView.detailedView?
            .iinView?.subtitleLabel?.text = profile?.iin
                .onEmpty(NSLocalizedString("no_data", comment: ""))
        myInfoView.detailedView?
            .familyStatusView?.subtitleLabel?.text = profile?.familyStatus
                .onEmpty(NSLocalizedString("no_data", comment: ""))
        myInfoView.detailedView?
            .childrenCountView?.subtitleLabel?.text = profile?.childrenQuantity
                .onEmpty(NSLocalizedString("no_data", comment: ""))
        myInfoView.detailedView?
            .birthdateView?.subtitleLabel?.text = profile?.birthDate
                .prettyDateString(format: "dd MMMM yyyy")
                .onEmpty(NSLocalizedString("no_data", comment: ""))
        myInfoView.detailedView?
            .genderView?.subtitleLabel?.text = profile?.gender
                .onEmpty(NSLocalizedString("no_data", comment: ""))
        myInfoView.detailedView?
            .clothingSizeView?.subtitleLabel?.text = profile?.clothingSize
                .onEmpty(NSLocalizedString("no_data", comment: ""))

        myInfoView.detailedView?
            .workExperienceView?.subtitleLabel?.text = profile?.totalExperience
                .onEmpty(NSLocalizedString("no_data", comment: ""))
        myInfoView.detailedView?
            .corporateExperienceView?.subtitleLabel?.text = profile?.corporateExperience
                .onEmpty(NSLocalizedString("no_data", comment: ""))

        let lastDate = profile?.medicalExamination.last?.prettyDateString(format: "dd.MM.yyyy")
        myInfoView.detailedView?
            .lastMedicalView?.subtitleLabel?.text = lastDate
            ?? NSLocalizedString("no_data", comment: "")

        let nextDate = profile?.medicalExamination.next?.prettyDateString(format: "dd.MM.yyyy")
        myInfoView.detailedView?
            .nextMedicalView?.subtitleLabel?.text = nextDate
            ?? NSLocalizedString("no_data", comment: "")
    }

}







