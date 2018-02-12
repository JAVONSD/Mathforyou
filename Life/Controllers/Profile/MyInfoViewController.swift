//
//  MyInfoViewController.swift
//  Life
//
//  Created by Shyngys Kassymov on 12.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import Material
import SnapKit

class MyInfoViewController: UIViewController {
    private var myInfoView: MyInfoView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
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

}
