//
//  ImageTextTableViewCell.swift
//  Life
//
//  Created by Shyngys Kassymov on 12.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import Kingfisher
import Material
import SnapKit

class ImageTextTableViewCell: TableViewCell {

    private(set) var view: ImageTextView?
    private var heightConstraint: NSLayoutConstraint?

    override func prepare() {
        super.prepare()

        setupUI()
    }

    // MARK: - Methods

    public func set(image: UIImage?) {
        view?.imageView?.image = image
    }

    public func set(imageURL: String?) {
        guard let imageURL = imageURL else { return }

        let url = URL(string: imageURL)
        view?.imageView?.kf.setImage(with: url)
    }

    public func set(imageSize: CGSize) {
        view?.imageSize = imageSize
    }

    public func set(imageRadius: CGFloat) {
        view?.imageRadius = imageRadius
    }

    public func setImage(hidden: Bool) {
        view?.imageView?.isHidden = hidden
    }

    public func setImageText(spacing: CGFloat) {
        view?.stackView?.stackView?.spacing = spacing
    }

    public func set(title: String?) {
        view?.titleLabel?.text = title
        view?.titleLabel?.isHidden = title == nil
    }

    public func setTitle(font: UIFont) {
        view?.titleLabel?.font = font
    }

    public func setTitle(color: UIColor?) {
        view?.titleLabel?.textColor = color
    }

    public func set(subtitle: String?) {
        view?.subtitleLabel?.text = subtitle
        view?.subtitleLabel?.isHidden = subtitle == nil
    }

    public func setSubtitle(font: UIFont) {
        view?.subtitleLabel?.font = font
    }

    public func setSubtitle(color: UIColor?) {
        view?.subtitleLabel?.textColor = color
    }

    public func set(insets: UIEdgeInsets) {
        view?.stackView?.insets = insets
    }

    public func setDivider(leftInset: CGFloat) {
        view?.dividerLeftOffset = leftInset
    }

    public func setDivider(rightInset: CGFloat) {
        view?.dividerRightOffset = rightInset
    }

    var minimumHeight: CGFloat = 0 {
        didSet {
            if let constraint = heightConstraint {
                constraint.constant = minimumHeight
                layoutIfNeeded()
                return
            }
            heightConstraint = contentView.getHeightConstraint()
            if let constraint = heightConstraint {
                constraint.constant = minimumHeight
                layoutIfNeeded()
            } else {
                heightConstraint = NSLayoutConstraint(
                    item: contentView,
                    attribute: .height,
                    relatedBy: .equal,
                    toItem: nil,
                    attribute: .notAnAttribute,
                    multiplier: 1.0,
                    constant: minimumHeight)
                heightConstraint?.isActive = true
            }
        }
    }

    // MARK: - UI

    private func setupUI() {
        setupView()
    }

    private func setupView() {
        backgroundColor = .clear
        backgroundView = nil

        view = ImageTextView(image: nil, title: "", subtitle: "")
        view?.dividerView?.isHidden = false

        guard let view = view else { return }

        contentView.addSubview(view)
        view.snp.makeConstraints { [weak self] (make) in
            guard let `self` = self else { return }
            make.edges.equalTo(self)
        }
    }

}
