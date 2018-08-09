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
import Kingfisher

class BiClubViewController: UIViewController {
    
    private var headerView: BiclubHeaderView = {
        let view = BiclubHeaderView()
        return view
    }()
    
    private var qrcodeView = QRCodeContainerView()
    
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
        scrollview.delegate = self
        scrollview.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        scrollview.contentSize = CGSize(width: screenSize.width, height: screenSize.height + 50)
    }

    fileprivate func setupheaderView() {
        scrollview.addSubview(headerView)
        headerView.frame = CGRect(x: padding, y: padding, width: screenSize.width - (padding * 2), height: 325)
    }
    
    fileprivate func setupQRCodeView() {
        qrcodeView.translatesAutoresizingMaskIntoConstraints = false
        
        scrollview.addSubview(qrcodeView)
        let paddingQrcodeView = screenSize.width / 5
        
        qrcodeView.anchor(top: headerView.bottomAnchor, left: headerView.leftAnchor, bottom: nil, right: headerView.rightAnchor, paddingTop: padding-10, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: paddingQrcodeView * 3)

        qrcodeView.backgroundColor = .blue
    }

}

extension BiClubViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
    
    // any offset changes
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        
    }
  
    // called on start of dragging (may require some time and or distance to move)
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
    }
    
    // called on finger up if the user dragged. velocity is in points/millisecond. targetContentOffset may be changed to adjust where the scroll view comes to rest
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
    }

    // called on finger up if the user dragged. decelerate is true if it will continue moving afterwards
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
    }
    
    // called on finger up as we are moving
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        
    }
    
    // called when scroll view grinds to a halt
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
    }

    // called when setContentOffset/scrollRectVisible:animated: finishes. not called if not animating
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        
    }
    
    // return a view that will be scaled. if delegate returns nil, nothing happens
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        
        return UIView()
    }
    
    // called before the scroll view begins zooming its content
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        
    }
    
    // scale between minimum and maximum. called after any 'bounce' animations
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        
    }
    
    // return a yes if you want to scroll to the top. if not defined, assumes YES
    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        
        return false
    }
    
     // called when scrolling animation finished. may be called immediately if already at top
    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        
    }
    
    // Also see -[UIScrollView adjustedContentInsetDidChange] ios(11.0)
    func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) {
        
    }

    
}







