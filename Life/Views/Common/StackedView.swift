//
//  StackedView.swift
//  Life
//
//  Created by Shyngys Kassymov on 12.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import SnapKit

class StackedView: UIView {

    private(set) var stackView: UIStackView?

    var insets: UIEdgeInsets = .zero {
        didSet {
            guard let stackView = stackView else { return }

            stackView.snp.remakeConstraints { [weak self] (make) in
                guard let `self` = self else { return }
                make.top.equalTo(self).inset(insets.top)
                make.left.equalTo(self).inset(insets.left)
                make.bottom.equalTo(self).inset(insets.bottom)
                make.right.equalTo(self).inset(insets.right)
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: .zero)

        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI

    private func setupUI() {
        stackView = UIStackView()

        guard let stackView = stackView else { return }

        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.axis = .vertical
        stackView.setContentCompressionResistancePriority(.required, for: .vertical)
        stackView.setContentHuggingPriority(.defaultLow, for: .vertical)
        addSubview(stackView)
        stackView.snp.makeConstraints { [weak self] (make) in
            guard let `self` = self else { return }
            make.edges.equalTo(self)
        }

        setContentCompressionResistancePriority(.required, for: .vertical)
        setContentHuggingPriority(.defaultLow, for: .vertical)

        setAllConstraintsPriority(to: UILayoutPriority(rawValue: 999))
    }

}
