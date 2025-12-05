//
//  OnboardingViewController.swift
//  ios
//
//  Onboarding Screen with Multiple Slides
//

import UIKit

struct OnboardingSlide {
    let icon: String
    let title: String
    let description: String
    let iconColor: UIColor
}

class OnboardingViewController: UIViewController {
    
    // MARK: - Data
    
    private let slides: [OnboardingSlide] = [
        OnboardingSlide(
            icon: "sparkles",
            title: "Personalized Recommendations",
            description: "Discover movies tailored to your taste using AI-powered recommendations",
            iconColor: DesignColors.primary
        ),
        OnboardingSlide(
            icon: "person.2.fill",
            title: "Connect with Friends",
            description: "Share your favorite films and get movie suggestions from friends",
            iconColor: DesignColors.accent
        ),
        OnboardingSlide(
            icon: "checkmark.circle.fill",
            title: "Track Your Watchlist",
            description: "Keep track of movies you want to watch and mark your favorites",
            iconColor: DesignColors.success
        ),
        OnboardingSlide(
            icon: "hand.draw.fill",
            title: "Swipe to Discover",
            description: "Swipe through movie cards to find your next favorite film",
            iconColor: DesignColors.info
        )
    ]
    
    // MARK: - UI Components
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bounces = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var slideViews: [OnboardingSlideView] = []
    
    private let pageControl: DSPageControl = {
        let pageControl = DSPageControl()
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()
    
    private let skipButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Skip", for: .normal)
        button.titleLabel?.font = DesignTypography.body
        button.setTitleColor(DesignColors.textSecondary, for: .normal)
        return button
    }()
    
    private let bottomContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    private let getStartedButton: DSButton = {
        let button = DSButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.style = .primary
        button.setTitle("Get Started", for: .normal)
        return button
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
    
    private var currentPage: Int = 0 {
        didSet {
            updateUIForCurrentPage()
        }
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupSlides()
        setupActions()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateScrollViewContentSize()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = DesignColors.backgroundPrimary
        
        view.addSubview(scrollView)
        view.addSubview(skipButton)
        view.addSubview(bottomContainerView)
        view.addSubview(pageControl)
        
        scrollView.addSubview(contentView)
        bottomContainerView.addSubview(getStartedButton)
        bottomContainerView.addSubview(signInButton)
        
        scrollView.delegate = self
        
        NSLayoutConstraint.activate([
            // Scroll View
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomContainerView.topAnchor),
            
            // Content View
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
            
            // Skip Button
            skipButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: DesignSpacing.base),
            skipButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -DesignSpacing.xl),
            
            // Page Control
            pageControl.bottomAnchor.constraint(equalTo: bottomContainerView.topAnchor, constant: -DesignSpacing.xl),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.heightAnchor.constraint(equalToConstant: 8),
            
            // Bottom Container
            bottomContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            // Get Started Button
            getStartedButton.topAnchor.constraint(equalTo: bottomContainerView.topAnchor, constant: DesignSpacing.lg),
            getStartedButton.leadingAnchor.constraint(equalTo: bottomContainerView.leadingAnchor, constant: DesignSpacing.xl),
            getStartedButton.trailingAnchor.constraint(equalTo: bottomContainerView.trailingAnchor, constant: -DesignSpacing.xl),
            getStartedButton.heightAnchor.constraint(equalToConstant: 56),
            
            // Sign In Button
            signInButton.topAnchor.constraint(equalTo: getStartedButton.bottomAnchor, constant: DesignSpacing.base),
            signInButton.leadingAnchor.constraint(equalTo: bottomContainerView.leadingAnchor, constant: DesignSpacing.xl),
            signInButton.trailingAnchor.constraint(equalTo: bottomContainerView.trailingAnchor, constant: -DesignSpacing.xl),
            signInButton.bottomAnchor.constraint(equalTo: bottomContainerView.bottomAnchor, constant: -DesignSpacing.lg)
        ])
        
        pageControl.numberOfPages = slides.count
        pageControl.currentPage = 0
        
        updateUIForCurrentPage()
    }
    
    private func setupSlides() {
        slideViews = []
        
        for slide in slides {
            let slideView = OnboardingSlideView(slide: slide)
            slideView.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(slideView)
            slideViews.append(slideView)
            
            NSLayoutConstraint.activate([
                slideView.topAnchor.constraint(equalTo: contentView.topAnchor),
                slideView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                slideView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
                slideView.heightAnchor.constraint(equalTo: contentView.heightAnchor)
            ])
        }
        
        // Layout slide views horizontally
        for (index, slideView) in slideViews.enumerated() {
            if index == 0 {
                slideView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
            } else {
                slideView.leadingAnchor.constraint(equalTo: slideViews[index - 1].trailingAnchor).isActive = true
            }
            
            if index == slideViews.count - 1 {
                slideView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
            }
        }
        
        updateScrollViewContentSize()
    }
    
    private func updateScrollViewContentSize() {
        let width = view.bounds.width * CGFloat(slides.count)
        scrollView.contentSize = CGSize(width: width, height: scrollView.bounds.height)
    }
    
    private func setupActions() {
        skipButton.addTarget(self, action: #selector(skipTapped), for: .touchUpInside)
        getStartedButton.addTarget(self, action: #selector(getStartedTapped), for: .touchUpInside)
        signInButton.addTarget(self, action: #selector(signInTapped), for: .touchUpInside)
    }
    
    // MARK: - Actions
    
    @objc private func skipTapped() {
        markOnboardingComplete()
        navigateToLogin()
    }
    
    @objc private func getStartedTapped() {
        if currentPage < slides.count - 1 {
            // Scroll to next page
            let nextPage = currentPage + 1
            let pageWidth = scrollView.bounds.width
            let offset = CGPoint(x: CGFloat(nextPage) * pageWidth, y: 0)
            scrollView.setContentOffset(offset, animated: true)
        } else {
            // Last page - navigate to register
            markOnboardingComplete()
            navigateToRegister()
        }
    }
    
    @objc private func signInTapped() {
        markOnboardingComplete()
        navigateToLogin()
    }
    
    private func markOnboardingComplete() {
        UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
    }
    
    // MARK: - UI Updates
    
    private func updateUIForCurrentPage() {
        pageControl.currentPage = currentPage
        
        // Show/hide skip button on last page
        skipButton.isHidden = currentPage == slides.count - 1
        
        // Update button text on last page
        if currentPage == slides.count - 1 {
            getStartedButton.setTitle("Get Started", for: .normal)
        } else {
            getStartedButton.setTitle("Next", for: .normal)
        }
    }
    
    // MARK: - Navigation
    
    private func navigateToLogin() {
        let loginVC = LoginViewController()
        let navController = UINavigationController(rootViewController: loginVC)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true)
    }
    
    private func navigateToRegister() {
        let registerVC = RegisterViewController()
        let navController = UINavigationController(rootViewController: registerVC)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true)
    }
}

// MARK: - UIScrollViewDelegate

extension OnboardingViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.bounds.width
        guard pageWidth > 0 else { return }
        
        let currentPageFloat = scrollView.contentOffset.x / pageWidth
        let newPage = Int(round(currentPageFloat))
        
        if newPage != currentPage && newPage >= 0 && newPage < slides.count {
            currentPage = newPage
        }
        
        // Parallax effect
        applyParallaxEffect(offset: scrollView.contentOffset.x)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateCurrentPageFromScrollView()
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        updateCurrentPageFromScrollView()
    }
    
    private func updateCurrentPageFromScrollView() {
        let pageWidth = scrollView.bounds.width
        guard pageWidth > 0 else { return }
        let page = Int(scrollView.contentOffset.x / pageWidth)
        if page >= 0 && page < slides.count {
            currentPage = page
        }
    }
    
    private func applyParallaxEffect(offset: CGFloat) {
        let pageWidth = view.bounds.width
        let currentPageFloat = offset / pageWidth
        
        for (index, slideView) in slideViews.enumerated() {
            let pageIndex = CGFloat(index)
            let distance = currentPageFloat - pageIndex
            
            // Parallax movement
            slideView.transform = CGAffineTransform(translationX: -distance * pageWidth * 0.3, y: 0)
            
            // Fade effect
            let alpha = 1.0 - abs(distance) * 0.5
            slideView.alpha = max(0.5, min(1.0, alpha))
        }
    }
}

// MARK: - Onboarding Slide View

class OnboardingSlideView: UIView {
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = DesignTypography.heading2
        label.textColor = DesignColors.textPrimary
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = DesignTypography.body
        label.textColor = DesignColors.textSecondary
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    init(slide: OnboardingSlide) {
        super.init(frame: .zero)
        setupUI(slide: slide)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI(slide: OnboardingSlide) {
        backgroundColor = .clear
        
        addSubview(iconImageView)
        addSubview(titleLabel)
        addSubview(descriptionLabel)
        
        // Configure content
        let config = UIImage.SymbolConfiguration(pointSize: 100, weight: .bold)
        iconImageView.image = UIImage(systemName: slide.icon, withConfiguration: config)
        iconImageView.tintColor = slide.iconColor
        titleLabel.text = slide.title
        descriptionLabel.text = slide.description
        
        NSLayoutConstraint.activate([
            // Icon
            iconImageView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: DesignSpacing.xxxl),
            iconImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 120),
            iconImageView.heightAnchor.constraint(equalToConstant: 120),
            
            // Title
            titleLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: DesignSpacing.xxxl),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: DesignSpacing.xl),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -DesignSpacing.xl),
            
            // Description
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: DesignSpacing.lg),
            descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: DesignSpacing.xl),
            descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -DesignSpacing.xl)
        ])
    }
}

