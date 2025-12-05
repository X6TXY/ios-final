//
//  LoginViewController.swift
//  ios
//
//  Streamlined Login Screen with Biometric Auth
//

import UIKit

class LoginViewController: UIViewController {
    
    // MARK: - UI Components
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.keyboardDismissMode = .onDrag
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let headerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Welcome Back"
        label.font = DesignTypography.heading2
        label.textColor = DesignColors.textPrimary
        label.textAlignment = .center
        return label
    }()
    
    private let biometricButton: BiometricAuthButton = {
        let button = BiometricAuthButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let formCard: FormCardView = {
        let card = FormCardView()
        card.translatesAutoresizingMaskIntoConstraints = false
        return card
    }()
    
    private let emailTextField: IconTextField = {
        let textField = IconTextField(icon: .envelope, placeholder: "Email")
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.keyboardType = .emailAddress
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.returnKeyType = .next
        textField.heightAnchor.constraint(equalToConstant: 56).isActive = true
        return textField
    }()
    
    private let emailErrorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = DesignTypography.caption
        label.textColor = DesignColors.error
        label.isHidden = true
        return label
    }()
    
    private let passwordTextField: IconTextField = {
        let textField = IconTextField(icon: .lock, placeholder: "Password")
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.isSecureTextEntry = true
        textField.returnKeyType = .done
        textField.heightAnchor.constraint(equalToConstant: 56).isActive = true
        return textField
    }()
    
    private let passwordErrorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = DesignTypography.caption
        label.textColor = DesignColors.error
        label.isHidden = true
        return label
    }()
    
    private let forgotPasswordButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Forgot Password?", for: .normal)
        button.titleLabel?.font = DesignTypography.body
        button.setTitleColor(DesignColors.primary, for: .normal)
        button.contentHorizontalAlignment = .right
        return button
    }()
    
    private let signInButton: DSButton = {
        let button = DSButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.style = .primary
        button.setTitle("Sign In", for: .normal)
        button.heightAnchor.constraint(equalToConstant: 56).isActive = true
        return button
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.color = DesignColors.textPrimary
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = DesignTypography.body
        button.setTitleColor(DesignColors.textSecondary, for: .normal)
        
        let fullText = "Don't have an account? Sign Up"
        let attributedString = NSMutableAttributedString(string: fullText)
        let range = (fullText as NSString).range(of: "Sign Up")
        attributedString.addAttribute(.foregroundColor, value: DesignColors.primary, range: NSRange(location: 0, length: fullText.count))
        attributedString.addAttribute(.font, value: DesignTypography.bodyBold, range: range)
        button.setAttributedTitle(attributedString, for: .normal)
        
        return button
    }()
    
    // MARK: - Properties
    
    private let authService = AuthService.shared
    private let biometricManager = BiometricAuthManager.shared
    private let keychain = KeychainManager.shared
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        setupTextFieldDelegates()
        setupKeyboardObservers()
        checkBiometricAvailability()
        checkSavedCredentials()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Auto-prompt biometric if available and has saved credentials
        if biometricButton.isHidden == false,
           keychain.getString(forKey: "biometric_email") != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.promptBiometricAuth()
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = DesignColors.backgroundPrimary
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(headerLabel)
        contentView.addSubview(biometricButton)
        contentView.addSubview(formCard)
        
        // Add fields to form card
        formCard.addArrangedSubview(emailTextField)
        formCard.addArrangedSubview(emailErrorLabel)
        formCard.addArrangedSubview(passwordTextField)
        formCard.addArrangedSubview(passwordErrorLabel)
        formCard.addArrangedSubview(forgotPasswordButton)
        
        contentView.addSubview(signInButton)
        contentView.addSubview(loadingIndicator)
        contentView.addSubview(signUpButton)
        
        NSLayoutConstraint.activate([
            // Scroll View
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Content View
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Header
            headerLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: DesignSpacing.xxxl),
            headerLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: DesignSpacing.xl),
            headerLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -DesignSpacing.xl),
            
            // Biometric Button
            biometricButton.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: DesignSpacing.xl),
            biometricButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: DesignSpacing.xl),
            biometricButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -DesignSpacing.xl),
            biometricButton.heightAnchor.constraint(equalToConstant: 56),
            
            // Form Card
            formCard.topAnchor.constraint(equalTo: biometricButton.bottomAnchor, constant: DesignSpacing.xl),
            formCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: DesignSpacing.xl),
            formCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -DesignSpacing.xl),
            
            // Sign In Button
            signInButton.topAnchor.constraint(equalTo: formCard.bottomAnchor, constant: DesignSpacing.xl),
            signInButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: DesignSpacing.xl),
            signInButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -DesignSpacing.xl),
            
            // Loading Indicator
            loadingIndicator.centerXAnchor.constraint(equalTo: signInButton.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: signInButton.centerYAnchor),
            
            // Sign Up Button
            signUpButton.topAnchor.constraint(equalTo: signInButton.bottomAnchor, constant: DesignSpacing.lg),
            signUpButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: DesignSpacing.xl),
            signUpButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -DesignSpacing.xl),
            signUpButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -DesignSpacing.xxxl)
        ])
    }
    
    private func setupActions() {
        signInButton.addTarget(self, action: #selector(signInTapped), for: .touchUpInside)
        signUpButton.addTarget(self, action: #selector(signUpTapped), for: .touchUpInside)
        biometricButton.addTarget(self, action: #selector(biometricButtonTapped), for: .touchUpInside)
        forgotPasswordButton.addTarget(self, action: #selector(forgotPasswordTapped), for: .touchUpInside)
        
        // Inline validation on blur
        emailTextField.addTarget(self, action: #selector(emailDidEndEditing), for: .editingDidEnd)
        passwordTextField.addTarget(self, action: #selector(passwordDidEndEditing), for: .editingDidEnd)
    }
    
    private func setupTextFieldDelegates() {
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    private func checkBiometricAvailability() {
        biometricButton.isHidden = !biometricManager.isAvailable
    }
    
    private func checkSavedCredentials() {
        if let savedEmail = keychain.getString(forKey: "biometric_email") {
            emailTextField.text = savedEmail
        }
    }
    
    // MARK: - Actions
    
    @objc private func signInTapped() {
        hideAllErrors()
        validateAndLogin()
    }
    
    @objc private func signUpTapped() {
        let registerVC = RegisterViewController()
        navigationController?.pushViewController(registerVC, animated: true)
    }
    
    @objc private func biometricButtonTapped() {
        promptBiometricAuth()
    }
    
    @objc private func forgotPasswordTapped() {
        // TODO: Implement forgot password flow
        let alert = UIAlertController(title: "Forgot Password", message: "Password reset functionality coming soon.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func emailDidEndEditing() {
        validateEmail()
    }
    
    @objc private func passwordDidEndEditing() {
        validatePassword()
    }
    
    @objc private func keyboardWillShow(notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let keyboardHeight = keyboardFrame.height
        scrollView.contentInset.bottom = keyboardHeight
        scrollView.verticalScrollIndicatorInsets.bottom = keyboardHeight
    }
    
    @objc private func keyboardWillHide(notification: Notification) {
        scrollView.contentInset.bottom = 0
        scrollView.verticalScrollIndicatorInsets.bottom = 0
    }
    
    // MARK: - Biometric Authentication
    
    private func promptBiometricAuth() {
        guard biometricManager.isAvailable else { return }
        
        Task {
            do {
                let authenticated = try await biometricManager.authenticate(reason: "Sign in to your account")
                
                if authenticated {
                    await MainActor.run {
                        // Retrieve saved credentials and login
                        if let email = keychain.getString(forKey: "biometric_email"),
                           let password = keychain.getString(forKey: "biometric_password") {
                            performLogin(email: email, password: password, saveCredentials: false)
                        }
                    }
                }
            } catch {
                // Biometric auth failed or cancelled
                print("Biometric authentication failed: \(error)")
            }
        }
    }
    
    // MARK: - Validation
    
    private func validateAndLogin() {
        guard validateEmail() else { return }
        guard validatePassword() else { return }
        
        guard let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              let password = passwordTextField.text else {
            return
        }
        
        performLogin(email: email, password: password, saveCredentials: true)
    }
    
    @discardableResult
    private func validateEmail() -> Bool {
        guard let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !email.isEmpty else {
            showFieldError("Email is required", on: emailTextField, errorLabel: emailErrorLabel)
            return false
        }
        
        guard isValidEmail(email) else {
            showFieldError("Please enter a valid email address", on: emailTextField, errorLabel: emailErrorLabel)
            return false
        }
        
        hideFieldError(emailTextField, errorLabel: emailErrorLabel)
        return true
    }
    
    @discardableResult
    private func validatePassword() -> Bool {
        guard let password = passwordTextField.text, !password.isEmpty else {
            showFieldError("Password is required", on: passwordTextField, errorLabel: passwordErrorLabel)
            return false
        }
        
        hideFieldError(passwordTextField, errorLabel: passwordErrorLabel)
        return true
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    // MARK: - Login
    
    private func performLogin(email: String, password: String, saveCredentials: Bool) {
        setLoading(true)
        
        Task {
            do {
                _ = try await authService.login(email: email, password: password)
                
                // Save credentials for biometric auth if requested
                if saveCredentials && biometricManager.isAvailable {
                    keychain.set(email, forKey: "biometric_email")
                    keychain.set(password, forKey: "biometric_password")
                }
                
                await MainActor.run {
                    setLoading(false)
                    navigateToMainApp()
                }
            } catch {
                await MainActor.run {
                    setLoading(false)
                    handleLoginError(error)
                }
            }
        }
    }
    
    private func handleLoginError(_ error: Error) {
        if let apiError = error as? APIError {
            let errorMessage = apiError.detail.lowercased()
            
            if errorMessage.contains("credentials") || errorMessage.contains("invalid") || errorMessage.contains("401") {
                showFieldError("Invalid email or password", on: passwordTextField, errorLabel: passwordErrorLabel)
                passwordTextField.shake()
            } else if errorMessage.contains("locked") {
                showGeneralError("Account is locked. Please try again later.")
            } else if errorMessage.contains("network") || errorMessage.contains("connect") {
                showGeneralError("Unable to connect. Please check your internet connection.")
            } else {
                showGeneralError(apiError.detail)
            }
        } else {
            showGeneralError("Login failed. Please try again.")
        }
    }
    
    // MARK: - UI Helpers
    
    private func showFieldError(_ message: String, on textField: UITextField, errorLabel: UILabel) {
        errorLabel.text = message
        errorLabel.isHidden = false
        
        textField.layer.borderColor = DesignColors.error.cgColor
        textField.layer.borderWidth = 2
        textField.shake()
    }
    
    private func hideFieldError(_ textField: UITextField, errorLabel: UILabel) {
        errorLabel.isHidden = true
        textField.layer.borderColor = DesignColors.borderPrimary.cgColor
        textField.layer.borderWidth = 1
    }
    
    private func hideAllErrors() {
        hideFieldError(emailTextField, errorLabel: emailErrorLabel)
        hideFieldError(passwordTextField, errorLabel: passwordErrorLabel)
    }
    
    private func showGeneralError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func setLoading(_ loading: Bool) {
        signInButton.isEnabled = !loading
        emailTextField.isEnabled = !loading
        passwordTextField.isEnabled = !loading
        
        if loading {
            loadingIndicator.startAnimating()
            signInButton.setTitle("", for: .normal)
        } else {
            loadingIndicator.stopAnimating()
            signInButton.setTitle("Sign In", for: .normal)
        }
    }
    
    // MARK: - Navigation
    
    private func navigateToMainApp() {
        let tabBarController = MainTabBarController()
        tabBarController.modalPresentationStyle = .fullScreen
        
        // Dismiss login and present tab bar
        if let presentingVC = presentingViewController {
            dismiss(animated: true) {
                presentingVC.present(tabBarController, animated: true)
            }
        } else {
            // If no presenting view controller, set as root
            if let windowScene = view.window?.windowScene {
                let window = UIWindow(windowScene: windowScene)
                window.rootViewController = tabBarController
                window.makeKeyAndVisible()
            }
        }
    }
}

// MARK: - UITextFieldDelegate

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            textField.resignFirstResponder()
            validateAndLogin()
        }
        return true
    }
}
