//
//  HomeViewController.swift
//  ios
//
//  Netflix-style Home Feed
//

import UIKit

class HomeViewController: UIViewController {
    
    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.showsVerticalScrollIndicator = false
        return scroll
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let heroSection: HeroSection = {
        let hero = HeroSection()
        hero.translatesAutoresizingMaskIntoConstraints = false
        return hero
    }()
    
    private let sectionsStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 0
        return stack
    }()
    
    private var contentSections: [ContentSection] = []
    private let apiService = APIService.shared
    private let authService = AuthService.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        setupHeroSection()
        loadContent()
    }
    
    private func setupUI() {
        view.backgroundColor = DesignColors.backgroundPrimary
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(heroSection)
        contentView.addSubview(sectionsStackView)
        
        let heroHeight: CGFloat = view.bounds.width * 9 / 16 // 16:9 aspect ratio
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            heroSection.topAnchor.constraint(equalTo: contentView.topAnchor),
            heroSection.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            heroSection.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            heroSection.heightAnchor.constraint(equalToConstant: heroHeight),
            
            sectionsStackView.topAnchor.constraint(equalTo: heroSection.bottomAnchor),
            sectionsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            sectionsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            sectionsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        // Pull to refresh
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshContent), for: .valueChanged)
        scrollView.refreshControl = refreshControl
        
        // Hero callbacks
        heroSection.onMovieTap = { [weak self] movie in
            self?.navigateToMovieDetail(movie)
        }
        heroSection.onPlayTap = { [weak self] movie in
            self?.playMovie(movie)
        }
        heroSection.onMyListTap = { [weak self] movie in
            self?.addToMyList(movie)
        }
        heroSection.onShareTap = { [weak self] movie in
            self?.shareMovie(movie)
        }
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        
        // Large title with greeting
        let greetingLabel = UILabel()
        greetingLabel.text = "Home"
        greetingLabel.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        greetingLabel.textColor = DesignColors.textPrimary
        navigationItem.title = "Home"
        
        // Profile avatar
        let avatarButton = UIButton(type: .custom)
        avatarButton.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
        avatarButton.layer.cornerRadius = 16
        avatarButton.backgroundColor = DesignColors.primary
        avatarButton.setImage(UIImage(systemName: "person.fill"), for: .normal)
        avatarButton.tintColor = .white
        avatarButton.addTarget(self, action: #selector(profileTapped), for: .touchUpInside)
        let avatarItem = UIBarButtonItem(customView: avatarButton)
        
        // Search button
        let searchButton = UIBarButtonItem(
            image: UIImage(systemName: "magnifyingglass"),
            style: .plain,
            target: self,
            action: #selector(searchTapped)
        )
        searchButton.tintColor = DesignColors.textPrimary
        
        navigationItem.rightBarButtonItems = [avatarItem, searchButton]
        
        // Transparent navigation bar with blur
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.largeTitleTextAttributes = [.foregroundColor: DesignColors.textPrimary]
        appearance.titleTextAttributes = [.foregroundColor: DesignColors.textPrimary]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    private func setupHeroSection() {
        // Hero section configured in loadContent
    }
    
    private func loadContent() {
        Task {
            do {
                // Load featured movies for hero
                let featured = try await apiService.getFeatured()
                await MainActor.run {
                    if !featured.isEmpty {
                        self.heroSection.configure(with: featured)
                    }
                }
                
                // Load all sections in parallel
                async let recommendations = apiService.getRecommendations(limit: 20)
                async let trending = apiService.getTrending(limit: 20)
                async let continueWatching = apiService.getContinueWatching()
                async let newReleases = apiService.getNewReleases(limit: 20)
                
                let (recs, trend, contWatch, newRel) = try await (recommendations, trending, continueWatching, newReleases)
                
                await MainActor.run {
                    self.setupContentSections(
                        recommendations: recs,
                        trending: trend,
                        continueWatching: contWatch,
                        newReleases: newRel
                    )
                    self.scrollView.refreshControl?.endRefreshing()
                }
            } catch {
                await MainActor.run {
                    self.handleError(error)
                    self.scrollView.refreshControl?.endRefreshing()
                }
            }
        }
    }
    
    private func setupContentSections(
        recommendations: [Movie],
        trending: [Movie],
        continueWatching: [Movie],
        newReleases: [Movie]
    ) {
        // Clear existing sections
        contentSections.forEach { $0.removeFromSuperview() }
        contentSections.removeAll()
        sectionsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Recommended for You
        if !recommendations.isEmpty {
            let section = createSection(title: "Recommended for You", movies: recommendations)
            sectionsStackView.addArrangedSubview(section)
            contentSections.append(section)
        }
        
        // Trending Now
        if !trending.isEmpty {
            let section = createSection(title: "Trending Now", movies: trending)
            sectionsStackView.addArrangedSubview(section)
            contentSections.append(section)
        }
        
        // Continue Watching
        if !continueWatching.isEmpty {
            let section = createSection(title: "Continue Watching", movies: continueWatching)
            sectionsStackView.addArrangedSubview(section)
            contentSections.append(section)
        }
        
        // New Releases
        if !newReleases.isEmpty {
            let section = createSection(title: "New Releases", movies: newReleases)
            sectionsStackView.addArrangedSubview(section)
            contentSections.append(section)
        }
    }
    
    private func createSection(title: String, movies: [Movie]) -> ContentSection {
        let section = ContentSection()
        section.translatesAutoresizingMaskIntoConstraints = false
        section.title = title
        section.movies = movies
        section.showSeeAll = true
        section.onMovieTap = { [weak self] movie in
            self?.navigateToMovieDetail(movie)
        }
        section.onMovieLongPress = { [weak self] movie in
            self?.showQuickActions(for: movie)
        }
        
        NSLayoutConstraint.activate([
            section.heightAnchor.constraint(equalToConstant: 280)
        ])
        
        return section
    }
    
    @objc private func refreshContent() {
        loadContent()
    }
    
    @objc private func profileTapped() {
        // Navigate to profile - get parent tab bar controller
        var parentVC = parent
        while parentVC != nil {
            if let tabBar = parentVC as? MainTabBarController {
                tabBar.setSelectedIndex(4, animated: true)
                break
            }
            parentVC = parentVC?.parent
        }
    }
    
    @objc private func searchTapped() {
        // Navigate to search - get parent tab bar controller
        var parentVC = parent
        while parentVC != nil {
            if let tabBar = parentVC as? MainTabBarController {
                tabBar.setSelectedIndex(1, animated: true)
                break
            }
            parentVC = parentVC?.parent
        }
    }
    
    private func navigateToMovieDetail(_ movie: Movie) {
        // TODO: Navigate to movie detail view
        print("Navigate to movie detail: \(movie.title)")
    }
    
    private func playMovie(_ movie: Movie) {
        // TODO: Play movie
        print("Play movie: \(movie.title)")
    }
    
    private func addToMyList(_ movie: Movie) {
        // TODO: Add to my list
        print("Add to my list: \(movie.title)")
    }
    
    private func shareMovie(_ movie: Movie) {
        let text = "Check out \(movie.title)!"
        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        present(activityVC, animated: true)
    }
    
    private func showQuickActions(for movie: Movie) {
        let alert = UIAlertController(title: movie.title, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Add to My List", style: .default) { _ in
            self.addToMyList(movie)
        })
        
        alert.addAction(UIAlertAction(title: "Share", style: .default) { _ in
            self.shareMovie(movie)
        })
        
        alert.addAction(UIAlertAction(title: "Mark as Watched", style: .default) { _ in
            // TODO: Mark as watched
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    private func handleError(_ error: Error) {
        print("Error loading content: \(error)")
        // Show error state
    }
}

