//
//  AuthorsSectionController.swift
//  Life
//
//  Created by Shyngys Kassymov on 22.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import IGListKit
import Moya
import RxSwift

class AuthorsSectionController: ASCollectionSectionController {
    private(set) weak var viewModel: TopQuestionsViewModel?

    var sectionTimestamp = DateCell()

    let disposeBag = DisposeBag()

    var onUnathorizedError: (() -> Void)?

    init(viewModel: TopQuestionsViewModel) {
        self.viewModel = viewModel

        super.init()

        viewModel.answers.answersSubject.subscribe(onNext: { [weak self] _ in
            self?.updateContents()
        }).disposed(by: disposeBag)
        viewModel.answers.videoAnswersSubject.subscribe(onNext: { [weak self] _ in
            self?.updateContents()
        }).disposed(by: disposeBag)
    }

    override func didUpdate(to object: Any) {
        viewModel = object as? TopQuestionsViewModel
        updateContents()
    }

    private func updateContents() {
        let items = [sectionTimestamp]
        set(items: items, animated: false, completion: nil)
    }

    override func cellForItem(at index: Int) -> UICollectionViewCell {
        return ASIGListSectionControllerMethods.cellForItem(at: index, sectionController: self)
    }

    override func sizeForItem(at index: Int) -> CGSize {
        return ASIGListSectionControllerMethods.sizeForItem(at: index)
    }

    override func didSelectItem(at index: Int) {
    }
}

extension AuthorsSectionController: ASSectionController {
    func nodeBlockForItem(at index: Int) -> ASCellNodeBlock {
        guard  let viewModel = self.viewModel else {
            return {
                return ASCellNode()
            }
        }

        return {
            return TopAuthorsCell(viewModel: viewModel)
        }
    }

    func beginBatchFetch(with context: ASBatchContext) {
        context.completeBatchFetching(true)
    }

    func shouldBatchFetch() -> Bool {
        return false
    }
}

extension AuthorsSectionController: RefreshingSectionControllerType {
    func refreshContent(with completion: (() -> Void)?) {
        sectionTimestamp.update()
        updateContents()
    }
}
