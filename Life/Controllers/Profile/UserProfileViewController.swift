//
//  ProfileViewController2.swift
//  Life
//
//  Created by 123 on 31.07.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import Kingfisher
import Lightbox
import Material

class UserProfileViewController: UIViewController, Stepper {
    
    private(set) lazy var tabBar = TabBar(frame: .zero)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = App.Color.whiteSmoke
    }

}

   //MARK: - Assembly Child Controllers
extension UserProfileViewController {
    
    public static var configuredVC: UserProfileViewController {
        let myInfoVC = MyInfoViewController()
        
        let vcArray = [
            myInfoVC,
            ResultsViewController(),
            PlansViewController(),
            BenefitsViewController()
        ]
        
        let profileVC = UserProfileViewController()
        myInfoVC.didTapAvatar = { [weak profileVC] in
            
        }
        return profileVC
    }
   
}

    // MARK: - TabBarDelegate
extension UserProfileViewController: TabBarDelegate {
    
    func tabBar(tabBar: TabBar, didSelect tabItem: TabItem) {
        navigationController?.setNavigationBarHidden(tabItem.tag == 2, animated: false)
        
        
    }
}





