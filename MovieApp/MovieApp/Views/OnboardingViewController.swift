//
//  OnboardingViewController.swift
//  MovieApp
//
//  Created by Uldana Shyndali on 14.12.2025.
//

import UIKit

class OnboardingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func getStartedButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let detailsVC = storyboard.instantiateViewController(
            withIdentifier: "AuthController"
        ) as! AuthViewController

        self.navigationController?.pushViewController(detailsVC, animated: true)
    }
    
}
