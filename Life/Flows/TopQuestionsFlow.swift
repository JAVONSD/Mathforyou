//
//  TopQuestionsFlow.swift
//  Life
//
//  Created by Shyngys Kassymov on 05.03.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit

class TopQuestionsFlow: Flow {

    var root: Presentable {
        return self.rootViewController
    }

    private var rootViewController: TopQuestionsViewController

    private unowned var topQuestionsViewModel: TopQuestionsViewModel

    init(viewController: TopQuestionsViewController, topQuestionsViewModel: TopQuestionsViewModel) {
        rootViewController = viewController
        self.topQuestionsViewModel = topQuestionsViewModel
    }

    func navigate(to step: Step) -> NextFlowItems {
        guard let step = step as? AppStep else { return NextFlowItems.stepNotHandled }

        switch step {
        case .createQuestion(let didAddQuestion):
            return navigationToQuestionForm(didAddQuestion: didAddQuestion)
        case .createQuestionDone:
            return navigationFromQuestionForm()
        case .topQuestionPicked:
            return NextFlowItems.none
        case .createAnswer(let questions, let isVideo, let didCreateAnswer):
            return navigationToAnswerForm(
                questions: questions,
                isVideo: isVideo,
                didCreateAnswer: didCreateAnswer
            )
        case .createAnswerDone:
            return navigationFromAnswerForm()
        default:
            return NextFlowItems.stepNotHandled
        }
    }

    private func navigationToTopQuestions() -> NextFlowItems {
        return NextFlowItems.one(flowItem:
            NextFlowItem(
                nextPresentable: rootViewController,
                nextStepper: rootViewController)
        )
    }

    private func navigationToQuestionForm(didAddQuestion: @escaping ((Question) -> Void)) -> NextFlowItems {
        let vc = QuestionFormViewController()
        vc.didAddQuestion = didAddQuestion
        self.rootViewController.present(vc, animated: true, completion: nil)
        return NextFlowItems.one(flowItem: NextFlowItem(nextPresentable: vc, nextStepper: vc))
    }

    private func navigationFromQuestionForm() -> NextFlowItems {
        self.rootViewController.presentedViewController?.dismiss(animated: true, completion: nil)
        return NextFlowItems.none
    }

    private func navigationToAnswerForm(
        questions: [Question],
        isVideo: Bool,
        didCreateAnswer: @escaping ((Answer, [String]) -> Void)) -> NextFlowItems {
        let viewModel = AnswerFormViewModel(questions: questions, isVideo: isVideo)
        let vc = AnswerFormViewController(viewModel: viewModel)
        vc.didCreateAnswer = didCreateAnswer
        self.rootViewController.present(vc, animated: true, completion: nil)
        return NextFlowItems.one(flowItem: NextFlowItem(nextPresentable: vc, nextStepper: vc))
    }

    private func navigationFromAnswerForm() -> NextFlowItems {
        self.rootViewController.presentedViewController?.dismiss(animated: true, completion: nil)
        return NextFlowItems.none
    }

}
