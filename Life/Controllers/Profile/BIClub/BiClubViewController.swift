//
//  BiClubViewController.swift
//  Life
//
//  Created by 123 on 09.08.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import Material
import RxCocoa
import RxSwift
import SnapKit

class BiClubViewController: UIViewController {
    
    private(set) var headerView: BiclubHeaderView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setupViews()
    }
    
    fileprivate func setupViews() {
        setupTabItem()
        
        
    }
    
    fileprivate func setupTabItem() {
        tabItem.title = NSLocalizedString("bi club", comment: "").uppercased()
        tabItem.titleLabel?.font = App.Font.buttonSmall
    }


}








