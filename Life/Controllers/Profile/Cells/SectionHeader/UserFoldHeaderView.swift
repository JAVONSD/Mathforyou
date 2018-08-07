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
    func showHistoryDetails(header: UserFoldHeaderView)
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
                
                switch modelItem.type {
                case .personal, .medical, .workexperiance:
                    weakSelf.foldLabel.font = App.Font.subhead
                case .education, .history:
                    weakSelf.foldLabel.font = UIFont.italicSystemFont(ofSize: 13)
                default:
                    break
                }

//                let title = modelItem.isCollapsed ? "\(String(describing: modelItem.sectionTitle))" : "Скрыть"
//                weakSelf.foldButton.setTitle(title, for: .normal)
                
                weakSelf.foldLabel.text = " \(String(describing: modelItem.sectionTitle))"
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

    let foldLabel: UILabel = {
        let lbl = UILabel()
        lbl.textColor = App.Color.azure
        lbl.font = App.Font.subhead
        lbl.backgroundColor = .white
        return lbl
    }()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        backgroundColor = .white
        
        // To detect a user interaction we can set a TapGestureRecognizer in our header
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapHeader))
        tapGesture.numberOfTapsRequired = 1
        addGestureRecognizer(tapGesture)
        
        setupViews()
    }
 
    fileprivate func setupViews() {
        addSubview(foldLabel)
        foldLabel.snp.makeConstraints {
            $0.top.equalTo(self.snp.top)
            $0.right.equalTo(self.snp.right)
            $0.bottom.equalTo(self.snp.bottom)
            $0.left.equalTo(self.snp.left).offset(20)
        }
    }
    
    @objc private func didTapHeader() {
        if let modelItem = modelItem {
            switch modelItem.type {
            case .education:
                delegate?.showDetails(header: self)
            case .history:
                delegate?.showHistoryDetails(header: self)
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
























