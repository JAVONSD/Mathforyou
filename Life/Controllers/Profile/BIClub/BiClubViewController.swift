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
import QRCode

class BiClubViewController: UIViewController {
    
    private var headerView: BiclubHeaderView = {
        let view = BiclubHeaderView()
        return view
    }()

    
    var scrollview: UIScrollView
    
    let screenSize = UIScreen.main.bounds
    let padding: CGFloat = 25
    
    init(_ scrollView: UIScrollView) {
        self.scrollview = scrollView
        self.scrollview.backgroundColor = .clear
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupViews()
    }
    
    fileprivate func setupViews() {
        setupTabItem()
        setupScrollview()
        setupheaderView()
        setupQRCodeView()
    }
    
    fileprivate func setupTabItem() {
        tabItem.title = NSLocalizedString("bi club", comment: "").uppercased()
        tabItem.titleLabel?.font = App.Font.buttonSmall
    }
    
    fileprivate func setupScrollview() {
        view.addSubview(scrollview)
        scrollview.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        scrollview.contentSize = CGSize(width: screenSize.width, height: screenSize.height + 50)
    }

    fileprivate func setupheaderView() {
        scrollview.addSubview(headerView)
        headerView.frame = CGRect(x: padding, y: padding, width: screenSize.width - (padding * 2), height: 325)
    }
    
    var imageViewLarge: UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFit
        return img
    }()
    
    fileprivate func setupQRCodeView() {
        let padd = (screenSize.width - 200) / 2
        imageViewLarge.frame = CGRect(x: padd, y: 350, width: 200, height: 200)
        scrollview.addSubview(imageViewLarge)
        
        imageViewLarge.image = {
            var profileString = ""
           
            if let profile: UserProfile = User.current.profile  {
                profileString = String(format: "%@\n%@\n%@\n%@", profile.fullname, profile.mobilePhoneNumber, profile.employeeCode, profile.email)
                let data = profileString.data(using: .utf8)!
                var qrCode = QRCode.init(data)
                qrCode.size = self.imageViewLarge.bounds.size
                qrCode.errorCorrection = .High
                return qrCode.image
            } else {
                let url = URL(string: "https://www.bi-group.org/ru/")!
                let qrCode = QRCode(url)
                return qrCode?.image
            }
        }()
    }

}






