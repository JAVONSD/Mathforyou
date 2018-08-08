//
//  UserPickExecutorCell.swift
//  Life
//
//  Created by 123 on 06.08.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import Kingfisher
import SnapKit
import RealmSwift
import RxSwift
import RxCocoa
import Moya
import Moya_ModelMapper
import RxOptional
import Mapper

protocol UserPickExecutorCellDelegate: class {
    func showTableView(sender: UserPickExecutorCell, hrList: [HRPerson])
}

class UserPickExecutorCell: UITableViewCell {
    
    weak var delegate: UserPickExecutorCellDelegate?
    
    lazy var executorTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = NSLocalizedString("Выберите исполнителя", comment: "")
        tf.borderColor = App.Color.black
        tf.borderStyle = .roundedRect
        tf.delegate = self
        return tf
    }()

    static var identifier: String {
        return String(describing: self)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    var latestHRName: Observable<String> {
        return executorTextField
            .rx.text
            .orEmpty
            .debounce(0.5, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
    }
    
    private let disposeBag = DisposeBag()
    private let provider = MoyaProvider<EmployeesService>(
        plugins: [
            AuthPlugin(tokenClosure: {
                return User.current.token
            })
        ]
    )
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupRx()
        setupViews()
    }
    
    func setupRx() {
        latestHRName.subscribe(onNext: { [weak self] (name) in
            
            self?.searchApi(name: name)
            
        }).disposed(by: disposeBag)
        
    }
    
    func searchApi(name: String) {
        provider
            .rx
            .request(EmployeesService.findEmployeeByRole(fltTxt: name))
            .mapOptional(to: [HRPerson].self)
            .subscribe { [weak self] event in
                switch event {
                case .success(let hrsList):
                    guard let weakSelf = self, let list = hrsList else { return }
                    
                    weakSelf.delegate?.showTableView(sender: weakSelf, hrList: list)
                    
                case .error(let error):
                    print(error)
                }
        }.disposed(by: disposeBag)

    }
    
    fileprivate func setupViews() {
        // add executorTextField into self
        addSubview(executorTextField)
        executorTextField.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsetsMake(20, 20, 20, 20))
        }

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension UserPickExecutorCell: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }
    
}






















