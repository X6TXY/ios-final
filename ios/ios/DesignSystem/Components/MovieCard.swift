//
//  MovieCard.swift
//  ios
//
//  Movie Card Component
//

import UIKit

class MovieCard: UIView {
    
    private let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = DesignColors.backgroundSecondary
        return imageView
    }()
    
    private let matchBadge: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        label.textColor = .white
        label.textAlignment = .center
        label.backgroundColor = UIColor(hex: "#E50914")
        label.layer.cornerRadius = 4
        label.clipsToBounds = true
        label.isHidden = true
        return label
    }()
    
    var movie: Movie? {
        didSet {
            updateUI()
        }
    }
    
    var onTap: (() -> Void)?
    var onLongPress: (() -> Void)?
    
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
        
        addSubview(posterImageView)
        addSubview(matchBadge)
        
        NSLayoutConstraint.activate([
            posterImageView.topAnchor.constraint(equalTo: topAnchor),
            posterImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            posterImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            posterImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            matchBadge.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            matchBadge.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            matchBadge.heightAnchor.constraint(equalToConstant: 20),
            matchBadge.widthAnchor.constraint(greaterThanOrEqualToConstant: 40)
        ])
        
        layer.cornerRadius = 8
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 8
        layer.shadowOpacity = 0.3
        clipsToBounds = false
        
        // Tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapped))
        addGestureRecognizer(tapGesture)
        
        // Long press gesture
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressed(_:)))
        longPressGesture.minimumPressDuration = 0.5
        addGestureRecognizer(longPressGesture)
    }
    
    private func updateUI() {
        guard let movie = movie else { return }
        
        // Load poster image
        if let posterUrl = movie.posterUrl, let url = URL(string: posterUrl) {
            loadImage(from: url)
        }
        
        // Update match badge
        if let match = movie.matchPercentage {
            matchBadge.text = "\(match)% Match"
            matchBadge.isHidden = false
        } else {
            matchBadge.isHidden = true
        }
    }
    
    private func loadImage(from url: URL) {
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let image = UIImage(data: data) {
                    await MainActor.run {
                        self.posterImageView.image = image
                    }
                }
            } catch {
                print("Failed to load image: \(error)")
            }
        }
    }
    
    @objc private func tapped() {
        onTap?()
    }
    
    @objc private func longPressed(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            onLongPress?()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        animateScale(to: 1.05)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        animateScale(to: 1.0)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        animateScale(to: 1.0)
    }
    
    private func animateScale(to scale: CGFloat) {
        UIView.animate(withDuration: 0.2) {
            self.transform = CGAffineTransform(scaleX: scale, y: scale)
            
            if scale > 1.0 {
                self.layer.shadowRadius = 12
                self.layer.shadowOpacity = 0.5
            } else {
                self.layer.shadowRadius = 8
                self.layer.shadowOpacity = 0.3
            }
        }
    }
}

