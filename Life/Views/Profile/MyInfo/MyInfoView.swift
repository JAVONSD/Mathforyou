//
//  MyInfoView.swift
//  Life
//
//  Created by Shyngys Kassymov on 12.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import Material
import SnapKit

class MyInfoView: UIView {

    private(set) var scrollView: StackedScrollView?
    private(set) var mainView: MyInfoMainView?
    private(set) var contactView: MyInfoContactView?
    private(set) var detailedView: MyInfoDetailedView?

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI

    private func setupUI() {
        setupStackView()
        setupMainView()
        setupContactView()
        setupDetaieldView()
    }

    private func setupStackView() {
        scrollView = StackedScrollView(direction: .vertical)
        scrollView?.stackView?.spacing = App.Layout.sideOffset
        scrollView?.insets = UIEdgeInsets(top: App.Layout.sideOffset,
                                                left: App.Layout.sideOffset,
                                                bottom: App.Layout.sideOffset,
                                                right: App.Layout.sideOffset)

        guard let scrollView = scrollView else { return }

        addSubview(scrollView)
        scrollView.snp.makeConstraints { [weak self] (make) in
            guard let `self` = self else { return }
            make.edges.equalTo(self)
        }
    }

    private func setupMainView() {
        mainView = MyInfoMainView()

        guard let stackView = scrollView?.stackView,
            let mainView = mainView else {
                return
        }

        stackView.addArrangedSubview(mainView)
    }

    private func setupContactView() {
        contactView = MyInfoContactView(frame: .zero)
        contactView?.didTapToggleDetailedView = { [weak self] state in
            guard let `self` = self,
                let stackView = self.scrollView?.stackView,
                let detailedView = self.detailedView else {
                    return
            }

            if stackView.arrangedSubviews.contains(detailedView) {
                detailedView.isHidden = state == .hidden
            } else {
                stackView.addArrangedSubview(detailedView)
            }
        }

        guard let stackView = scrollView?.stackView,
            let contactView = contactView else {
                return
        }

        stackView.addArrangedSubview(contactView)
    }

    private func setupDetaieldView() {
        detailedView = MyInfoDetailedView(frame: .zero)
    }

}
