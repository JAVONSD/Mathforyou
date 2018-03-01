//
//  EventsSectionController.swift
//  Life
//
//  Created by Shyngys Kassymov on 20.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import IGListKit
import Moya

class EventsSectionController: ASCollectionSectionController {
    private(set) weak var viewModel: EventsViewModel?

    var onUnathorizedError: (() -> Void)?

    init(viewModel: EventsViewModel) {
        self.viewModel = viewModel

        super.init()

        supplementaryViewSource = self
    }

    override func didUpdate(to object: Any) {
        viewModel = object as? EventsViewModel

        // do nothing because API not ready
//        guard let viewModel = self.viewModel else { return }
//        set(items: [viewModel], animated: false, completion: nil)
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

extension EventsSectionController: ASSectionController {
    func nodeBlockForItem(at index: Int) -> ASCellNodeBlock {
        guard index < items.count,
            let viewModel = items[index] as? EventsViewModel else {
                return {
                    return ASCellNode()
                }
        }

        return {
            let slides = viewModel.events.map {
                //swiftlint:disable line_length
                return SliderViewModel(
                    title: $0.event.title,
                    label: NSLocalizedString("calend", comment: "").uppercased(),
                    image: "https://images.pexels.com/photos/313691/pexels-photo-313691.jpeg?w=1260&h=750&auto=compress&cs=tinysrgb"
                )
                //swiftlint:enable line_length
            }

            let defaultLayout = UICollectionViewFlowLayout()
            defaultLayout.scrollDirection = .horizontal
            defaultLayout.minimumInteritemSpacing = 0
            defaultLayout.minimumLineSpacing = App.Layout.itemSpacingMedium
            defaultLayout.sectionInset = .init(
                top: 0,
                left: App.Layout.itemSpacingSmall,
                bottom: 0,
                right: App.Layout.itemSpacingSmall)

            return BoardSliderCell(
                slides: slides,
                height: 180,
                layout: defaultLayout,
                slidesCornerRadius: App.Layout.cornerRadiusSmall
            )
        }
    }

    func beginBatchFetch(with context: ASBatchContext) {
        context.completeBatchFetching(true)
    }

    func shouldBatchFetch() -> Bool {
        return false
    }
}

extension EventsSectionController: RefreshingSectionControllerType {
    func refreshContent(with completion: (() -> Void)?) {
        if let completion = completion {
            completion()
        }
    }
}

extension EventsSectionController: ASSupplementaryNodeSource {
    func nodeBlockForSupplementaryElement(ofKind elementKind: String, at index: Int) -> ASCellNodeBlock {
        return {
            return TodayHeader(date: Date())
        }
    }

    func sizeRangeForSupplementaryElement(ofKind elementKind: String, at index: Int) -> ASSizeRange {
        if elementKind == UICollectionElementKindSectionHeader {
            return ASSizeRangeUnconstrained
        } else {
            return ASSizeRangeZero
        }
    }
}

extension EventsSectionController: ListSupplementaryViewSource {
    func supportedElementKinds() -> [String] {
        return [UICollectionElementKindSectionHeader]
    }

    func viewForSupplementaryElement(ofKind elementKind: String, at index: Int) -> UICollectionReusableView {
        return ASIGListSupplementaryViewSourceMethods
            .viewForSupplementaryElement(
                ofKind: elementKind,
                at: index,
                sectionController: self)
    }

    func sizeForSupplementaryView(ofKind elementKind: String, at index: Int) -> CGSize {
        return ASIGListSupplementaryViewSourceMethods.sizeForSupplementaryView(ofKind: elementKind, at: index)
    }

}
