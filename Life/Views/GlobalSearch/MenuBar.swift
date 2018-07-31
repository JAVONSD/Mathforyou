//
//  MenuBar.swift
//  Life
//
//  Created by 123 on 27.07.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import SnapKit

protocol MenuBarProtocol: class {
    func scrollToMenuIndex(sender: MenuBar, menuIndex: Int)
}

class MenuBar: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    //MARK: - Properties
    struct MenuBarCellIdentifiers {
        static let cellID = "cellID"
    }
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.delegate = self
        cv.dataSource = self
        return cv
    }()
    
    let titleNames = ["News", "None", "None", "Tags"]
    
    weak var delegate: MenuBarProtocol?
    
    //MARK: - View Life Circle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        collectionView.register(MenuCell.self, forCellWithReuseIdentifier: MenuBarCellIdentifiers.cellID)
        
        self.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: self.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
            ])
        
        // item по-умолчанию
        let indexPath = IndexPath(item: 0, section: 0)
        collectionView.selectItem(at: indexPath, animated: false, scrollPosition: UICollectionViewScrollPosition() )
        
        setupHorizontalBar()
    }
    
    override func layoutSubviews() {
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.invalidateLayout()
        }
    }
    
    var horizontalLeftAnchor: NSLayoutConstraint?
    
    func setupHorizontalBar() {
        let horizontalBarView = UIView()
        horizontalBarView.backgroundColor = UIColor(white: 0.95, alpha: 1)
        horizontalBarView.translatesAutoresizingMaskIntoConstraints =  false
        
        addSubview(horizontalBarView)
        horizontalLeftAnchor = horizontalBarView.leftAnchor.constraint(equalTo: self.leftAnchor)
        horizontalLeftAnchor?.isActive = true
        
        NSLayoutConstraint.activate([
            horizontalBarView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            horizontalBarView.widthAnchor.constraint(equalTo: self.widthAnchor , multiplier: 1/4),
            horizontalBarView.heightAnchor.constraint(equalToConstant: 8)
            ])
    }
    
    //MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // при тапе на item в menuBar сдвигаем item VC на этот item
        delegate?.scrollToMenuIndex(sender: self, menuIndex: indexPath.item)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MenuBarCellIdentifiers.cellID, for: indexPath) as! MenuCell
        
        let title = titleNames[indexPath.item]
        cell.activeButton.setTitle(title, for: .normal)
        
        return cell
    }
    
    //MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: frame.width / 4, height: frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

//MARK: - Setup MenuCell

class MenuCell: BaseCell {
    
//    let activeButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.setTitle("News", for: .normal)
//        button.tintColor = .black
//        button.fontSize = 12
//        button.addTarget(self, action: #selector(handleActiveButtun), for: .touchUpInside)
//        return button
//    }()
    
    let activeButton: UIButton = {
        let fb = UIButton()
        fb.layer.cornerRadius = 5
        fb.setTitle("News", for: .normal)
        fb.setTitleColor(.black, for: .normal)
        fb.titleLabel?.font = App.Font.buttonSmall
        fb.titleEdgeInsets = UIEdgeInsets(top: 0, left: -2, bottom: 0, right: 0)
        fb.addTarget(self, action: #selector(handleActiveButtun), for: .touchUpInside)
        return fb
    }()
    
    @objc
    func handleActiveButtun() {
        print("------------ active")
    }
    
    // меняем цвет когда селектед
    override var isSelected: Bool {
        didSet {
            let selectedColor = isSelected ? App.Color.azure : .black
            activeButton.setTitleColor(selectedColor, for: .normal)
        }
    }
    
    override func setupViews() {
        super.setupViews()
        
        addSubview(activeButton)
        activeButton.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
            $0.width.height.equalToSuperview()
        }
    }
    
}


class BaseCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    func setupViews() { }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}










