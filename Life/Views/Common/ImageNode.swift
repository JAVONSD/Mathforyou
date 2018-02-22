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

    private(set) var image: String
    private(set) var size: CGSize

    init(image: String,
         size: CGSize,
         cornerRadius: CGFloat = App.Layout.cornerRadius,
         backgroundColor: UIColor = App.Color.silver) {
        self.image = image
        self.size = size

        super.init()

        imageNode = ASNetworkImageNode()
        imageNode.backgroundColor = backgroundColor
        imageNode.contentMode = .scaleAspectFill
        imageNode.cornerRadius = cornerRadius
        imageNode.style.preferredSize = size
        addSubnode(imageNode)
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASWrapperLayoutSpec(layoutElement: imageNode)
    }

    override func didLoad() {
        super.didLoad()

        ImageDownloader.download(image: image) { (image) in
            self.imageNode.image = image
        }
    }

}
