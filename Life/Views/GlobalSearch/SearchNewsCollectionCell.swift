//
//  SearchNewsCollectionCell.swift
//  Life
//
//  Created by 123 on 31.07.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import Material

class SearchNewsCollectionCell: BaseCell {

    fileprivate var card: Card!
    
    fileprivate var toolbar: Toolbar!
    fileprivate var moreButton: IconButton!
    
    fileprivate var contentLabel: UILabel!
    
    fileprivate var bottomBar: Bar!
    fileprivate var dateFormatter: DateFormatter!
    fileprivate var dateLabel: UILabel!
    fileprivate var favoriteButton: IconButton!
    
    override func setupViews() {
        super.setupViews()

        prepareDateFormatter()
        prepareDateLabel()
        prepareFavoriteButton()
        prepareMoreButton()
        prepareToolbar()
        prepareContentLabel()
        prepareBottomBar()
        prepareCard()
    }
    
    fileprivate func prepareDateFormatter() {
        dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
    }
    
    fileprivate func prepareDateLabel() {
        dateLabel = UILabel()
        dateLabel.font = RobotoFont.regular(with: 12)
        dateLabel.textColor = Color.grey.base
        dateLabel.text = dateFormatter.string(from: Date.distantFuture)
    }
    
    fileprivate func prepareFavoriteButton() {
        favoriteButton = IconButton(image: Icon.favorite, tintColor: Color.red.base)
    }
    
    fileprivate func prepareMoreButton() {
        moreButton = IconButton(image: Icon.cm.moreVertical, tintColor: Color.grey.base)
    }
    
    fileprivate func prepareToolbar() {
        toolbar = Toolbar(rightViews: [moreButton])
        
        toolbar.title = "Material"
        toolbar.titleLabel.textAlignment = .left
        
        toolbar.detail = "Build Beautiful Software"
        toolbar.detailLabel.textAlignment = .left
        toolbar.detailLabel.textColor = Color.grey.base
    }
    
    fileprivate func prepareContentLabel() {
        contentLabel = UILabel()
        contentLabel.numberOfLines = 0
        contentLabel.text = "Material is an animation and graphics framework that is used to create beautiful applications."
        contentLabel.font = RobotoFont.regular(with: 14)
    }
    
    fileprivate func prepareBottomBar() {
        bottomBar = Bar()
        
        bottomBar.leftViews = [favoriteButton]
        bottomBar.rightViews = [dateLabel]
    }
    
    fileprivate func prepareCard() {
        card = Card()
        
        card.toolbar = toolbar
        card.toolbarEdgeInsetsPreset = .square3
        card.toolbarEdgeInsets.bottom = 0
        card.toolbarEdgeInsets.right = 8
        
        card.contentView = contentLabel
        card.contentViewEdgeInsetsPreset = .wideRectangle3
        
        card.bottomBar = bottomBar
        card.bottomBarEdgeInsetsPreset = .wideRectangle2
        
        layout(card).horizontally(left: 20, right: 20).center()
    }
    
}
























