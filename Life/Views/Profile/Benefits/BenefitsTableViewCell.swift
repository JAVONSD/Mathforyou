//
//  BenefitsTableViewCell.swift
//  Life
//
//  Created by Shyngys Kassymov on 13.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import Material
import SnapKit

class BenefitsTableViewCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate {

    private(set) var collectionView: UICollectionView?

    static let cellHeight: CGFloat = 168

    var numberOfItems: (() -> Int)?
    var configureCell: ((ImageCollectionViewCell, IndexPath) -> Void)?
    var didSelectItem: ((IndexPath) -> Void)?

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI

    private func setupUI() {
        backgroundColor = .clear
        backgroundView = nil
        contentView.backgroundColor = .clear

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 112, height: 72)
        layout.minimumInteritemSpacing = App.Layout.itemSpacingSmall
        layout.minimumLineSpacing = App.Layout.itemSpacingSmall
        layout.sectionInset = .init(
            top: App.Layout.itemSpacingSmall,
            left: 0,
            bottom: App.Layout.itemSpacingSmall,
            right: 0
        )

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView?.contentInset = .init(
            top: 0,
            left: App.Layout.sideOffset,
            bottom: 0,
            right: App.Layout.sideOffset
        )

        guard let collectionView = collectionView else { return }

        collectionView.backgroundView = nil
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(
            ImageCollectionViewCell.self,
            forCellWithReuseIdentifier: App.CellIdentifier.biClubCollBenefitsCellId
        )

        contentView.addSubview(collectionView)
        collectionView.snp.makeConstraints { [weak self] (make) in
            guard let `self` = self else { return }
            make.edges.equalTo(self.contentView)
        }
    }

    // MARK: - UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let numberOfItems = numberOfItems {
            return numberOfItems()
        }
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellId = App.CellIdentifier.biClubCollBenefitsCellId
        let someCell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath)
        guard let cell = someCell as? ImageCollectionViewCell else {
            return ImageCollectionViewCell(frame: .zero)
        }

        if let configureCell = configureCell {
            configureCell(cell, indexPath)
        }

        return cell
    }

    // MARK: - UICollectionViewDelegate

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let didSelectItem = didSelectItem {
            didSelectItem(indexPath)
        }
    }

}
