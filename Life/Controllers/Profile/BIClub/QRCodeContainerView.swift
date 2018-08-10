////
////  QRCodeContainerView.swift
////  Life
////
////  Created by 123 on 09.08.2018.
////  Copyright © 2018 Shyngys Kassymov. All rights reserved.
////
//
//import UIKit
//import Material
//import RxCocoa
//import RxSwift
//import SnapKit
//import QRCode
//
//class QRCodeContainerView: UIView {
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        
//        setupviews()
//    }
//    
//    let imageViewLarge = UIImageView()
//    
//    fileprivate func setupviews() {
//        //        imageViewLarge.image = #imageLiteral(resourceName: "bi")
//        
//        //        imageViewLarge.image = {
//        //            var qrCode = QRCode("http://github.com/aschuch/QRCode")!
//        //            qrCode.size = self.imageViewLarge.bounds.size
//        //            qrCode.errorCorrection = .High
//        //            return qrCode.image
//        //        }()
//        
//        addSubview(imageViewLarge)
//        
//        imageViewLarge.snp.makeConstraints {
//            $0.edges.equalToSuperview()
//        }
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//}
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
