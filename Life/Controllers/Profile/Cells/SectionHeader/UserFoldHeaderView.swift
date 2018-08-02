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
}

class UserFoldHeaderView: UITableViewHeaderFooterView {
    
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
        delegate?.toggleSection(header: self, section: section)
    }
    
    func setCollapsed(collapsed: Bool, section: Int) {
        // When we call this method for collapsed state,
        // it will rotate the arrow to the original position,
        // for expanded state it will rotate the arrow to pi radians.
        DispatchQueue.main.async { [weak self] in
            guard let weakSelf = self else { return }
            
            var tempTitles = ("", "")
            switch section {
            case 1:
                tempTitles = ("Показать личные и семья", "Скрыть личные и семья")
            case 2:
                tempTitles = ("Показать трудовая деятельность", "Скрыть трудовая деятельность")
            case 3:
                tempTitles = ("Показать медосмотр", "Скрыть медосмотр")
            default:
                tempTitles = ("", "")
            }
            let title = collapsed ? "▽  \(tempTitles.0)" : "△  \(tempTitles.1)"
            weakSelf.foldButton.setTitle(title, for: .normal)
        }
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
























