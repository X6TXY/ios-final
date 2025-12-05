//
//  ContentSection.swift
//  ios
//
//  Content Section Component for Movie Lists
//

import UIKit

class ContentSection: UIView {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        label.textColor = DesignColors.textPrimary
        return label
    }()
    
    private let seeAllButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("See All", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        button.setTitleColor(DesignColors.primary, for: .normal)
        button.isHidden = true
        return button
    }()
    
    private let headerStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        stack.alignment = .center
        return stack
    }()
    
    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.showsHorizontalScrollIndicator = false
        scroll.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        return scroll
    }()
    
    private let contentStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 12
        stack.distribution = .fill
        return stack
    }()
    
    private var movieCards: [MovieCard] = []
    var movies: [Movie] = [] {
        didSet {
            updateMovies()
        }
    }
    
    var title: String = "" {
        didSet {
            titleLabel.text = title
        }
    }
    
    var showSeeAll: Bool = false {
        didSet {
            seeAllButton.isHidden = !showSeeAll
        }
    }
    
    var onMovieTap: ((Movie) -> Void)?
    var onMovieLongPress: ((Movie) -> Void)?
    var onSeeAllTap: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = .clear
        
        headerStackView.addArrangedSubview(titleLabel)
        headerStackView.addArrangedSubview(seeAllButton)
        
        scrollView.addSubview(contentStackView)
        
        addSubview(headerStackView)
        addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            headerStackView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            headerStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            headerStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            scrollView.topAnchor.constraint(equalTo: headerStackView.bottomAnchor, constant: 16),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentStackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        ])
        
        seeAllButton.addTarget(self, action: #selector(seeAllTapped), for: .touchUpInside)
    }
    
    private func updateMovies() {
        // Remove old cards
        movieCards.forEach { $0.removeFromSuperview() }
        movieCards.removeAll()
        contentStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Create new cards
        let cardWidth: CGFloat = 130
        let cardHeight: CGFloat = cardWidth * 1.5 // 2:3 aspect ratio
        
        for movie in movies {
            let card = MovieCard()
            card.translatesAutoresizingMaskIntoConstraints = false
            card.movie = movie
            card.onTap = { [weak self] in
                self?.onMovieTap?(movie)
            }
            card.onLongPress = { [weak self] in
                self?.onMovieLongPress?(movie)
            }
            
            contentStackView.addArrangedSubview(card)
            movieCards.append(card)
            
            NSLayoutConstraint.activate([
                card.widthAnchor.constraint(equalToConstant: cardWidth),
                card.heightAnchor.constraint(equalToConstant: cardHeight)
            ])
        }
    }
    
    @objc private func seeAllTapped() {
        onSeeAllTap?()
    }
}

