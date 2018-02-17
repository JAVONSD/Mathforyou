//
//  SearchView.swift
//  Life
//
//  Created by Shyngys Kassymov on 16.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import DynamicColor
import Material
import SnapKit

class SearchView: UIView, UITextFieldDelegate {

    private(set) lazy var searchBar = TextField(frame: .zero)

    var edgeInsets: UIEdgeInsets = .zero {
        didSet {
            searchBar.snp.remakeConstraints { [weak self] (make) in
                guard let `self` = self else { return }
                make.top.equalTo(self).inset(edgeInsets.top)
                make.left.equalTo(self).inset(edgeInsets.left)
                make.right.equalTo(self).inset(edgeInsets.right)
                make.height.equalTo(self.searchBarHeight)
            }
        }
    }

    var searchBarHeight: CGFloat = 36 {
        didSet {
            searchBar.snp.remakeConstraints { [weak self] (make) in
                guard let `self` = self else { return }
                make.top.equalTo(self).inset(edgeInsets.top)
                make.left.equalTo(self).inset(edgeInsets.left)
                make.right.equalTo(self).inset(edgeInsets.right)
                make.height.equalTo(self.searchBarHeight)
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI

    private func setupUI() {
        backgroundColor = .clear

        let searchImageContainer = UIView(frame: .init(x: 0, y: 0, width: 32, height: 36))

        let searchImage = UIImageView(frame: .init(
            origin: .zero,
            size: .init(width: 14, height: 14))
        )
        searchImage.contentMode = .scaleAspectFit
        searchImage.image = #imageLiteral(resourceName: "search")
        searchImage.tintColor = App.Color.coolGrey
        searchImageContainer.addSubview(searchImage)
        searchImage.snp.makeConstraints { (make) in
            make.centerY.equalTo(searchImageContainer)
            make.centerX.equalTo(searchImageContainer).offset(1)
            make.size.equalTo(CGSize(width: 16, height: 16))
        }

        searchBar.layer.cornerRadius = App.Layout.cornerRadiusSmall
        searchBar.layer.masksToBounds = true
        searchBar.backgroundColor = UIColor(red: 142/255.0, green: 142/255.0, blue: 147/255.0, alpha: 0.12)
        searchBar.placeholder = NSLocalizedString("search", comment: "")
        searchBar.placeholderLabel.font = App.Font.body
        searchBar.placeholderLabel.textColor = App.Color.steel
        searchBar.isDividerHidden = true

        searchBar.leftView = searchImageContainer
        searchBar.leftViewMode = .always
        searchBar.leftViewOffset = 0
        searchBar.textInset = 0
        searchBar.delegate = self

        addSubview(searchBar)
        searchBar.snp.makeConstraints { [weak self] (make) in
            guard let `self` = self else { return }
            make.top.equalTo(self).inset(edgeInsets.top)
            make.left.equalTo(self).inset(edgeInsets.left)
            make.right.equalTo(self).inset(edgeInsets.right)
            make.height.equalTo(self.searchBarHeight)
        }
    }

    // MARK: - UITextFieldDelegate

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}
