//
//  QuestionnaireView.swift
//  Life
//
//  Created by Shyngys Kassymov on 04.04.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import Kingfisher
import Material
import NVActivityIndicatorView
import SnapKit

class QuestionnaireView: UIView {

    private(set) lazy var scrollView = UIScrollView()
    private(set) lazy var contentView = UIView()

    private(set) lazy var headerView = QuestionnaireHeaderView()
    private(set) lazy var pollView = QuestionnairePollView()
    private(set) lazy var statisticsView = QuestionnaireStatisticsView()

    private(set) lazy var spinner = NVActivityIndicatorView(
        frame: .init(x: 0, y: 0, width: 44, height: 44),
        type: .circleStrokeSpin,
        color: App.Color.azure,
        padding: 0)

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Methods

    public func setPollViewVisible(with questionnaire: Questionnaire) {
        statisticsView.removeFromSuperview()

        var images = questionnaire.secondaryImages.map { $0.streamId }
        if !questionnaire.imageStreamId.isEmpty {
            images.insert(questionnaire.imageStreamId, at: 0)
        }
        headerView.images = images
        headerView.authorLabel.text = questionnaire.authorName
        headerView.publishDateLabel.text = questionnaire.createDate.prettyDateString()
        headerView.authorImageView.set(
            image: "",
            employeeCode: questionnaire.authorCode,
            placeholderImage: #imageLiteral(resourceName: "ic-user"),
            size: CGSize(width: 40, height: 40)
        )
        contentView.addSubview(headerView)
        headerView.snp.makeConstraints { (make) in
            make.top.equalTo(self.contentView)
            make.left.equalTo(self.contentView)
            make.right.equalTo(self.contentView)
        }

        pollView.build(with: questionnaire)
        contentView.addSubview(pollView)
        pollView.snp.makeConstraints { (make) in
            make.top.equalTo(self.headerView.snp.bottom)
            make.left.equalTo(self.contentView)
            make.bottom.equalTo(self.contentView)
            make.right.equalTo(self.contentView)
        }
    }

    public func setStatisticsViewVisible(with statistics: QuestionnaireStatistics) {
        headerView.removeFromSuperview()
        pollView.removeFromSuperview()

        statisticsView.build(with: statistics)
        contentView.addSubview(statisticsView)
        statisticsView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.contentView)
        }
    }

    public func set(isLoading: Bool) {
        for view in subviews {
            view.isHidden = isLoading
        }

        spinner.isHidden = !isLoading
        isLoading ? spinner.startAnimating() : spinner.stopAnimating()
    }

    // MARK: - UI

    private func setupUI() {
        backgroundColor = .white

        setupScrollView()
        setupContentView()
        setupSpinner()
    }

    private func setupScrollView() {
        addSubview(scrollView)
        scrollView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
    }

    private func setupContentView() {
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.scrollView)
            make.width.equalTo(self.scrollView)
        }
    }

    private func setupSpinner() {
        spinner.isHidden = true
        addSubview(spinner)
        spinner.snp.makeConstraints { (make) in
            make.center.equalTo(self)
        }
    }

}
