//
//  ImageNode.swift
//  Life
//
//  Created by Shyngys Kassymov on 20.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import Kingfisher

class ImageNode: ASCellNode {

    private(set) var imageNode: ASNetworkImageNode!
    private(set) var overlayNode: ASDisplayNode!

    private(set) var image: String
    private(set) var size: CGSize
    private(set) var imageIsAvatar: Bool

    init(image: String,
         size: CGSize,
         cornerRadius: CGFloat = App.Layout.cornerRadius,
         backgroundColor: UIColor = App.Color.silver,
         overlayColor: UIColor = .clear,
         imageIsAvatar: Bool = false) {
        self.image = image
        self.size = size
        self.imageIsAvatar = imageIsAvatar

        super.init()

        imageNode = ASNetworkImageNode()
        imageNode.backgroundColor = backgroundColor
        imageNode.contentMode = .scaleAspectFill
        imageNode.cornerRadius = cornerRadius
        imageNode.style.preferredSize = size
        addSubnode(imageNode)

        overlayNode = ASDisplayNode()
        overlayNode.backgroundColor = overlayColor
        overlayNode.cornerRadius = cornerRadius
        overlayNode.style.preferredSize = size
        imageNode.addSubnode(overlayNode)
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        imageNode.layoutSpecBlock = { (_, _) in
            return ASWrapperLayoutSpec(layoutElement: self.overlayNode)
        }

        return ASWrapperLayoutSpec(layoutElement: imageNode)
    }

    override func didLoad() {
        super.didLoad()

        if imageIsAvatar {
            ImageDownloader.download(image: "", employeeCode: image, completion: { image in
                self.imageNode.image = image
            })
        } else {
            ImageDownloader.download(image: image) { (image) in
                self.imageNode.image = image
            }
        }
    }

}
