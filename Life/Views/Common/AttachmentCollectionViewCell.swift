//
//  AttachmentCollectionViewCell.swift
//  Life
//
//  Created by Shyngys Kassymov on 04.04.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import SnapKit

class AttachmentCollectionViewCell: UICollectionViewCell {

    private(set) lazy var containerView = UIView()
    private(set) lazy var imageView = UIImageView()
    private(set) lazy var titleLabel = UILabel()
    private(set) lazy var subtitleLabel = UILabel()
    private(set) lazy var deleteButton = UIButton()

    static let containerSideLength: CGFloat = 60
    static let sideInset: CGFloat = 12
    static let labelHeight: CGFloat = 30

    var didTapDelete: ((UIButton) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        titleLabel.preferredMaxLayoutWidth = titleLabel.frame.size.width
        subtitleLabel.preferredMaxLayoutWidth = subtitleLabel.frame.size.width
    }

    // MARK: - Actions

    @objc
    private func handleDelete() {
        didTapDelete?(deleteButton)
    }

    // MARK: - Methods

    public static func width() -> CGFloat {
        return containerSideLength + 2 * AttachmentCollectionViewCell.sideInset
    }

    public static func height() -> CGFloat {
        var height = containerSideLength

        // vertical insets
        height += (AttachmentCollectionViewCell.sideInset + App.Layout.itemSpacingSmall * 2)

        // label height
        height += AttachmentCollectionViewCell.labelHeight

        return height
    }

    // MARK: - UI

    private func setupUI() {
        setupContainerView()
        setupImageView()
        setupTitleLabel()
        setupSubtitleLabel()
        setupDeleteButton()
    }

    private func setupContainerView() {
        containerView.backgroundColor = App.Color.paleGreyTwo
        containerView.layer.cornerRadius = App.Layout.cornerRadiusSmall
        containerView.layer.masksToBounds = true
        contentView.addSubview(containerView)
        containerView.snp.makeConstraints { (make) in
            make.top.equalTo(self.contentView).inset(AttachmentCollectionViewCell.sideInset)
            make.left.equalTo(self.contentView).inset(AttachmentCollectionViewCell.sideInset)
            make.right.equalTo(self.contentView).inset(AttachmentCollectionViewCell.sideInset)
            make.size.equalTo(
                CGSize(
                    width: AttachmentCollectionViewCell.containerSideLength,
                    height: AttachmentCollectionViewCell.containerSideLength
                )
            )
        }
    }

    private func setupImageView() {
        imageView.contentMode = .scaleAspectFill
        containerView.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.containerView)
        }
    }

    private func setupTitleLabel() {
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.5
        titleLabel.font = App.Font.subheadAlts
        titleLabel.textAlignment = .center
        titleLabel.textColor = .black
        containerView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.edges.equalTo(self.containerView).inset(App.Layout.itemSpacingSmall)
        }
    }

    private func setupSubtitleLabel() {
        subtitleLabel.font = App.Font.caption
        subtitleLabel.lineBreakMode = .byWordWrapping
        subtitleLabel.numberOfLines = 2
        subtitleLabel.textAlignment = .center
        subtitleLabel.textColor = App.Color.steel
        contentView.addSubview(subtitleLabel)
        subtitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.containerView.snp.bottom).offset(App.Layout.itemSpacingSmall)
            make.left.equalTo(self.contentView).inset(AttachmentCollectionViewCell.sideInset)
            make.bottom.equalTo(self.contentView).inset(App.Layout.itemSpacingSmall)
            make.right.equalTo(self.contentView).inset(AttachmentCollectionViewCell.sideInset)
            make.height.equalTo(AttachmentCollectionViewCell.labelHeight)
        }
    }

    private func setupDeleteButton() {
        let image = #imageLiteral(resourceName: "close-circle-dark")
        let templateImage = image.withRenderingMode(.alwaysTemplate)

        deleteButton.addTarget(self, action: #selector(handleDelete), for: .touchUpInside)
        deleteButton.contentMode = .scaleAspectFit
        deleteButton.setImage(templateImage, for: .normal)
        deleteButton.tintColor = .red
        contentView.addSubview(deleteButton)
        deleteButton.snp.makeConstraints { (make) in
            make.top.equalTo(self.contentView)
            make.right.equalTo(self.contentView)
        }
    }

}
