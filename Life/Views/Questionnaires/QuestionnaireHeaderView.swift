//
//  QuestionnaireHeaderView.swift
//  Life
//
//  Created by Shyngys Kassymov on 04.04.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import Kingfisher
import Material
import SnapKit

class QuestionnaireHeaderView: UIView {

    private(set) var collectionView: UICollectionView!

    private(set) lazy var overlayView = UIView()
    private(set) lazy var label = InsetLabel(
        insets: .init(top: 1, left: 4, bottom: 1, right: 4)
    )
    private(set) lazy var closeButton = FlatButton(image: #imageLiteral(resourceName: "close-circle"))

    private(set) lazy var pageControl = UIPageControl()

    private(set) lazy var authorContainerView = UIView()
    private(set) lazy var authorImageView = UIImageView()
    private(set) lazy var authorLabel = UILabel()
    private(set) lazy var publishDateLabel = UILabel()

    private(set) lazy var separatorView = UIView()

    var images = [String]() {
        didSet {
            collectionView.reloadData()
            pageControl.numberOfPages = images.count

            collectionView.snp.remakeConstraints { (make) in
                make.top.equalTo(self)
                make.left.equalTo(self)
                make.right.equalTo(self)
                if images.isEmpty {
                    make.height.equalTo(72)
                } else {
                    make.height.equalTo(self.collectionView.snp.width).multipliedBy(300.0 / 360.0)
                }
            }
            overlayView.snp.remakeConstraints { (make) in
                make.top.equalTo(self)
                make.left.equalTo(self)
                make.right.equalTo(self)
                if images.isEmpty {
                    make.height.equalTo(72)
                } else {
                    make.height.equalTo(self.collectionView.snp.width).multipliedBy(300.0 / 360.0)
                }
            }
        }
    }

    var didTapImage: ((String, [String]) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        authorLabel.preferredMaxLayoutWidth = authorLabel.frame.size.width
    }

    // MARK: - UI

    private func setupUI() {
        setupCollectionView()
        setupCollectionOverlay()
        setupAuthorViews()
        setupSeparatorView()
    }

    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = .zero
        layout.scrollDirection = .horizontal

        let width = UIScreen.main.bounds.size.width
        let height = width * 300.0 / 360.0
        layout.itemSize = CGSize(width: width, height: height)

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.top.equalTo(self)
            make.left.equalTo(self)
            make.right.equalTo(self)
            make.height.equalTo(self.collectionView.snp.width).multipliedBy(300.0 / 360.0)
        }

        collectionView.register(
            ImageCollectionViewCell.self,
            forCellWithReuseIdentifier: App.CellIdentifier.imageCellId
        )
    }

    private func setupCollectionOverlay() {
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.16)
        overlayView.isUserInteractionEnabled = false
        addSubview(overlayView)
        overlayView.snp.makeConstraints { (make) in
            make.top.equalTo(self)
            make.left.equalTo(self)
            make.right.equalTo(self)
            make.height.equalTo(self.collectionView.snp.width).multipliedBy(300.0 / 360.0)
        }

        addSubview(closeButton)
        closeButton.snp.makeConstraints { (make) in
            make.top.equalTo(self).inset(App.Layout.itemSpacingMedium)
            make.right.equalTo(self).inset(App.Layout.itemSpacingMedium)
            make.size.equalTo(CGSize(width: 40, height: 40))
        }

        label.backgroundColor = .white
        label.font = App.Font.label
        label.textColor = App.Color.slateGrey
        label.text = NSLocalizedString("questionnaire", comment: "").uppercased()
        label.layer.cornerRadius = App.Layout.cornerRadiusSmall / 2
        label.layer.masksToBounds = true
        addSubview(label)
        label.snp.makeConstraints { (make) in
            make.left.equalTo(self).inset(App.Layout.sideOffset)
            make.centerY.equalTo(self.closeButton)
        }

        pageControl.backgroundColor = .white
        pageControl.numberOfPages = images.count
        pageControl.currentPage = 0
        pageControl.hidesForSinglePage = true
        pageControl.pageIndicatorTintColor = App.Color.slateGrey.withAlphaComponent(0.32)
        pageControl.currentPageIndicatorTintColor = App.Color.slateGrey
        pageControl.isUserInteractionEnabled = false
        addSubview(pageControl)
        pageControl.snp.makeConstraints { (make) in
            make.top.equalTo(self.collectionView.snp.bottom)
            make.left.equalTo(self)
            make.right.equalTo(self)
            make.height.equalTo(20)
        }
    }

    private func setupAuthorViews() {
        addSubview(authorContainerView)
        authorContainerView.snp.makeConstraints { (make) in
            make.top.equalTo(self.pageControl.snp.bottom)
            make.left.equalTo(self)
            make.right.equalTo(self)
        }

        authorImageView.layer.cornerRadius = App.Layout.cornerRadiusSmall
        authorImageView.layer.masksToBounds = true
        authorContainerView.addSubview(authorImageView)
        authorImageView.snp.makeConstraints { (make) in
            make.left.equalTo(self.authorContainerView).inset(App.Layout.sideOffset)
            make.size.equalTo(CGSize(width: 40, height: 40))
            make.centerY.equalTo(self.authorContainerView)
                .offset(-App.Layout.itemSpacingSmall / 2)
        }

        authorLabel.font = App.Font.bodyAlts
        authorLabel.lineBreakMode = .byWordWrapping
        authorLabel.numberOfLines = 0
        authorLabel.textColor = .black
        authorContainerView.addSubview(authorLabel)
        authorLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.authorContainerView).inset(App.Layout.itemSpacingSmall)
            make.left.equalTo(self.authorImageView.snp.right)
                .offset(App.Layout.itemSpacingMedium)
            make.right.equalTo(self.authorContainerView).inset(App.Layout.sideOffset)
        }

        publishDateLabel.font = App.Font.body
        publishDateLabel.textColor = App.Color.steel
        authorContainerView.addSubview(publishDateLabel)
        publishDateLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.authorLabel.snp.bottom)
                .offset(App.Layout.itemSpacingSmall / 2)
            make.left.equalTo(self.authorLabel)
            make.bottom.equalTo(self.authorContainerView)
                .inset(App.Layout.itemSpacingMedium)
            make.right.equalTo(self.authorContainerView).inset(App.Layout.sideOffset)
        }
    }

    private func setupSeparatorView() {
        separatorView.backgroundColor = App.Color.coolGrey
        addSubview(separatorView)
        separatorView.snp.makeConstraints { (make) in
            make.top.equalTo(self.authorContainerView.snp.bottom)
            make.left.equalTo(self).inset(App.Layout.sideOffset)
            make.bottom.equalTo(self)
            make.right.equalTo(self).inset(App.Layout.sideOffset)
            make.height.equalTo(0.5)
        }
    }

}

extension QuestionnaireHeaderView: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let aCell = collectionView.dequeueReusableCell(
            withReuseIdentifier: App.CellIdentifier.imageCellId,
            for: indexPath
        )
        guard let cell = aCell as? ImageCollectionViewCell else {
            return UICollectionViewCell()
        }

        ImageDownloader.set(image: images[indexPath.item], to: cell.imageView)
        cell.imageRadius = 0

        return cell
    }
}

extension QuestionnaireHeaderView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        didTapImage?(images[indexPath.item], images)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let width = scrollView.frame.size.width
        let page = (scrollView.contentOffset.x + 0.5 * width) / width
        pageControl.currentPage = max(min(Int(page), images.count - 1), 0)
    }
}
