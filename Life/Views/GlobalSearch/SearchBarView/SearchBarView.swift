//
//  SearchBarView.swift
//  SearchBar
//
//  Created by huangmian on 2018/7/26.
//  Copyright © 2018年 hm. All rights reserved.
//

import UIKit

protocol SearchBarViewDelegate: class {
    func SearchBarViewEditingChanged(textField: UITextField)
    func SearchBarViewSearchAction(textField: UITextField)
    func SearchBarViewDidBeginEditing(textField: UITextField)
    func SearchBarViewcancelAction()
}

class SearchBarView: UIView {
    weak var delegate: SearchBarViewDelegate?
    
    private lazy var searchTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = UIColor.init(hexString: "#ebeef1")
        textField.textColor = UIColor.init(hexString: "#494949")
        textField.font = UIFont.systemFont(ofSize: 15)
        textField.placeholder = "搜索歌曲、歌手、专辑"
        textField.attributedPlaceholder = NSAttributedString(string: textField.placeholder ?? "", attributes: [NSAttributedStringKey.foregroundColor : UIColor.init(hexString: "#bfbfbf")])
        textField.layer.cornerRadius = 15
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 15))
        textField.leftViewMode = .always
        textField.clearsOnBeginEditing = true
        textField.clearButtonMode = .always
        textField.returnKeyType = .search
        textField.addTarget(self, action: #selector(editingChanged), for: UIControlEvents.editingChanged)
        textField.delegate = self
        textField.tintColor = UIColor(hexString: "#63C6F9", alpha: 1)
        return textField
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton.init(type: UIButtonType.system)
        button.setTitle("取消", for: UIControlState.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17.0)
        button.setTitleColor(UIColor.init(hexString: "#494949"), for: UIControlState.normal)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        isUserInteractionEnabled = true
        self.addSubview(searchTextField)
        self.addSubview(cancelButton)
        cancelButton.addTarget(self, action: #selector(cancelAction), for: UIControlEvents.touchUpInside)
        
    }
    
    @objc func cancelAction() {
        print("cancelAction")
        delegate?.SearchBarViewcancelAction()
        
    }
    
    deinit {
        print("SearchBarView deinit")
    }
    
    func setSearchTextString(searchTextString: String) {
        searchTextField.text = searchTextString
    }
    
    func hideKeyboard(_ hide: Bool) {
        if hide {
            searchTextField.resignFirstResponder()
        }else{
            searchTextField.becomeFirstResponder()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        searchTextField.frame = CGRect(x: 0, y: 0, width: self.frame.size.width - 55, height: 30)
        cancelButton.frame = CGRect(x: searchTextField.frame.maxX + 20, y: 7, width: 37, height: 16)
    }
}

extension SearchBarView : UITextFieldDelegate {
    
    @objc func editingChanged() {
        delegate?.SearchBarViewEditingChanged(textField: searchTextField)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        delegate?.SearchBarViewSearchAction(textField: searchTextField)
        return false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        delegate?.SearchBarViewDidBeginEditing(textField: textField)
    }
}

extension UIColor {
    convenience init(hexString: String, alpha: CGFloat = 1.0) {
        var hexString = hexString
        if hexString.count < 6 {
            self.init(red: 0, green: 0, blue: 0, alpha: alpha)
            return
        }
        
        var startIndex = hexString.startIndex
        if hexString.hasPrefix("0x"){
            startIndex = hexString.index(startIndex, offsetBy: 2)
            hexString = String(hexString[startIndex..<hexString.endIndex])
        }else if hexString.hasPrefix("#"){
            startIndex = hexString.index(startIndex, offsetBy: 1)
            hexString = String(hexString[startIndex..<hexString.endIndex])
        }
        
        if hexString.count != 6 {
            self.init(red: 0, green: 0, blue: 0, alpha: alpha)
        }else{
            var r: UInt32 = 0
            var g: UInt32 = 0
            var b: UInt32 = 0
            let redIndex = hexString.startIndex
            let redString = hexString[redIndex..<hexString.index(redIndex, offsetBy: 2)]
            let greenIndex = hexString.index(redIndex, offsetBy: 2)
            let greenString = hexString[greenIndex..<hexString.index(greenIndex, offsetBy: 2)]
            let blueIndex = hexString.index(redIndex, offsetBy: 4)
            let blueString = hexString[blueIndex..<hexString.endIndex]
            Scanner.init(string: String(redString)).scanHexInt32(&r)
            Scanner.init(string: String(greenString)).scanHexInt32(&g)
            Scanner.init(string: String(blueString)).scanHexInt32(&b)
            self.init(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: alpha)
        }
    }
}
