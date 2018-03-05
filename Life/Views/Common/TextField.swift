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

    private(set) lazy var datePicker = UIDatePicker()
    private(set) lazy var dateFormatter = DateFormatter()

    override init(frame: CGRect) {
        super.init(frame: .zero)

        delegate = self

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

        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Actions

    @objc
    private func handleDatePickerChange(_ datePicker: UIDatePicker) {
        text = dateFormatter.string(from: datePicker.date)
    }

    // MARK: - Methods

    public func makeLight() {
        dividerColor = App.Color.coolGrey
        dividerActiveColor = UIColor.white.withAlphaComponent(0.7)

        placeholderNormalColor = UIColor.white.withAlphaComponent(0.4)
        placeholderActiveColor = UIColor.white.withAlphaComponent(0.7)

        textColor = .white
    }

    public func setAsPicker(
        with items: [String],
        setText: Bool = true,
        selectedIdx: Int = 0) {
        self.items = items

        pickerView.backgroundColor = .white
        pickerView.dataSource = self
        pickerView.delegate = self
        inputView = pickerView

        if setText {
            if items.count > selectedIdx {
                text = items[selectedIdx]
            } else {
                text = items.first
            }
        }
    }

    public func setAsDatePicker(
        includeTime: Bool = true,
        initialDate: Date = Date(),
        setText: Bool = true) {
        datePicker.backgroundColor = .white
        datePicker.date = initialDate
        datePicker.datePickerMode = includeTime ? .dateAndTime : .date
        datePicker.addTarget(self, action: #selector(handleDatePickerChange(_:)), for: .valueChanged)
        inputView = datePicker

        if setText {
            let date = datePicker.date
            text = dateFormatter.string(from: date)
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
    func pickerView(_ pickerView: UIPickerView,
                    titleForRow row: Int, forComponent component: Int) -> String? {
        return items[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        text = items[row]
    }
}

extension TextField: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let textFieldText = textField.text, !textFieldText.isEmpty {
            tintColor = placeholderActiveColor
            placeholderLabel.textColor = placeholderActiveColor
        } else {
            tintColor = placeholderNormalColor
            placeholderLabel.textColor = placeholderNormalColor
        }
    }
}
