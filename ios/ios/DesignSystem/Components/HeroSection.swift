//
//  HeroSection.swift
//  ios
//
//  Hero Section Component for Featured Movie
//

import UIKit

class HeroSection: UIView {
    
    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.isPagingEnabled = true
        scroll.showsHorizontalScrollIndicator = false
        scroll.bounces = false
        return scroll
    }()
    
    private let contentView = UIView()
    private var heroViews: [HeroMovieView] = []
    private var movies: [Movie] = []
    private var currentPage = 0
    private var timer: Timer?
    
    var onMovieTap: ((Movie) -> Void)?
    var onPlayTap: ((Movie) -> Void)?
    var onMyListTap: ((Movie) -> Void)?
    var onShareTap: ((Movie) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        ])
        
        scrollView.delegate = self
    }
    
    func configure(with movies: [Movie]) {
        self.movies = movies
        setupHeroViews()
        startAutoScroll()
    }
    
    private func setupHeroViews() {
        heroViews.forEach { $0.removeFromSuperview() }
        heroViews.removeAll()
        contentView.subviews.forEach { $0.removeFromSuperview() }
        
        guard !movies.isEmpty else { return }
        
        var previousView: UIView?
        
        for (index, movie) in movies.enumerated() {
            let heroView = HeroMovieView()
            heroView.translatesAutoresizingMaskIntoConstraints = false
            heroView.configure(with: movie)
            heroView.onPlayTap = { [weak self] in self?.onPlayTap?(movie) }
            heroView.onMyListTap = { [weak self] in self?.onMyListTap?(movie) }
            heroView.onShareTap = { [weak self] in self?.onShareTap?(movie) }
            
            contentView.addSubview(heroView)
            heroViews.append(heroView)
            
            NSLayoutConstraint.activate([
                heroView.topAnchor.constraint(equalTo: contentView.topAnchor),
                heroView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                heroView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
                heroView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
            ])
            
            if let previous = previousView {
                heroView.leadingAnchor.constraint(equalTo: previous.trailingAnchor).isActive = true
            } else {
                heroView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
            }
            
            previousView = heroView
        }
        
        if let last = previousView {
            last.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        }
        
        scrollView.contentSize = CGSize(width: CGFloat(movies.count) * bounds.width, height: bounds.height)
    }
    
    private func startAutoScroll() {
        stopAutoScroll()
        guard movies.count > 1 else { return }
        
        timer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { [weak self] _ in
            self?.scrollToNext()
        }
    }
    
    private func stopAutoScroll() {
        timer?.invalidate()
        timer = nil
    }
    
    private func scrollToNext() {
        guard movies.count > 1 else { return }
        currentPage = (currentPage + 1) % movies.count
        scrollToPage(currentPage, animated: true)
    }
    
    private func scrollToPage(_ page: Int, animated: Bool) {
        let offsetX = CGFloat(page) * scrollView.bounds.width
        scrollView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: animated)
    }
    
    deinit {
        stopAutoScroll()
    }
}

extension HeroSection: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.bounds.width
        guard pageWidth > 0 else { return }
        currentPage = Int(round(scrollView.contentOffset.x / pageWidth))
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        stopAutoScroll()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        startAutoScroll()
    }
}

// MARK: - Hero Movie View

class HeroMovieView: UIView {
    
    private let backdropImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = DesignColors.backgroundSecondary
        return imageView
    }()
    
    private let gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.3).cgColor,
            UIColor.black.withAlphaComponent(0.8).cgColor
        ]
        layer.locations = [0.0, 0.5, 1.0]
        layer.startPoint = CGPoint(x: 0.5, y: 0.0)
        layer.endPoint = CGPoint(x: 0.5, y: 1.0)
        return layer
    }()
    
    private let gradientView = UIView()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.textColor = .white
        label.numberOfLines = 2
        return label
    }()
    
    private let genreStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fill
        return stack
    }()
    
    private let ratingBadge: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .white
        label.textAlignment = .center
        label.backgroundColor = UIColor(hex: "#E50914")
        label.layer.cornerRadius = 6
        label.clipsToBounds = true
        return label
    }()
    
    private let buttonsStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 12
        stack.distribution = .fill
        return stack
    }()
    
    var onPlayTap: (() -> Void)?
    var onMyListTap: (() -> Void)?
    var onShareTap: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        addSubview(backdropImageView)
        addSubview(gradientView)
        addSubview(titleLabel)
        addSubview(genreStackView)
        addSubview(ratingBadge)
        addSubview(buttonsStackView)
        
        gradientView.layer.addSublayer(gradientLayer)
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            backdropImageView.topAnchor.constraint(equalTo: topAnchor),
            backdropImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backdropImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backdropImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            gradientView.topAnchor.constraint(equalTo: topAnchor),
            gradientView.leadingAnchor.constraint(equalTo: leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: trailingAnchor),
            gradientView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            ratingBadge.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            ratingBadge.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16),
            ratingBadge.heightAnchor.constraint(equalToConstant: 32),
            ratingBadge.widthAnchor.constraint(greaterThanOrEqualToConstant: 60),
            
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            titleLabel.bottomAnchor.constraint(equalTo: genreStackView.topAnchor, constant: -8),
            
            genreStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            genreStackView.bottomAnchor.constraint(equalTo: buttonsStackView.topAnchor, constant: -16),
            
            buttonsStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            buttonsStackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -32),
            buttonsStackView.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        setupButtons()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = gradientView.bounds
    }
    
    private func setupButtons() {
        // Play button
        let playButton = createActionButton(title: "Play", icon: "play.fill", isPrimary: true)
        playButton.addTarget(self, action: #selector(playTapped), for: .touchUpInside)
        buttonsStackView.addArrangedSubview(playButton)
        
        // My List button
        let myListButton = createActionButton(title: "My List", icon: "plus", isPrimary: false)
        myListButton.addTarget(self, action: #selector(myListTapped), for: .touchUpInside)
        buttonsStackView.addArrangedSubview(myListButton)
        
        // Share button
        let shareButton = createActionButton(title: nil, icon: "square.and.arrow.up", isPrimary: false)
        shareButton.addTarget(self, action: #selector(shareTapped), for: .touchUpInside)
        buttonsStackView.addArrangedSubview(shareButton)
        
        NSLayoutConstraint.activate([
            playButton.widthAnchor.constraint(equalToConstant: 120),
            myListButton.widthAnchor.constraint(equalToConstant: 100),
            shareButton.widthAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func createActionButton(title: String?, icon: String, isPrimary: Bool) -> UIButton {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        let image = UIImage(systemName: icon, withConfiguration: config)
        
        if isPrimary {
            button.backgroundColor = .white
            button.setTitleColor(.black, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
            button.setTitle(title, for: .normal)
            button.setImage(image, for: .normal)
            button.tintColor = .black
            button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 0)
        } else {
            button.backgroundColor = UIColor.white.withAlphaComponent(0.2)
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.white.withAlphaComponent(0.5).cgColor
            button.setImage(image, for: .normal)
            button.tintColor = .white
            if let title = title {
                button.setTitle(title, for: .normal)
                button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
                button.setTitleColor(.white, for: .normal)
            }
        }
        
        button.layer.cornerRadius = 8
        return button
    }
    
    func configure(with movie: Movie) {
        titleLabel.text = movie.title
        
        // Load backdrop
        if let backdropUrl = movie.backdropUrl, let url = URL(string: backdropUrl) {
            loadImage(from: url)
        }
        
        // Update genres
        genreStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for genre in movie.genres.prefix(3) {
            let pill = createGenrePill(text: genre)
            genreStackView.addArrangedSubview(pill)
        }
        
        // Update rating
        if let match = movie.matchPercentage {
            ratingBadge.text = "\(match)% Match"
            ratingBadge.isHidden = false
        } else if let rating = movie.rating {
            ratingBadge.text = String(format: "%.0f%%", rating * 10)
            ratingBadge.isHidden = false
        } else {
            ratingBadge.isHidden = true
        }
    }
    
    private func createGenrePill(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .white
        label.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        label.layer.cornerRadius = 12
        label.clipsToBounds = true
        label.textAlignment = .center
        label.padding = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
        return label
    }
    
    private func loadImage(from url: URL) {
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let image = UIImage(data: data) {
                    await MainActor.run {
                        self.backdropImageView.image = image
                    }
                }
            } catch {
                print("Failed to load backdrop: \(error)")
            }
        }
    }
    
    @objc private func playTapped() {
        onPlayTap?()
    }
    
    @objc private func myListTapped() {
        onMyListTap?()
    }
    
    @objc private func shareTapped() {
        onShareTap?()
    }
}

// MARK: - UILabel Extension for Padding

extension UILabel {
    private struct AssociatedKeys {
        static var padding = UIEdgeInsets()
    }
    
    var padding: UIEdgeInsets {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.padding) as? UIEdgeInsets ?? .zero
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.padding, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    override open func draw(_ rect: CGRect) {
        if padding != .zero {
            drawText(in: rect.inset(by: padding))
        } else {
            drawText(in: rect)
        }
    }
    
    override open var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + padding.left + padding.right,
                     height: size.height + padding.top + padding.bottom)
    }
}

