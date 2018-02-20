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

    init(image: String, size: CGSize) {
        self.image = image
        self.size = size

        super.init()

        imageNode = ASNetworkImageNode()
        imageNode.backgroundColor = App.Color.silver
        imageNode.contentMode = .scaleAspectFill
        imageNode.cornerRadius = App.Layout.cornerRadius
        imageNode.style.preferredSize = size
        addSubnode(imageNode)
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASWrapperLayoutSpec(layoutElement: imageNode)
    }

    override func didLoad() {
        super.didLoad()

        let modifier = AnyModifier { request in
            var r = request
            let token = User.current.token ?? ""
            r.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            return r
        }

        if let url = URL(string: image) {
            ImageDownloader
                .default
                .downloadImage(
                    with: url,
                    options: [.requestModifier(modifier)],
                    progressBlock: nil) { (image, _, _, _) in
                        self.imageNode.image = image
            }
        }
    }

}
