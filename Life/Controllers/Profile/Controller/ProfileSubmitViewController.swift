//
//  ProfileSubmitViewController.swift
//  Life
//
//  Created by 123 on 05.08.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit

class ProfileSubmitViewController: UIViewController {
    
    lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.dataSource = self
        tv.delegate = self
        return tv
    }()

    let addedImageView: UIImageView = {
        let iv = UIImageView()
        iv.isHidden = true
        return iv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupViews()
    }
    
    private func setupViews() {
        setupTableView()
        setupCloseButton()
    }
    
    fileprivate func setupTableView() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        tableView.register(UserSubmitDescriptionCell.self, forCellReuseIdentifier: UserSubmitDescriptionCell.identifier)
        tableView.register(UserSubmitImageCell.self, forCellReuseIdentifier: UserSubmitImageCell.identifier)
        
        tableView.separatorStyle = .none
        tableView.allowsSelection = true
    }
    
    fileprivate func setupCloseButton() {
        let closeBtn = UIBarButtonItem(image: #imageLiteral(resourceName: "close-circle-dark").withRenderingMode(.alwaysOriginal), style: .done, target: self, action: #selector(closeAction))
        navigationItem.rightBarButtonItem = closeBtn
    }
    
    @objc
    fileprivate func closeAction() {
        sendCloseAction()
    }
    
    private func sendCloseAction() {
        dismiss(animated: true, completion: nil)
    }
    
    deinit {
        print("*** deinit \(self)")
    }
  
}

//MARK: - UITableView DataSource
extension ProfileSubmitViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            let cell = tableView.dequeueReusableCell(withIdentifier: UserSubmitDescriptionCell.identifier, for: indexPath) as! UserSubmitDescriptionCell
     
            
            return cell
        case (1, 0):
            let cell = tableView.dequeueReusableCell(withIdentifier: UserSubmitImageCell.identifier, for: indexPath) as! UserSubmitImageCell
            
            cell.addPhotoLabel.text = "Выбрать фото"
            
            return cell
        default:
            return UITableViewCell()
        }
    }
  
}

//MARK: - UITableView Delegate
extension ProfileSubmitViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.section == 0 || indexPath.section == 1 {
            // only two sections are tappable
            return indexPath
            
        } else {
            // tap не срабатывает
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            // if we tap not exactly on text view
      
            let cell = tableView.cellForRow(at: indexPath) as! UserSubmitDescriptionCell
            cell.descriptionTextView.becomeFirstResponder()
            
        } else if indexPath.section == 1 && indexPath.row == 0 {
            tableView.deselectRow(at: indexPath, animated: true)
            pickPhoto()
        }
      
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch (section) {
        case (0):
            return 50
        default:
            return 50
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            return 88
        case (1, 0):
            return addedImageView.isHidden ? 44 : 280
        default:
            return 44
        }
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch (section) {
        case (0):
            return "Описание"
        default:
            return "Изображение"
        }
    }
}

//MARK: - Navigation
extension ProfileSubmitViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
}

//MARK: - UIImagePickerController Delegate
extension ProfileSubmitViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
    }
    
    fileprivate func takePhotoWithCamera() {
        
    }
    
    fileprivate func choosePhotoFromLibrary() {
        
    }
    
    fileprivate func pickPhoto() {
        
    }
    
    fileprivate func showPhotoMenu() {
        
    }
}




















