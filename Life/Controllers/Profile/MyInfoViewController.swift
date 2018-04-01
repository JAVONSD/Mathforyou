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

            ImageDownloader.set(
                image: "",
                employeeCode: (profile?.employeeCode ?? ""),
                to: self.myInfoView.mainView?.infoView?.imageView,
                placeholderImage: #imageLiteral(resourceName: "ic-user")
            )

            self.updateUI(with: profile)
        }).disposed(by: disposeBag)
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
        let tapGr = UITapGestureRecognizer(target: self, action: #selector(handleAvatarTap))
        tapGr.numberOfTapsRequired = 1
        tapGr.numberOfTouchesRequired = 1

        myInfoView.mainView?.infoView?.imageView?.isUserInteractionEnabled = true
        myInfoView.mainView?.infoView?.imageView?.addGestureRecognizer(tapGr)

        myInfoView.mainView?
            .infoView?.titleLabel?.text = profile?.fullname
        myInfoView.mainView?
            .infoView?.subtitleLabel?.text = profile?.jobPosition

        myInfoView.contactView?
            .divisionButton?.view?.titleLabel?.text = profile?.company
        myInfoView.contactView?
            .cellPhoneButton?.view?.titleLabel?.text = profile?.mobilePhoneNumber
        myInfoView.contactView?
            .emailButton?.view?.titleLabel?.text = profile?.email
        myInfoView.contactView?
            .officialPhoneButton?.view?.titleLabel?.text = profile?.workPhoneNumber

        myInfoView.detailedView?
            .iinView?.subtitleLabel?.text = profile?.iin
        myInfoView.detailedView?
            .familyStatusView?.subtitleLabel?.text = profile?.familyStatus
        myInfoView.detailedView?
            .childrenCountView?.subtitleLabel?.text = profile?.childrenQuantity
        myInfoView.detailedView?
            .birthdateView?.subtitleLabel?.text = profile?.birthDate
                .prettyDateString(format: "dd MMMM yyyy")
        myInfoView.detailedView?
            .genderView?.subtitleLabel?.text = profile?.gender
        myInfoView.detailedView?
            .clothingSizeView?.subtitleLabel?.text = profile?.clothingSize

        myInfoView.detailedView?
            .workExperienceView?.subtitleLabel?.text = profile?.totalExperience
        myInfoView.detailedView?
            .corporateExperienceView?.subtitleLabel?.text = profile?.corporateExperience

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
