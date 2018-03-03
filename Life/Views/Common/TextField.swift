//
//  TextField.swift
//  Life
//
//  Created by Shyngys Kassymov on 11.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import Material
import SnapKit

class TextField: ErrorTextField {

    private(set) lazy var pickerView = UIPickerView()

    private(set) var items = [String]()

    var didTapSelect: ((Int) -> Void)?
    var didTapAdd: ((String) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: .zero)

        dividerColor = App.Color.coolGrey
        dividerActiveColor = App.Color.azure

        placeholderNormalColor = App.Color.blackDisable
        placeholderActiveColor = App.Color.azure

        detailLabel.textAlignment = .right

        font = App.Font.subheadAlts
        placeholderLabel.font = App.Font.subhead

        placeholderVerticalOffset = 16
        detailVerticalOffset = 2

        textColor = .black
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Actions

    @objc
    private func handleFieldTypeToggle() {
        text = nil
        if inputView != nil {
            setAsNormal()
        } else {
            setAsPicker(with: items)
        }
        addOrUpdateToggleToolbar()
        reloadInputViews()
    }

    @objc
    private func createTag() {
        if let didTapAdd = didTapAdd,
            text != nil && !text!.isEmpty {
            didTapAdd(text!)
        }

        text = nil
    }

    @objc
    private func selectTag() {
        if let didTapSelect = didTapSelect {
            didTapSelect(pickerView.selectedRow(inComponent: 0))
        }
    }

    @objc
    private func done() {
        text = nil
        resignFirstResponder()
    }

    // MARK: - Methods

    public func makeLight() {
        dividerColor = App.Color.coolGrey
        dividerActiveColor = UIColor.white.withAlphaComponent(0.7)

        placeholderNormalColor = UIColor.white.withAlphaComponent(0.4)
        placeholderActiveColor = UIColor.white.withAlphaComponent(0.7)

        textColor = .white
    }

    public func addOrUpdateToggleToolbar() {
        let toolbar = UIToolbar(frame: .init(
            x: 0,
            y: 0,
            width: UIScreen.main.bounds.size.width,
            height: 44)
        )
        toolbar.barStyle = .default
        toolbar.tintColor = .black

        var items = [UIBarButtonItem]()

        let flexibleItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        if inputView != nil {
            let toggleItem = UIBarButtonItem(
                title: NSLocalizedString("new_tag", comment: ""),
                style: .plain,
                target: self,
                action: #selector(handleFieldTypeToggle))
            items.append(toggleItem)

            items.append(flexibleItem)

            let doneItem = UIBarButtonItem(
                title: NSLocalizedString("select_tag", comment: ""),
                style: .plain,
                target: self,
                action: #selector(selectTag))
            items.append(doneItem)
        } else {
            let toggleItem = UIBarButtonItem(
                title: NSLocalizedString("tag_list", comment: ""),
                style: .plain,
                target: self,
                action: #selector(handleFieldTypeToggle))
            items.append(toggleItem)

            items.append(flexibleItem)

            let doneItem = UIBarButtonItem(
                title: NSLocalizedString("create_tag", comment: ""),
                style: .plain,
                target: self,
                action: #selector(createTag))
            items.append(doneItem)
        }

        let doneItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(done))
        items.append(doneItem)

        toolbar.items = items
        inputAccessoryView = toolbar
    }

    public func setAsPicker(with items: [String], setText: Bool = true) {
        self.items = items

        pickerView.backgroundColor = .white
        pickerView.dataSource = self
        pickerView.delegate = self
        inputView = pickerView

        if setText {
            let selectedIdx = pickerView.selectedRow(inComponent: 0)
            if items.count > selectedIdx {
                text = items[selectedIdx]
            } else {
                text = items.first
            }
        }
    }

    public func setAsNormal() {
        inputView = nil
    }

}

extension TextField: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return items.count
    }
}

extension TextField: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return items[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        text = items[row]
    }
}
