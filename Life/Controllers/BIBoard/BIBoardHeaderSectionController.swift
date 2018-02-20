//
//  BIBoardHeaderSectionController.swift
//  Life
//
//  Created by Shyngys Kassymov on 19.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import IGListKit
import Moya

class BIBoardHeaderSectionController: ASCollectionSectionController {
    private(set) weak var viewModel: NewsViewModel?

    var onUnathorizedError: (() -> Void)?

    init(viewModel: NewsViewModel) {
        self.viewModel = viewModel

        super.init()
    }

    override func didUpdate(to object: Any) {
        viewModel = object as? NewsViewModel

        guard let viewModel = self.viewModel else { return }

        set(items: [viewModel], animated: false, completion: nil)
    }

    override func cellForItem(at index: Int) -> UICollectionViewCell {
        return ASIGListSectionControllerMethods.cellForItem(at: index, sectionController: self)
    }

    override func sizeForItem(at index: Int) -> CGSize {
        return ASIGListSectionControllerMethods.sizeForItem(at: index)
    }

    override func didSelectItem(at index: Int) {
        print("Selected item at index - \(index)")
    }
}

extension BIBoardHeaderSectionController: ASSectionController {
    func nodeBlockForItem(at index: Int) -> ASCellNodeBlock {
        guard index < items.count,
            let viewModel = items[index] as? NewsViewModel else {
                return {
                    return ASCellNode()
                }
        }

        return {
            let slides = viewModel.news.map {
                return SliderViewModel(
                    title: $0.news.title,
                    label: NSLocalizedString("news", comment: "").uppercased(),
                    image: "https://images.pexels.com/photos/60006/spring-tree-flowers-meadow-60006.jpeg?w=1260&h=750&auto=compress&cs=tinysrgb"
                )
            }
            return BoardSliderCell(slides: slides, height: 200)
        }
    }

    func beginBatchFetch(with context: ASBatchContext) {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self,
                let viewModel = self.viewModel else { return }
            self.set(items: [viewModel], animated: false, completion: {
                context.completeBatchFetching(true)
            })
        }
    }

    func shouldBatchFetch() -> Bool {
        return false
    }

}

extension BIBoardHeaderSectionController: RefreshingSectionControllerType {
    func refreshContent(with completion: (() -> Void)?) {
        if let completion = completion {
            completion()
        }
    }
}
