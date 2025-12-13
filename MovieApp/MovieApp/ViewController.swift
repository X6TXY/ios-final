//
//  ViewController.swift
//  MovieApp
//
//  Created by Baha Toleu on 10.12.2025.
//

import UIKit

final class ViewController: UIViewController {
    
    private var glassTabBarView: UIVisualEffectView?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
        
    }
    
    private func setupTabBar() {
        guard let tabBar = tabBarController?.tabBar else { return }

        tabBar.backgroundImage = UIImage()
        tabBar.shadowImage = UIImage()
        tabBar.isTranslucent = true
        tabBar.backgroundColor = .clear

        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        let glassView = UIVisualEffectView(effect: blurEffect)

        glassView.frame = tabBar.bounds.insetBy(dx: 16, dy: 8)
        glassView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        glassView.layer.cornerRadius = 24
        glassView.layer.masksToBounds = true

        tabBar.insertSubview(glassView, at: 0)
        glassTabBarView = glassView
    }

}


