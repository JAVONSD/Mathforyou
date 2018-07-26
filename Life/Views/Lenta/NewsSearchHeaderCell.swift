//
//  NewsSearchHeaderCell.swift
//  Life
//
//  Created by 123 on 26.07.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import Kingfisher

class NewsSearchHeaderCell: ASCellNode {
    
    private(set) var labelContainerNode: ASDisplayNode!
    private(set) var titleNode: ASTextNode!
    
    private(set) var slide: SliderViewModel
    private(set) var width: CGFloat
    private(set) var height: CGFloat
    
    var leftInset: CGFloat = 0
    
    var didSelectSlide: ((_ index: Int) -> Void)?
    
    init(slide: SliderViewModel,
         width: CGFloat,
         height: CGFloat,
         slideCornerRadius: CGFloat) {
        
        self.slide = slide
        self.width = width
        self.height = height
        
        super.init()
        
        cornerRadius = slideCornerRadius

        titleNode = ASTextNode()
        titleNode.attributedText = attTitle("news")
        titleNode.maximumNumberOfLines = 1
        titleNode.backgroundColor = App.Color.coolGrey
        addSubnode(titleNode)
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        let insets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        let inset = ASInsetLayoutSpec(insets: insets, child: titleNode)
        
        let centerSpec = ASCenterLayoutSpec(
            centeringOptions: ASCenterLayoutSpecCenteringOptions.Y,
            sizingOptions: ASCenterLayoutSpecSizingOptions.minimumX,
            child: inset)
        
        return centerSpec
    }
    
    override func didLoad() {
        super.didLoad()
        
    }
    
    // MARK: - Methods
    
    private func attTitle(_ string: String) -> NSMutableAttributedString {
        let attText = NSMutableAttributedString(string: string)
        
        let allRange = NSRange(location: 0, length: attText.length)
        attText.addAttribute(.font, value: App.Font.body, range: allRange)
        attText.addAttribute(.foregroundColor, value: UIColor.black, range: allRange)
        
        return attText
    }
    
}







