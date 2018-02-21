//
//  StackedScrollView.swift
//  Life
//
//  Created by Shyngys Kassymov on 12.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import SnapKit

class StackedScrollView: UIScrollView {

    private(set) var stackView: UIStackView?

    enum ScrollDirection {
        case vertical, horizontal
    }

    var insets: UIEdgeInsets = .zero {
        didSet {
            guard let stackView = stackView else { return }

            stackView.snp.remakeConstraints { [weak self] (make) in
                guard let `self` = self else { return }

                if scrollDirection == .vertical {
                    make.top.equalTo(self).inset(insets.top)
                    make.left.equalTo(self).inset(insets.left)
                    make.right.equalTo(self).inset(insets.right)
                    make.width.equalTo(self).offset(-insets.left - insets.right)
                } else {
                    make.top.equalTo(self).inset(insets.top)
                    make.left.equalTo(self).inset(insets.left)
                    make.bottom.equalTo(self).inset(insets.bottom)
                    make.height.equalTo(self).offset(-insets.top - insets.bottom)
                }
            }
        }
    }

    private(set) var scrollDirection = ScrollDirection.vertical

    init(direction: ScrollDirection) {
        super.init(frame: .zero)

        scrollDirection = direction

        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        guard let stackView = stackView else { return }

        var size = stackView.frame.size
        if scrollDirection == .vertical {
            size.width = frame.size.width
            size.height += insets.top + insets.bottom
        } else {
            size.height = frame.size.height
            size.width += insets.left + insets.right
        }
        contentSize = size
    }

    // MARK: - UI

    private func setupUI() {
        stackView = UIStackView()

        guard let stackView = stackView else { return }

        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.axis = scrollDirection == .vertical ? .vertical : .horizontal
        addSubview(stackView)
        stackView.snp.makeConstraints { [weak self] (make) in
            guard let `self` = self else { return }

            if scrollDirection == .vertical {
                make.top.equalTo(self)
                make.left.equalTo(self)
                make.right.equalTo(self)
                make.width.equalTo(self)
            } else {
                make.top.equalTo(self)
                make.left.equalTo(self)
                make.bottom.equalTo(self)
                make.height.equalTo(self)
            }
        }

        setAllConstraintsPriority(to: UILayoutPriority(rawValue: 999))
    }

}
