//
//  MainTabBarController.swift
//  ios
//
//  Main Tab Bar Controller
//

import UIKit

class MainTabBarController: UIViewController {
    
    private let customTabBar = CustomTabBar()
    private var viewControllers: [UIViewController] = []
    private var currentViewController: UIViewController?
    
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = DesignColors.backgroundPrimary
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupViewControllers()
    }
    
    private func setupUI() {
        view.backgroundColor = DesignColors.backgroundPrimary
        
        view.addSubview(containerView)
        view.addSubview(customTabBar)
        
        customTabBar.translatesAutoresizingMaskIntoConstraints = false
        customTabBar.delegate = self
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: view.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: customTabBar.topAnchor),
            
            customTabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customTabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customTabBar.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            customTabBar.heightAnchor.constraint(equalToConstant: 83)
        ])
    }
    
    private func setupViewControllers() {
        // Create view controllers
        let homeVC = HomeViewController()
        let homeNav = UINavigationController(rootViewController: homeVC)
        
        let searchVC = createPlaceholderVC(title: "Search", color: .systemBlue)
        let discoverVC = createPlaceholderVC(title: "Discover", color: .systemPurple)
        let friendsVC = createPlaceholderVC(title: "Friends", color: .systemGreen)
        let profileVC = createPlaceholderVC(title: "Profile", color: .systemOrange)
        
        viewControllers = [homeNav, searchVC, discoverVC, friendsVC, profileVC]
        
        let tabItems = [
            TabBarItem.home,
            TabBarItem.search,
            TabBarItem.discover,
            TabBarItem.friends,
            TabBarItem.profile
        ]
        
        customTabBar.configure(with: tabItems)
        selectViewController(at: 0)
    }
    
    private func createPlaceholderVC(title: String, color: UIColor) -> UIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = DesignColors.backgroundPrimary
        
        let label = UILabel()
        label.text = title
        label.font = DesignTypography.heading1
        label.textColor = DesignColors.textPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor)
        ])
        
        return vc
    }
    
    private func selectViewController(at index: Int) {
        guard index >= 0 && index < viewControllers.count else { return }
        
        let newVC = viewControllers[index]
        
        // Remove current view controller
        if let currentVC = currentViewController {
            currentVC.willMove(toParent: nil)
            currentVC.view.removeFromSuperview()
            currentVC.removeFromParent()
        }
        
        // Add new view controller
        addChild(newVC)
        newVC.view.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(newVC.view)
        
        NSLayoutConstraint.activate([
            newVC.view.topAnchor.constraint(equalTo: containerView.topAnchor),
            newVC.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            newVC.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            newVC.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        newVC.didMove(toParent: self)
        currentViewController = newVC
        customTabBar.setSelectedIndex(index)
    }
}

extension MainTabBarController: CustomTabBarDelegate {
    func tabBar(_ tabBar: CustomTabBar, didSelectItemAt index: Int) {
        selectViewController(at: index)
    }
    
    func setSelectedIndex(_ index: Int, animated: Bool) {
        customTabBar.setSelectedIndex(index, animated: animated)
        selectViewController(at: index)
    }
}

