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
        let isClear = UserDefaults.standard.object(forKey: "tabBarClear") == nil
            ? true  // Default: clear
            : UserDefaults.standard.bool(forKey: "tabBarClear")
        
        if isClear {
            tabBar.backgroundImage = UIImage()
            tabBar.shadowImage = UIImage()
            tabBar.isTranslucent = true
            tabBar.backgroundColor = .clear
        } else {
            tabBar.backgroundImage = nil
            tabBar.shadowImage = nil
            tabBar.isTranslucent = false
            tabBar.backgroundColor = .white
        }

        tabBar.tintColor = .red
        tabBar.unselectedItemTintColor = .lightGray
    }
}
