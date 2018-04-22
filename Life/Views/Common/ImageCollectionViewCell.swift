//
//  ImageCollectionViewCell.swift
//  Life
//
//  Created by Shyngys Kassymov on 13.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import Kingfisher
import Material
import SnapKit

class ImageCollectionViewCell: CollectionViewCell {

    private(set) var imageView: UIImageView?
    private(set) lazy var collectionOverlayView = UIView()

    var imageRadius: CGFloat = 0 {
        didSet {
            imageView?.layer.cornerRadius = imageRadius
            imageView?.layer.masksToBounds = imageRadius != 0
        }
    }

    var overlayColor: UIColor = .clear {
        didSet {
            collectionOverlayView.backgroundColor = overlayColor
        }
    }

    override func prepare() {
        super.prepare()

        setupUI()
    }

    // MARK: - Methods

    public func set(imageURL: String) {
        let url = URL(string: imageURL)
        imageView?.kf.setImage(with: url)
    }

    // MARK: - UI

    private func setupUI() {
        backgroundColor = .clear
        backgroundView = nil
        contentView.backgroundColor = .clear
        layer.masksToBounds = true

        imageView = UIImageView()
        imageView?.backgroundColor = App.Color.silver
        imageView?.contentMode = .scaleAspectFill

        guard let imageView = imageView else { return }

        imageRadius = App.Layout.cornerRadius

        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { [weak self] (make) in
            guard let `self` = self else { return }
            make.edges.equalTo(self)
        }

        collectionOverlayView.backgroundColor = .clear
        collectionOverlayView.isUserInteractionEnabled = false
        imageView.addSubview(collectionOverlayView)
        collectionOverlayView.snp.makeConstraints { (make) in
            make.edges.equalTo(imageView)
        }
    }

}
