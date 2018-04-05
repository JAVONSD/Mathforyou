//
//  QuestionnaireStatisticsView.swift
//  
//
//  Created by Shyngys Kassymov on 04.04.2018.
//

import UIKit
import Material
import SnapKit

class QuestionnaireStatisticsView: UIView {

    private(set) lazy var headerView = NotificationHeaderView(image: nil, title: "", subtitle: nil)
    private(set) lazy var contentView = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Methods

    public func build(with statistics: QuestionnaireStatistics) {
        headerView.titleLabel?.text = "Статистика: \(statistics.name)"

        for subview in contentView.subviews {
            subview.removeFromSuperview()
        }

        var previousView: UIView?
        for idx in 0..<statistics.questions.count {
            let item = statistics.questions[idx]

            let view = QuestionnaireStatisticsItemView(questionnaireQuestionStatistics: item)
            contentView.addSubview(view)

            if idx == 0 {
                view.snp.makeConstraints { (make) in
                    make.top.equalTo(self.contentView)
                    make.left.equalTo(self.contentView)
                    make.right.equalTo(self.contentView)
                }
            } else if idx < statistics.questions.count - 1 {
                view.snp.makeConstraints { (make) in
                    make.top.equalTo(previousView!.snp.bottom).offset(App.Layout.sideOffset)
                    make.left.equalTo(self.contentView)
                    make.right.equalTo(self.contentView)
                }
            } else {
                view.snp.makeConstraints { (make) in
                    make.top.equalTo(previousView!.snp.bottom).offset(App.Layout.sideOffset)
                    make.left.equalTo(self.contentView)
                    make.bottom.equalTo(self.contentView)
                    make.right.equalTo(self.contentView)
                }
            }

            previousView = view
        }
    }

    // MARK: - UI

    private func setupUI() {
        setupHeaderView()
        setupContentView()
    }

    private func setupHeaderView() {
        headerView.textStackView?.insets = .init(
            top: App.Layout.itemSpacingMedium,
            left: 0,
            bottom: App.Layout.itemSpacingMedium,
            right: 0)
        addSubview(headerView)
        headerView.snp.makeConstraints { (make) in
            make.top.equalTo(self)
            make.left.equalTo(self)
            make.right.equalTo(self)
        }
    }

    private func setupContentView() {
        addSubview(contentView)
        contentView.snp.makeConstraints { (make) in
            make.top.equalTo(self.headerView.snp.bottom).offset(App.Layout.sideOffset)
            make.left.equalTo(self).inset(App.Layout.sideOffset)
            make.bottom.equalTo(self).inset(App.Layout.sideOffset)
            make.right.equalTo(self).inset(App.Layout.sideOffset)
        }
    }

}
