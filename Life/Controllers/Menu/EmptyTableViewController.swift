//
//  EmptyTableViewController.swift
//  Life
//
//  Created by Shyngys Kassymov on 07.04.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

class EmptyTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.titleLabel.text = title
        navigationItem.titleLabel.font = App.Font.headline
        navigationItem.titleLabel.textAlignment = .left
        navigationItem.titleLabel.textColor = UIColor.black

        tableView.backgroundView = nil
        tableView.backgroundColor = App.Color.whiteSmoke
        tableView.separatorColor = .clear
        tableView.separatorStyle = .none
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        tableView.register(
            UITableViewCell.self,
            forCellReuseIdentifier: App.CellIdentifier.dummyCellId
        )
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: App.CellIdentifier.dummyCellId,
            for: indexPath
        )
        return cell
    }

}

extension EmptyTableViewController: DZNEmptyDataSetSource {
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return #imageLiteral(resourceName: "ic_config")
    }

    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let text = NSLocalizedString("section_still_in_dev_text", comment: "")
        let attText = NSMutableAttributedString(string: text)

        let allRange = NSRange(location: 0, length: attText.length)
        attText.addAttribute(.font, value: App.Font.subhead, range: allRange)
        attText.addAttribute(.foregroundColor, value: App.Color.black, range: allRange)

        return attText
    }
}

extension EmptyTableViewController: DZNEmptyDataSetDelegate {
    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView!) -> Bool {
        return true
    }
}
