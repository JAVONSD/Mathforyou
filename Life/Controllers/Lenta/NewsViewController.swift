//
//  NewsViewController.swift
//  Life
//
//  Created by Shyngys Kassymov on 22.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import IGListKit
import Lightbox
import Material
import NVActivityIndicatorView
import RxSwift
import SnapKit
import Hero

class NewsViewController: ASViewController<ASDisplayNode>, Stepper {

    private var listAdapter: ListAdapter!
    private(set) var collectionNode: ASCollectionNode!

    private var spinnerNode: ASDisplayNode!
    private(set) lazy var spinner = NVActivityIndicatorView(
        frame: .init(x: 0, y: 0, width: 44, height: 44),
        type: .circleStrokeSpin,
        color: App.Color.azure,
        padding: 0)

    private lazy var refreshCtrl = UIRefreshControl()

    private var fabButton: FABButton!

    var viewModel: NewsItemViewModel!

    var onUnathorizedError: (() -> Void)?

    let disposeBag = DisposeBag()
    
    // dismiss
    var panGR : UIPanGestureRecognizer!
    var progressBool : Bool = false
    var dismissBool : Bool = true

    init(viewModel: NewsItemViewModel) {
        self.viewModel = viewModel

        let node = ASDisplayNode()
        super.init(node: node)

        setupNodes()

        // IGList Adapter - kind of dataSource for collection view
        let updater = ListAdapterUpdater()
        listAdapter = ListAdapter(updater: updater, viewController: self, workingRangeSize: 0)
        listAdapter.dataSource = self
        // Connect list adapter to collection node
        listAdapter.setASDKCollectionNode(collectionNode)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
 
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionNode.view.backgroundColor = .white
        collectionNode.view.alwaysBounceVertical = true

        let ratio: CGFloat = 360.0 / 300.0
        let width = UIScreen.main.bounds.size.width
        let height = width / ratio

        collectionNode.view.scrollIndicatorInsets = .init(
            top: height,
            left: 0,
            bottom: 0,
            right: 0)

        refreshCtrl = UIRefreshControl()
        refreshCtrl.addTarget(self, action: #selector(refreshFeed), for: .valueChanged)
        refreshCtrl.tintColor = App.Color.azure
        collectionNode.view.addSubview(refreshCtrl)

        bind()
        setupGestureForDismiss()
    }
    
    
 
    // MARK: - Actions

    @objc
    private func handleShareButton() {
        let text = viewModel.news.title

        let textType = "Новость"
        let link = LinkBuilder.newsLink(for: viewModel.news.id)

        let shareText =
        """
        \(textType): "\(text)"
        Автор: \(viewModel.news.authorName)
        Ссылка: \(link)
        """

        let shareItems = [shareText]
        let activityViewController = UIActivityViewController(
            activityItems: shareItems,
            applicationActivities: nil
        )
        activityViewController.popoverPresentationController?.sourceView = self.view

        present(activityViewController, animated: true, completion: nil)
    }

    // MARK: - Bind

    private func bind() {
        viewModel.loading.asDriver()
            .drive(onNext: { [weak self] loading in
                guard let `self` = self else { return }
                loading ? self.spinner.startAnimating() : self.spinner.stopAnimating()
                self.spinnerNode.isHidden = !loading
                self.fabButton.isHidden = loading
            })
            .disposed(by: disposeBag)
    }

    // MARK: - Methods

    @objc
    private func refreshFeed() {
        guard let secCtrl = listAdapter
            .sectionController(for: viewModel) as? RefreshingSectionControllerType else {
                return
        }

        secCtrl.refreshContent {
            self.refreshCtrl.endRefreshing()
        }
    }

    private func open(image: URL, allImages: [URL]) {
        guard !allImages.isEmpty else { return }

        var images = allImages.map { LightboxImage(imageURL: $0) }
        let startIndex = allImages.index(of: image) ?? 0

        if !image.absoluteString.hasPrefix("http://") && !image.absoluteString.hasPrefix("https://") {
            images = allImages.map { url -> LightboxImage in
                guard let data = try? Data.init(contentsOf: url),
                    let image = UIImage(data: data) else {
                        return LightboxImage(imageURL: url)
                }
                return LightboxImage(image: image)
            }
        }

        let controller = LightboxController(images: images, startIndex: startIndex)
        controller.dynamicBackground = true

        present(controller, animated: true, completion: nil)
    }

    private func setupFABButton() {
        fabButton = FABButton(image: Icon.cm.share, tintColor: .white)
        fabButton.addTarget(self, action: #selector(handleShareButton), for: .touchUpInside)
        fabButton.pulseColor = .white
        fabButton.backgroundColor = App.Color.azure
        fabButton.shadowColor = App.Color.black12
        fabButton.depth = Depth(offset: Offset.init(horizontal: 0, vertical: 12), opacity: 1, radius: 12)
        fabButton.isHidden = true
    }

    // MARK: - UI

    private func setupNodes() {
        let layout = UICollectionViewFlowLayout()
        layout.sectionFootersPinToVisibleBounds = true
        collectionNode = ASCollectionNode(collectionViewLayout: layout)
        node.addSubnode(collectionNode)

        let fabNode = ASDisplayNode { () -> UIView in
            self.setupFABButton()
            let view = UIView()
            view.backgroundColor = .clear
            view.addSubview(self.fabButton)
            self.fabButton.snp.makeConstraints { (make) in
                make.size.equalTo(CGSize(width: 56, height: 56))
                make.edges.equalTo(view)
            }
            return view
        }
        fabNode.backgroundColor = .clear
        fabNode.style.preferredSize = CGSize(width: 56, height: 56)
        node.addSubnode(fabNode)

        spinnerNode = ASDisplayNode(viewBlock: { () -> UIView in
            self.spinner.startAnimating()
            return self.spinner
        })
        spinnerNode.backgroundColor = .clear
        spinnerNode.style.preferredSize = CGSize(width: 44, height: 44)
        node.addSubnode(spinnerNode)

        node.layoutSpecBlock = { (_, _) in
            let insetSpec = ASInsetLayoutSpec(insets: .init(
                top: 0,
                left: 0,
                bottom: 30,
                right: App.Layout.sideOffset), child: fabNode)
            let relativeSpec = ASRelativeLayoutSpec(
                horizontalPosition: .end,
                verticalPosition: .end,
                sizingOption: [],
                child: insetSpec
            )
            let collectionSpec = ASOverlayLayoutSpec(child: self.collectionNode, overlay: relativeSpec)

            let spinnerSpec = ASStackLayoutSpec.vertical()
            spinnerSpec.children = [self.spinnerNode]
            spinnerSpec.alignItems = .center
            spinnerSpec.justifyContent = .center

            let spinnerInsetSpect = ASInsetLayoutSpec(
                insets: .init(top: 70, left: 0, bottom: 0, right: 0),
                child: spinnerSpec
            )

            return ASOverlayLayoutSpec(child: collectionSpec, overlay: spinnerInsetSpect)
        }
    }

}

    // used to provide data to an IGListAdapter
extension NewsViewController: ListAdapterDataSource {
    
    // ask data sourse for objects to display in list
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return [viewModel]
    }

    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        let section = NewsDetailSectionController(
            viewModel: viewModel,
            didTapClose: { [weak self] in
                self?.step.accept(AppStep.newsDone)
            },
            didTapImage: { [weak self] (tappedImageURL, imageURLs) in
                self?.open(image: tappedImageURL, allImages: imageURLs)
            }
        )
        section.onUnathorizedError = { [weak self] in
            guard let `self` = self else { return }
            DispatchQueue.main.async {
                User.current.logout()
                if let onUnathorizedError = self.onUnathorizedError {
                    onUnathorizedError()
                }
            }
        }
        return section
    }

    // if we have nothing to show
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
}

extension NewsViewController : UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool{
        
        return true
    }
    
    private func setupGestureForDismiss() {
        hero.isEnabled = true
        panGR = UIPanGestureRecognizer(target: self, action: #selector(panAct))
        view.addGestureRecognizer(panGR)
        panGR.delegate = self
    }
    
    @objc func panAct(recognizer : UIPanGestureRecognizer) {
        
        //1. Monitor the translation of view
        let translation = recognizer.translation(in: nil)
        let progressX = (translation.x / 2 ) / view.bounds.width
        let progressY = (translation.y / 2 ) / view.bounds.height
        
        //1. Monitor the direction of view
        if recognizer.direction == .right {
            
            if (translation.x > 0) {
                if dismissBool {
                    dismissBool = false
                    hero.dismissViewController()
                    self.hero.modalAnimationType = .uncover(direction: .right)
                    recognizer.setTranslation(.zero, in: view)
                }
            }
            
        }
        //3. Gesture states
        switch recognizer.state {
        //3.1 Gesture states began to check the pan direction the user initiated
        case .began:
            
            print("began")
            
        //3.2 Gesture state changed to Translate the view according to the user pan gesture
        case .changed:
            
            if progressBool {
                
                let currentPos = CGPoint(x: view.center.x , y: translation.y + view.center.y)
                Hero.shared.update(progressY)
                Hero.shared.apply(modifiers: [.position(currentPos)], to: view)
                
            } else {
                
                if translation.x > 0 {
                    let currentPos = CGPoint(x: translation.x + view.center.x , y: view.center.y)
                    Hero.shared.update(progressX)
                    Hero.shared.apply(modifiers: [.position(currentPos)], to: view)
                }
                
            }
            
            
        //3.3 Gesture state end to finish the animation
        default:
            dismissBool = true
            progressBool = false
            if fabs(progressY + recognizer.velocity(in: nil).y / view.bounds.height ) > 0.5 {
                Hero.shared.finish()
            } else if progressX + recognizer.velocity(in: nil).x / view.bounds.width > 0.5 {
                Hero.shared.finish()
            } else {
                Hero.shared.cancel()
                self.hero.modalAnimationType = .uncover(direction: .right)
            }
        }
    }
}












