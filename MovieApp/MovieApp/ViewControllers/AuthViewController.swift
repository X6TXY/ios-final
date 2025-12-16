//
//  AuthViewController.swift
//  MovieApp
//
//  Created by Baha Toleu on 10.12.2025.
//

import UIKit

final class AuthViewController: UIViewController {

    @IBOutlet weak var actionTitle: UILabel!
    @IBOutlet weak var authSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var usernameFieldView: AuthFieldView!
    @IBOutlet weak var emailFieldView: AuthFieldView!
    @IBOutlet weak var passwordFieldView: AuthFieldView!
    @IBOutlet weak var passwordConfirmFieldView: AuthFieldView!
    
    @IBOutlet weak var authButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSegmentedControl()
        updateUIForSelectedSegment()
        
        usernameFieldView.fieldType = .username
        emailFieldView.fieldType = .email
        passwordFieldView.fieldType = .password
        passwordConfirmFieldView.fieldType = .confirmPassword
        
        [usernameFieldView, emailFieldView, passwordFieldView, passwordConfirmFieldView].forEach { field in
            field.textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        }
        
        updateAuthButtonState()
    }
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        updateUIForSelectedSegment()
        updateAuthButtonState()
    }
    
    private func setupSegmentedControl() {
        let normalAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.systemGray]
        let selectedAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.white]
        authSegmentedControl.setTitleTextAttributes(normalAttributes, for: .normal)
        authSegmentedControl.setTitleTextAttributes(selectedAttributes, for: .selected)
    }
    
    private func updateUIForSelectedSegment() {
        let isSignIn = authSegmentedControl.selectedSegmentIndex == 0
        
        actionTitle.text = isSignIn ? "Welcome Back" : "Join Us"
        
        usernameFieldView.isHidden = isSignIn
        passwordConfirmFieldView.isHidden = isSignIn
        
        authButton.setTitle(isSignIn ? "Sign In" : "Sign Up", for: .normal)
    }
    
    @objc private func textFieldDidChange() {
        updateAuthButtonState()
    }
    
    private func updateAuthButtonState() {
        let isSignIn = authSegmentedControl.selectedSegmentIndex == 0
        
        let emailFilled = !(emailFieldView.text?.isEmpty ?? true)
        let passwordFilled = !(passwordFieldView.text?.isEmpty ?? true)
        
        if isSignIn {
            authButton.isEnabled = emailFilled && passwordFilled
        } else {
            let usernameFilled = !(usernameFieldView.text?.isEmpty ?? true)
            let confirmPasswordFilled = !(passwordConfirmFieldView.text?.isEmpty ?? true)
            let passwordsMatch = passwordFieldView.text == passwordConfirmFieldView.text
            
            authButton.isEnabled = usernameFilled && emailFilled && passwordFilled && confirmPasswordFilled && passwordsMatch
        }
        
        let title = isSignIn ? "Sign In" : "Sign Up"
            authButton.setTitle(title, for: .normal)
            authButton.setTitle(title, for: .disabled)

        authButton.alpha = authButton.isEnabled ? 1 : 0.5
    }
    
    @IBAction func authAction(_ sender: UIButton) {
        let isSignIn = authSegmentedControl.selectedSegmentIndex == 0

        authButton.isEnabled = false

        if isSignIn {
            let request = SignInRequest(
                email: emailFieldView.text ?? "",
                password: passwordFieldView.text ?? ""
            )

            APIClient.shared.signIn(request) { [weak self] result in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    self.authButton.isEnabled = true
                    switch result {
                    case .success(let user):
                        UserDefaults.standard.set(true, forKey: "authorized")
                        UserDefaults.standard.set(user.id, forKey: "current_user_id")
                        UserDefaults.standard.set(user.email, forKey: "current_user_email")
                        UserDefaults.standard.set(user.username, forKey: "current_user_username")
                        self.authSucceeded()
                    case .failure(let error):
                        self.showError(error)
                    }
                }
            }
        } else {
            let request = SignUpRequest(
                email: emailFieldView.text ?? "",
                password: passwordFieldView.text ?? "",
                username: usernameFieldView.text ?? ""
            )

            APIClient.shared.signUp(request) { [weak self] result in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    self.authButton.isEnabled = true
                    switch result {
                    case .success(let user):
                        UserDefaults.standard.set(true, forKey: "authorized")
                        UserDefaults.standard.set(user.id, forKey: "current_user_id")
                        UserDefaults.standard.set(user.email, forKey: "current_user_email")
                        UserDefaults.standard.set(user.username, forKey: "current_user_username")
                        self.authSucceeded()
                    case .failure(let error):
                        self.showError(error)
                    }
                }
            }
        }
    }
    
    func authSucceeded() {
        guard let windowScene = view.window?.windowScene else { return }
            let window = UIWindow(windowScene: windowScene)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let mainTabBar = storyboard.instantiateViewController(withIdentifier: "ClearTabBarController")
            
            UIView.transition(with: window,
                              duration: 0.3,
                              options: .transitionCrossDissolve,
                              animations: {
                window.rootViewController = mainTabBar
            })
            
            self.view.window?.rootViewController = mainTabBar
    }

    private func showError(_ error: Error) {
        let alert = UIAlertController(
            title: "Error",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}


