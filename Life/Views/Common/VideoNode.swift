//
//  VideoNode.swift
//  Life
//
//  Created by Shyngys Kassymov on 02.03.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import AVFoundation

class VideoNode: ASCellNode {

    private(set) var videoNode: ASVideoNode!
    private(set) var overlayNode: ASDisplayNode!

    private(set) var video: String
    private(set) var size: CGSize

    init(video: String,
         size: CGSize,
         cornerRadius: CGFloat = App.Layout.cornerRadius,
         backgroundColor: UIColor = App.Color.silver) {
        self.video = video
        self.size = size

        super.init()

        videoNode = ASVideoNode()
        videoNode.backgroundColor = backgroundColor
        videoNode.cornerRadius = cornerRadius
        videoNode.style.preferredSize = size
        videoNode.shouldAutoplay = false
        videoNode.shouldAutorepeat = false
        videoNode.muted = true
        videoNode.isUserInteractionEnabled = false
        addSubnode(videoNode)
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASWrapperLayoutSpec(layoutElement: videoNode)
    }

    override func didLoad() {
        super.didLoad()

        let token = User.current.token ?? ""
        let headers = ["Authorization": "Bearer \(token)"]

        if let url = URL(string: "\(App.String.apiBaseUrl)/Files/\(video)") {
            videoNode.asset = AVURLAsset(
                url: url,
                options: [
                    "AVURLAssetHTTPHeaderFieldsKey": headers
                ]
            )
        }
    }

}
