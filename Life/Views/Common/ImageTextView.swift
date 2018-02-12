//
//  ImageTextView.swift
//  Life
//
//  Created by Shyngys Kassymov on 12.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import DynamicColor
import SnapKit

class ImageTextView: UIView {

    private(set) var stackView: StackedView?
    private(set) var textStackView: StackedView?

    private(set) var imageView: UIImageView?
    private(set) var titleLabel: UILabel?
    private(set) var subtitleLabel: UILabel?
    private(set) var dividerView: UIView?

    var imageSize: CGSize = CGSize(width: 50, height: 50) {
        didSet {
            imageView?.snp.remakeConstraints { (make) in
                make.size.equalTo(imageSize)
            }
        }
    }

    var imageRadius: CGFloat = App.Layout.cornerRadius {
        didSet {
            imageView?.layer.cornerRadius = imageRadius
            imageView?.layer.masksToBounds = imageRadius != 0
        }
    }

    var dividerLeftOffset: CGFloat = 40 {
        didSet {
            dividerView?.snp.remakeConstraints { [weak self] (make) in
                guard let `self` = self else { return }
                make.left.equalTo(self).inset(dividerLeftOffset)
                make.bottom.equalTo(self)
                make.right.equalTo(self)
                make.height.equalTo(0.5)
            }
        }
    }

    init(image: UIImage? = nil,
         title: String? = nil,
         subtitle: String? = nil) {
        super.init(frame: .zero)

        setupUI()

        imageView?.image = image

        titleLabel?.text = title
        titleLabel?.isHidden = title == nil

        subtitleLabel?.text = subtitle
        subtitleLabel?.isHidden = subtitle == nil
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        guard let textStackView = textStackView,
            let titleLabel = titleLabel else {
            return
        }

        titleLabel.preferredMaxLayoutWidth = textStackView.frame.size.width
    }

    // MARK: - UI

    private func setupUI() {
        setupStackView()
        setupImageView()
        setupTextStackView()
        setupDividerView()
    }

    private func setupStackView() {
        stackView = StackedView()

        guard let stackView = stackView else {
            return
        }

        stackView.stackView?.alignment = .center
        stackView.stackView?.axis = .horizontal
        stackView.stackView?.spacing = App.Layout.sideOffset

        addSubview(stackView)
        stackView.snp.makeConstraints { [weak self] (make) in
            guard let `self` = self else { return }
            make.edges.equalTo(self)
        }
    }

    private func setupImageView() {
        imageView = UIImageView()
        imageView?.backgroundColor = UIColor(hexString: "#d8d8d8")
        imageView?.contentMode = .scaleAspectFit
        imageView?.layer.cornerRadius = App.Layout.cornerRadius
        imageView?.layer.masksToBounds = true

        guard let stackView = stackView,
            let imageView = imageView else {
                return
        }

        stackView.stackView?.addArrangedSubview(imageView)
    }

    private func setupTextStackView() {
        textStackView = StackedView()

        guard let stackView = stackView,
            let textStackView = textStackView else {
            return
        }

        textStackView.stackView?.distribution = .fill
        stackView.stackView?.addArrangedSubview(textStackView)

        setupLabels()
    }

    private func setupLabels() {
        titleLabel = UILabel()
        titleLabel?.font = App.Font.headline
        titleLabel?.lineBreakMode = .byWordWrapping
        titleLabel?.numberOfLines = 0
        titleLabel?.textColor = .black

        subtitleLabel = UILabel()
        subtitleLabel?.font = App.Font.body
        subtitleLabel?.textColor = App.Color.steel

        guard let textStackView = textStackView,
            let titleLabel = titleLabel,
            let subtitleLabel = subtitleLabel else {
                return
        }

        textStackView.stackView?.addArrangedSubview(titleLabel)
        textStackView.stackView?.addArrangedSubview(subtitleLabel)
    }

    private func setupDividerView() {
        dividerView = UIView()
        dividerView?.backgroundColor = App.Color.coolGrey
        dividerView?.isHidden = true

        guard let dividerView = dividerView else {
            return
        }

        addSubview(dividerView)
        dividerView.snp.makeConstraints { [weak self] (make) in
            guard let `self` = self else { return }
            make.left.equalTo(self).inset(dividerLeftOffset)
            make.bottom.equalTo(self)
            make.right.equalTo(self)
            make.height.equalTo(0.5)
        }
    }

}
