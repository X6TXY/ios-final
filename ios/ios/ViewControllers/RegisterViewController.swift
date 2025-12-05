//
//  RegisterViewController.swift
//  ios
//
//  Conversion-Optimized Sign-Up Screen
//

import UIKit

class RegisterViewController: UIViewController {
    
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
        label.text = "Create Account"
        label.font = DesignTypography.heading2
        label.textColor = DesignColors.textPrimary
        label.textAlignment = .center
        return label
    }()
    
    private let subheaderLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Join to get personalized recommendations"
        label.font = DesignTypography.body
        label.textColor = DesignColors.textSecondary
        label.textAlignment = .center
        return label
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
    
    private let usernameTextField: IconTextField = {
        let textField = IconTextField(icon: .person, placeholder: "Username")
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.returnKeyType = .next
        textField.heightAnchor.constraint(equalToConstant: 56).isActive = true
        return textField
    }()
    
    private let usernameErrorLabel: UILabel = {
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
        textField.returnKeyType = .next
        textField.heightAnchor.constraint(equalToConstant: 56).isActive = true
        return textField
    }()
    
    private let passwordStrengthIndicator = PasswordStrengthIndicator()
    
    private let passwordErrorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = DesignTypography.caption
        label.textColor = DesignColors.error
        label.isHidden = true
        return label
    }()
    
    private let confirmPasswordTextField: IconTextField = {
        let textField = IconTextField(icon: .lock, placeholder: "Confirm Password")
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.isSecureTextEntry = true
        textField.returnKeyType = .done
        textField.heightAnchor.constraint(equalToConstant: 56).isActive = true
        return textField
    }()
    
    private let confirmPasswordErrorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = DesignTypography.caption
        label.textColor = DesignColors.error
        label.isHidden = true
        return label
    }()
    
    private let termsCheckbox = TermsCheckbox()
    
    private let createAccountButton: DSButton = {
        let button = DSButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.style = .primary
        button.setTitle("Create Account", for: .normal)
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
    
    private let signInButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = DesignTypography.body
        button.setTitleColor(DesignColors.textSecondary, for: .normal)
        button.setTitle("Already have an account? Sign In", for: .normal)
        return button
    }()
    
    // MARK: - Properties
    
    private let authService = AuthService.shared
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        setupTextFieldDelegates()
        setupKeyboardObservers()
        setupNavigationBar()
        setupTermsCheckbox()
        
        // Auto-focus on first field
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.emailTextField.becomeFirstResponder()
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
        contentView.addSubview(subheaderLabel)
        contentView.addSubview(formCard)
        
        // Add fields to form card
        formCard.addArrangedSubview(emailTextField)
        formCard.addArrangedSubview(emailErrorLabel)
        formCard.addArrangedSubview(usernameTextField)
        formCard.addArrangedSubview(usernameErrorLabel)
        formCard.addArrangedSubview(passwordTextField)
        formCard.addArrangedSubview(passwordStrengthIndicator)
        formCard.addArrangedSubview(passwordErrorLabel)
        formCard.addArrangedSubview(confirmPasswordTextField)
        formCard.addArrangedSubview(confirmPasswordErrorLabel)
        formCard.addArrangedSubview(termsCheckbox)
        
        contentView.addSubview(createAccountButton)
        contentView.addSubview(loadingIndicator)
        contentView.addSubview(signInButton)
        
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
            
            // Subheader
            subheaderLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: DesignSpacing.sm),
            subheaderLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: DesignSpacing.xl),
            subheaderLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -DesignSpacing.xl),
            
            // Form Card
            formCard.topAnchor.constraint(equalTo: subheaderLabel.bottomAnchor, constant: DesignSpacing.xxl),
            formCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: DesignSpacing.xl),
            formCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -DesignSpacing.xl),
            
            // Create Account Button
            createAccountButton.topAnchor.constraint(equalTo: formCard.bottomAnchor, constant: DesignSpacing.xl),
            createAccountButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: DesignSpacing.xl),
            createAccountButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -DesignSpacing.xl),
            
            // Loading Indicator
            loadingIndicator.centerXAnchor.constraint(equalTo: createAccountButton.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: createAccountButton.centerYAnchor),
            
            // Sign In Button
            signInButton.topAnchor.constraint(equalTo: createAccountButton.bottomAnchor, constant: DesignSpacing.lg),
            signInButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: DesignSpacing.xl),
            signInButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -DesignSpacing.xl),
            signInButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -DesignSpacing.xxxl)
        ])
        
        updateCreateAccountButton()
    }
    
    private func setupActions() {
        createAccountButton.addTarget(self, action: #selector(createAccountTapped), for: .touchUpInside)
        signInButton.addTarget(self, action: #selector(signInTapped), for: .touchUpInside)
        
        // Password strength monitoring
        passwordTextField.addTarget(self, action: #selector(passwordChanged), for: .editingChanged)
        
        // Inline validation on blur
        emailTextField.addTarget(self, action: #selector(emailDidEndEditing), for: .editingDidEnd)
        usernameTextField.addTarget(self, action: #selector(usernameDidEndEditing), for: .editingDidEnd)
        passwordTextField.addTarget(self, action: #selector(passwordDidEndEditing), for: .editingDidEnd)
        confirmPasswordTextField.addTarget(self, action: #selector(confirmPasswordDidEndEditing), for: .editingDidEnd)
    }
    
    private func setupTextFieldDelegates() {
        emailTextField.delegate = self
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self
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
    
    private func setupNavigationBar() {
        title = "Sign Up"
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.tintColor = DesignColors.primary
    }
    
    private func setupTermsCheckbox() {
        let termsText = "I agree to the Terms of Service and Privacy Policy"
        let attributedString = NSMutableAttributedString(string: termsText)
        let range = (termsText as NSString).range(of: "Terms of Service and Privacy Policy")
        attributedString.addAttribute(.foregroundColor, value: DesignColors.primary, range: range)
        termsCheckbox.setAttributedTermsText(attributedString)
        
        termsCheckbox.onToggle = { [weak self] isChecked in
            self?.updateCreateAccountButton()
        }
    }
    
    // MARK: - Actions
    
    @objc private func createAccountTapped() {
        hideAllErrors()
        validateAndRegister()
    }
    
    @objc private func signInTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func passwordChanged() {
        guard let password = passwordTextField.text else { return }
        passwordStrengthIndicator.updateStrength(password)
        
        // Validate password match if confirm password has text
        if let confirmPassword = confirmPasswordTextField.text, !confirmPassword.isEmpty {
            validatePasswordMatch()
        }
    }
    
    @objc private func emailDidEndEditing() {
        validateEmail()
    }
    
    @objc private func usernameDidEndEditing() {
        validateUsername()
    }
    
    @objc private func passwordDidEndEditing() {
        validatePassword()
    }
    
    @objc private func confirmPasswordDidEndEditing() {
        validatePasswordMatch()
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
    
    // MARK: - Validation
    
    private func validateAndRegister() {
        guard validateEmail() else { return }
        guard validateUsername() else { return }
        guard validatePassword() else { return }
        guard validatePasswordMatch() else { return }
        guard termsCheckbox.isChecked else {
            showError("Please accept the Terms of Service", on: termsCheckbox)
            return
        }
        
        performRegister()
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
    private func validateUsername() -> Bool {
        guard let username = usernameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !username.isEmpty else {
            showFieldError("Username is required", on: usernameTextField, errorLabel: usernameErrorLabel)
            return false
        }
        
        guard username.count >= 3 else {
            showFieldError("Username must be at least 3 characters", on: usernameTextField, errorLabel: usernameErrorLabel)
            return false
        }
        
        hideFieldError(usernameTextField, errorLabel: usernameErrorLabel)
        return true
    }
    
    @discardableResult
    private func validatePassword() -> Bool {
        guard let password = passwordTextField.text, !password.isEmpty else {
            showFieldError("Password is required", on: passwordTextField, errorLabel: passwordErrorLabel)
            return false
        }
        
        guard password.count >= 6 else {
            showFieldError("Password must be at least 6 characters", on: passwordTextField, errorLabel: passwordErrorLabel)
            return false
        }
        
        hideFieldError(passwordTextField, errorLabel: passwordErrorLabel)
        return true
    }
    
    @discardableResult
    private func validatePasswordMatch() -> Bool {
        guard let password = passwordTextField.text, !password.isEmpty else { return true }
        guard let confirmPassword = confirmPasswordTextField.text, !confirmPassword.isEmpty else { return true }
        
        guard password == confirmPassword else {
            showFieldError("Passwords do not match", on: confirmPasswordTextField, errorLabel: confirmPasswordErrorLabel)
            return false
        }
        
        hideFieldError(confirmPasswordTextField, errorLabel: confirmPasswordErrorLabel)
        return true
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    // MARK: - Registration
    
    private func performRegister() {
        setLoading(true)
        
        guard let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              let username = usernameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              let password = passwordTextField.text else {
            return
        }
        
        Task {
            do {
                _ = try await authService.signup(email: email, username: username, password: password)
                
                await MainActor.run {
                    setLoading(false)
                    navigateToMainApp()
                }
            } catch {
                await MainActor.run {
                    setLoading(false)
                    handleRegistrationError(error)
                }
            }
        }
    }
    
    private func handleRegistrationError(_ error: Error) {
        if let apiError = error as? APIError {
            let errorMessage = apiError.detail.lowercased()
            
            if errorMessage.contains("email") {
                showFieldError(apiError.detail, on: emailTextField, errorLabel: emailErrorLabel)
            } else if errorMessage.contains("username") {
                showFieldError(apiError.detail, on: usernameTextField, errorLabel: usernameErrorLabel)
            } else {
                showGeneralError(apiError.detail)
            }
        } else {
            showGeneralError("Registration failed. Please try again.")
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
        hideFieldError(usernameTextField, errorLabel: usernameErrorLabel)
        hideFieldError(passwordTextField, errorLabel: passwordErrorLabel)
        hideFieldError(confirmPasswordTextField, errorLabel: confirmPasswordErrorLabel)
    }
    
    private func showGeneralError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showError(_ message: String, on view: UIView) {
        view.shake()
    }
    
    private func updateCreateAccountButton() {
        let isValid = termsCheckbox.isChecked
        createAccountButton.isEnabled = isValid
    }
    
    private func setLoading(_ loading: Bool) {
        createAccountButton.isEnabled = !loading && termsCheckbox.isChecked
        emailTextField.isEnabled = !loading
        usernameTextField.isEnabled = !loading
        passwordTextField.isEnabled = !loading
        confirmPasswordTextField.isEnabled = !loading
        
        if loading {
            loadingIndicator.startAnimating()
            createAccountButton.setTitle("", for: .normal)
        } else {
            loadingIndicator.stopAnimating()
            createAccountButton.setTitle("Create Account", for: .normal)
        }
    }
    
    // MARK: - Navigation
    
    private func navigateToMainApp() {
        let tabBarController = MainTabBarController()
        tabBarController.modalPresentationStyle = .fullScreen
        
        // Dismiss register and present tab bar
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

extension RegisterViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case emailTextField:
            usernameTextField.becomeFirstResponder()
        case usernameTextField:
            passwordTextField.becomeFirstResponder()
        case passwordTextField:
            confirmPasswordTextField.becomeFirstResponder()
        case confirmPasswordTextField:
            textField.resignFirstResponder()
            if termsCheckbox.isChecked {
                validateAndRegister()
            }
        default:
            textField.resignFirstResponder()
        }
        return true
    }
}
