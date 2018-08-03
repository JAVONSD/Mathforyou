//
//  UserFoldHeaderView.swift
//  Life
//
//  Created by 123 on 01.08.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit


protocol HeaderViewDelegate: class {
    func toggleSection(header: UserFoldHeaderView, section: Int)
    func showDetails(header: UserFoldHeaderView)
}

class UserFoldHeaderView: UITableViewHeaderFooterView {
    
    var modelItem: ProfileViewModelItem? {
        didSet {
            guard let modelItem = modelItem else {
                return
            }
            
            setCollapsed(collapsed: modelItem.isCollapsed)
            
            DispatchQueue.main.async { [weak self] in
                guard
                let weakSelf = self,
                let modelItem = weakSelf.modelItem
                else { return }
                
                let title = modelItem.isCollapsed ? "▽  Показать \(String(describing: modelItem.sectionTitle))" : "△  \(String(describing: modelItem.sectionTitle))"
                weakSelf.foldButton.setTitle(title, for: .normal)
            }
            
        }
    }
    
    var titleLabel: UILabel?
    
    weak var delegate: HeaderViewDelegate?
    
    static var identifier: String {
        return String(describing: self)
    }
    
    // We will use the section variable to store the current section index
    var section: Int = 0
    
    let foldButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.showsTouchWhenHighlighted = true
        btn.setTitleColor(App.Color.azure, for: .normal)
        btn.titleLabel?.font = App.Font.subtitle
        btn.titleEdgeInsets = UIEdgeInsetsMake(0, -40, 0, 0)
        btn.addTarget(self, action: #selector(didTapHeader), for: .touchUpInside)
        btn.backgroundColor = .white
        return btn
    }()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        setupViews()
    }
 
    fileprivate func setupViews() {
        addSubview(foldButton)
        foldButton.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    @objc private func didTapHeader() {
        if let modelItem = modelItem {
            switch modelItem.type {
            case .education:
                delegate?.showDetails(header: self)
            default:
                break
            }
        }
        
        delegate?.toggleSection(header: self, section: section)
    }
    
    func setCollapsed(collapsed: Bool) {
        // When we call this method for collapsed state,
        // it will rotate the arrow to the original position,
        // for expanded state it will rotate the arrow to pi radians.
//        DispatchQueue.main.async { [weak self] in
//            guard let weakSelf = self else { return }
//
//            let title = collapsed ? "▽  Показать \(String(describing: weakSelf.titleLabel))" : "△  \(String(describing: weakSelf.titleLabel))"
//            weakSelf.foldButton.setTitle(title, for: .normal)
//        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension UIView {
    func rotate(_ toValue: CGFloat, duration: CFTimeInterval = 0.2) {
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        
        animation.toValue = toValue
        animation.duration = duration
        animation.isRemovedOnCompletion = false
        animation.fillMode = kCAFillModeForwards
        
        self.layer.add(animation, forKey: nil)
    }
}
























