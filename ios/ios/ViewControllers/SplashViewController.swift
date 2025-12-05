//
//  SplashViewController.swift
//  ios
//
//  Modern Splash Screen with Gradient and Glow Effect
//

import UIKit

class SplashViewController: UIViewController {
    
    // MARK: - UI Components
    
    private let gradientView: GradientView = {
        let view = GradientView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.colors = [
            UIColor(red: 0.545, green: 0.0, blue: 0.0, alpha: 1.0), // #8B0000 deep burgundy
            UIColor.black
        ]
        view.startPoint = CGPoint(x: 0.5, y: 0.0)
        view.endPoint = CGPoint(x: 0.5, y: 1.0)
        return view
    }()
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        let config = UIImage.SymbolConfiguration(pointSize: 80, weight: .bold)
        imageView.image = UIImage(systemName: "film.fill", withConfiguration: config)
        
        // Add glow effect
        imageView.layer.shadowColor = UIColor.white.cgColor
        imageView.layer.shadowRadius = 20
        imageView.layer.shadowOpacity = 0.8
        imageView.layer.shadowOffset = .zero
        imageView.layer.masksToBounds = false
        
        return imageView
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.color = .white
        indicator.hidesWhenStopped = false
        return indicator
    }()
    
    private let taglineLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Discover Your Next Favorite"
        label.font = DesignTypography.heading3
        label.textColor = .white
        label.textAlignment = .center
        label.alpha = 0
        return label
    }()
    
    // MARK: - Properties
    
    private let authService = AuthService.shared
    private let apiService = APIService.shared
    private var hasNavigated = false
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startAnimation()
        checkAuthenticationAndHealth()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .black
        
        view.addSubview(gradientView)
        view.addSubview(logoImageView)
        view.addSubview(loadingIndicator)
        view.addSubview(taglineLabel)
        
        NSLayoutConstraint.activate([
            // Gradient View - Full screen
            gradientView.topAnchor.constraint(equalTo: view.topAnchor),
            gradientView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            gradientView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Logo - Centered
            logoImageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: -DesignSpacing.xxl),
            logoImageView.widthAnchor.constraint(equalToConstant: 120),
            logoImageView.heightAnchor.constraint(equalToConstant: 120),
            
            // Loading Indicator - Below logo
            loadingIndicator.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: DesignSpacing.xxl),
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Tagline - At bottom
            taglineLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -DesignSpacing.xxxl),
            taglineLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: DesignSpacing.xl),
            taglineLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -DesignSpacing.xl)
        ])
        
        // Initial state
        logoImageView.alpha = 0
        loadingIndicator.alpha = 0
    }
    
    // MARK: - Animation
    
    private func startAnimation() {
        loadingIndicator.startAnimating()
        
        // Fade-in logo with scale
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut) {
            self.logoImageView.alpha = 1.0
            self.logoImageView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            self.loadingIndicator.alpha = 1.0
        }
        
        // Fade-in tagline
        UIView.animate(withDuration: 0.5, delay: 0.3, options: .curveEaseOut) {
            self.taglineLabel.alpha = 1.0
        }
    }
    
    // MARK: - API Checks
    
    private func checkAuthenticationAndHealth() {
        Task {
            // Check backend health first
            do {
                let health = try await apiService.checkHealth()
                print("✓ Backend health check passed - Status: \(health.status)")
            } catch {
                print("⚠ Backend health check failed: \(error)")
                // Continue anyway - might be offline
            }
            
            // Check authentication status
            await checkAuthenticationStatus()
        }
    }
    
    private func checkAuthenticationStatus() async {
        // Wait minimum 2 seconds for splash screen
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        
        guard !hasNavigated else { return }
        
        if authService.isAuthenticated {
            // Validate token by fetching current user
            do {
                _ = try await authService.getCurrentUser()
                await MainActor.run {
                    navigateToMainApp()
                }
            } catch {
                // Token invalid, clear it and show onboarding/login
                authService.logout()
                await MainActor.run {
                    checkFirstLaunch()
                }
            }
        } else {
            await MainActor.run {
                checkFirstLaunch()
            }
        }
    }
    
    private func checkFirstLaunch() {
        guard !hasNavigated else { return }
        hasNavigated = true
        
        // Check if user has seen onboarding
        let hasSeenOnboarding = UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
        
        if hasSeenOnboarding {
            navigateToLogin()
        } else {
            navigateToOnboarding()
        }
    }
    
    // MARK: - Navigation
    
    private func navigateToOnboarding() {
        let onboardingVC = OnboardingViewController()
        onboardingVC.modalPresentationStyle = .fullScreen
        onboardingVC.modalTransitionStyle = .crossDissolve
        present(onboardingVC, animated: true)
    }
    
    private func navigateToLogin() {
        let loginVC = LoginViewController()
        let navController = UINavigationController(rootViewController: loginVC)
        navController.modalPresentationStyle = .fullScreen
        navController.modalTransitionStyle = .crossDissolve
        present(navController, animated: true)
    }
    
    private func navigateToMainApp() {
        guard !hasNavigated else { return }
        hasNavigated = true
        
        let tabBarController = MainTabBarController()
        tabBarController.modalPresentationStyle = .fullScreen
        present(tabBarController, animated: true)
    }
}
