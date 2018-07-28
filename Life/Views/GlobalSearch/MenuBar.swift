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
    func scrollToMenuIndex(menuIndex: Int)
}

class MenuBar: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    //MARK: - Properties

    weak var delegate: MenuBarProtocol?
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .white
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.delegate = self
        cv.dataSource = self
        return cv
    }()
    
    let cellID = "cellID"
    let titleNames = ["Новости", "Предложения", "Вопросы"]
    
    //MARK: - View Life Circle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        collectionView.register(MenuCell.self, forCellWithReuseIdentifier: cellID)
        
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
        horizontalBarView.backgroundColor = UIColor.init(red: 0.06, green: 0.54, blue: 0.92, alpha: 1)
        horizontalBarView.translatesAutoresizingMaskIntoConstraints =  false
        
        addSubview(horizontalBarView)
        horizontalLeftAnchor = horizontalBarView.leftAnchor.constraint(equalTo: self.leftAnchor)
        horizontalLeftAnchor?.isActive = true
        
        NSLayoutConstraint.activate([
            horizontalBarView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            horizontalBarView.widthAnchor.constraint(equalTo: self.widthAnchor , multiplier: 1/3),
            horizontalBarView.heightAnchor.constraint(equalToConstant: 2)
            ])
    }
    
    //MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.scrollToMenuIndex(menuIndex: indexPath.item)
        collectionView.selectItem(at: indexPath, animated: false, scrollPosition: UICollectionViewScrollPosition() )
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! MenuCell
        cell.textLabel.text = titleNames[indexPath.item]
        cell.tintColor = App.Color.azure
        return cell
    }
    
    //MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: frame.width / 3, height: frame.height)
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

    let textLabel: UILabel = {
        let lb = UILabel()
        lb.font = App.Font.captionAlts
        lb.textAlignment = .center
        lb.textColor = App.Color.steel
        return lb
    }()

    override var isSelected: Bool {
        didSet {
            textLabel.textColor = isSelected ? App.Color.black : App.Color.steel
        }
    }
    
    override func setupViews() {
        super.setupViews()
        
        addSubview(textLabel)
        textLabel.snp.makeConstraints { make in
            make.height.equalTo(28)
            make.left.equalTo(self)
            make.right.equalTo(self)
            make.centerY.equalToSuperview()
        }
    }
    
}

class BaseCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    func setupViews() {
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}










