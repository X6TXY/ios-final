//
//  ClearTabBarController.swift
//  MovieApp
//
//  Created by Uldana Shyndali on 14.12.2025.
//

import UIKit

class ClearTabBarController: UITabBarController {

        override func viewDidLoad() {
            super.viewDidLoad()
            setupTabBar()
        }

        private func setupTabBar() {
            // Make tab bar transparent
            tabBar.backgroundImage = UIImage()
            tabBar.shadowImage = UIImage()
            tabBar.isTranslucent = true
            tabBar.backgroundColor = .clear

            
            tabBar.tintColor = .red

     
            tabBar.unselectedItemTintColor = .lightGray
        }
    }

