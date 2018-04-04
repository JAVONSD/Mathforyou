//
//  AttachmentsView.swift
//  Life
//
//  Created by Shyngys Kassymov on 04.04.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import Material
import SnapKit

class AttachmentsView: UIView {

    private(set) var attachments = [Attachment]()

    let collectionView: UICollectionView

    var didTapAdd: (() -> Void)?

    override init(frame: CGRect) {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = .init(
            top: 0,
            left: App.Layout.sideOffset - AttachmentCollectionViewCell.sideInset,
            bottom: 0,
            right: App.Layout.sideOffset - AttachmentCollectionViewCell.sideInset
        )
        layout.itemSize = CGSize(
            width: AttachmentCollectionViewCell.width(),
            height: AttachmentCollectionViewCell.height()
        )
        layout.scrollDirection = .horizontal

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)

        super.init(frame: frame)

        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Methods

    public func add(attachment: Attachment) {
        if attachments.contains(attachment) {
            return
        }

        let index = attachments.count

        attachments.append(attachment)

        collectionView.performBatchUpdates({
            collectionView.insertItemsAtIndexPaths([IndexPath(item: index, section: 0)], animationStyle: .automatic)
        }, completion: nil)
    }

    public func add(attachments: [Attachment]) {
        let attachments = attachments.filter { attachment -> Bool in
            return !self.attachments.contains(attachment)
        }

        if attachments.isEmpty {
            return
        }

        let index = self.attachments.count

        self.attachments.append(contentsOf: attachments)

        collectionView.performBatchUpdates({
            for idx in 0..<attachments.count {
                collectionView.insertItemsAtIndexPaths([IndexPath(item: index + idx, section: 0)], animationStyle: .automatic)
            }
        }, completion: nil)
    }

    // MARK: - UI

    private func setupUI() {
        collectionView.backgroundColor = .white
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.alwaysBounceHorizontal = true
        addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
            make.height.equalTo(AttachmentCollectionViewCell.height())
        }

        collectionView.register(
            AttachmentCollectionViewCell.self,
            forCellWithReuseIdentifier: App.CellIdentifier.attachmentCellId
        )
    }

}

extension AttachmentsView: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return attachments.count + 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let aCell = collectionView.dequeueReusableCell(
            withReuseIdentifier: App.CellIdentifier.attachmentCellId,
            for: indexPath
        )
        guard let cell = aCell as? AttachmentCollectionViewCell else {
            return UICollectionViewCell()
        }

        cell.titleLabel.text = nil
        cell.subtitleLabel.text = nil
        cell.imageView.image = nil

        if indexPath.item < attachments.count {
            let attachment = attachments[indexPath.item]
            if attachment.type == .file {
                cell.titleLabel.text = ".\(attachment.extensionName)".uppercased()
            } else {
                cell.imageView.contentMode = .scaleAspectFill
                cell.imageView.image = UIImage(contentsOfFile: attachment.url.path)
            }
            cell.subtitleLabel.text = attachment.fileName

            cell.containerView.backgroundColor = App.Color.paleGreyTwo

            cell.deleteButton.isHidden = false
            cell.didTapDelete = { [weak self] sender in
                guard let `self` = self else { return }

                let point = sender.convert(CGPoint.zero, to: self.collectionView)
                if let indexPath = self.collectionView.indexPathForItem(at: point) {
                    self.attachments.remove(at: indexPath.item)
                    self.collectionView.deleteItemsAtIndexPaths([indexPath], animationStyle: .automatic)
                }
            }
        } else {
            cell.containerView.backgroundColor = .clear

            cell.imageView.contentMode = .center
            cell.imageView.image = #imageLiteral(resourceName: "plus")
            cell.imageView.tintColor = App.Color.azure

            cell.deleteButton.isHidden = true
            cell.didTapDelete = nil
        }

        return cell
    }
}

extension AttachmentsView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == attachments.count {
            didTapAdd?()
        }
    }
}
