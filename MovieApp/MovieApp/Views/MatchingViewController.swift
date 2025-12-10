//
//  MatchingViewController.swift
//  MovieApp
//
//  Created by Baha Toleu on 10.12.2025.
//

import UIKit

final class MatchingViewController: UIViewController {

    // Background blur behind the main card
    private let backgroundImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "ironman")
        iv.contentMode = .scaleAspectFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.alpha = 0.35
        return iv
    }()

    private let backgroundBlur: UIVisualEffectView = {
        let blur = UIBlurEffect(style: .dark)
        let view = UIVisualEffectView(effect: blur)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alpha = 0.7
        return view
    }()

    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.15, alpha: 1)
        view.layer.cornerRadius = 20
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.35
        view.layer.shadowOffset = CGSize(width: 0, height: 10)
        view.layer.shadowRadius = 18
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let posterImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "ironman")
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 20
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let gradientOverlay: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = false
        return view
    }()

    private let heartBadge: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 26
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.systemBlue.cgColor
        view.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.18)
        let icon = UIImageView(image: UIImage(systemName: "heart.fill"))
        icon.tintColor = .systemBlue
        icon.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(icon)
        NSLayoutConstraint.activate([
            icon.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            icon.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Iron Man"
        label.font = .boldSystemFont(ofSize: 26)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()


    private lazy var tagsStack: UIStackView = {
        let tags = ["Fantasy", "Noir", "French new wave"]
        let arranged = tags.map { text -> UILabel in
            let label = PaddingLabel(insets: UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12))
            label.text = text
            label.font = .systemFont(ofSize: 12, weight: .semibold)
            label.textColor = .white
            label.layer.cornerRadius = 14
            label.layer.masksToBounds = true
            label.backgroundColor = UIColor.black.withAlphaComponent(0.45)
            return label
        }
        let stack = UIStackView(arrangedSubviews: arranged)
        stack.axis = .horizontal
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()


    private let likeLabel: UIView = {
        let view = UIView()
        view.alpha = 0
        view.layer.borderWidth = 5
        view.layer.borderColor = UIColor.systemGreen.cgColor
        view.layer.cornerRadius = 80
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false

        let icon = UIImageView(image: UIImage(systemName: "checkmark"))
        icon.tintColor = .systemGreen
        icon.contentMode = .scaleAspectFit
        icon.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(icon)

        NSLayoutConstraint.activate([
            icon.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            icon.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 80),
            icon.heightAnchor.constraint(equalToConstant: 80)
        ])
        return view
    }()

    private let nopeLabel: UIView = {
        let view = UIView()
        view.alpha = 0
        view.layer.borderWidth = 5
        view.layer.borderColor = UIColor.systemRed.cgColor
        view.layer.cornerRadius = 80
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false

        let icon = UIImageView(image: UIImage(systemName: "xmark"))
        icon.tintColor = .systemRed
        icon.contentMode = .scaleAspectFit
        icon.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(icon)

        NSLayoutConstraint.activate([
            icon.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            icon.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 80),
            icon.heightAnchor.constraint(equalToConstant: 80)
        ])
        return view
    }()

    private let likeButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        btn.tintColor = .systemGreen
        btn.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.12)
        btn.layer.cornerRadius = 34
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.systemGreen.withAlphaComponent(0.5).cgColor
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private let dislikeButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        btn.tintColor = .systemRed
        btn.backgroundColor = UIColor.systemRed.withAlphaComponent(0.12)
        btn.layer.cornerRadius = 34
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.systemRed.withAlphaComponent(0.5).cgColor
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()


    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupBackground()
        setupCard()
        setupButtons()
        addGestures()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        applyGradient()
    }

    private func setupBackground() {
        view.addSubview(backgroundImageView)
        view.addSubview(backgroundBlur)

        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leftAnchor.constraint(equalTo: view.leftAnchor),
            backgroundImageView.rightAnchor.constraint(equalTo: view.rightAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            backgroundBlur.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundBlur.leftAnchor.constraint(equalTo: view.leftAnchor),
            backgroundBlur.rightAnchor.constraint(equalTo: view.rightAnchor),
            backgroundBlur.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func applyGradient() {
        gradientOverlay.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.6).cgColor
        ]
        gradient.locations = [0.0, 1.0]
        gradient.frame = gradientOverlay.bounds
        gradientOverlay.layer.insertSublayer(gradient, at: 0)
    }

    // MARK: — Layout
    private func setupCard() {
        view.addSubview(cardView)
        view.addSubview(heartBadge)
        cardView.addSubview(posterImageView)
        cardView.addSubview(gradientOverlay)
        cardView.addSubview(titleLabel)
        cardView.addSubview(tagsStack)

        // Добавляем LIKE/NOPE поверх карточки
        cardView.addSubview(likeLabel)
        cardView.addSubview(nopeLabel)

        NSLayoutConstraint.activate([
            cardView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cardView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            cardView.widthAnchor.constraint(equalToConstant: 320),
            cardView.heightAnchor.constraint(equalToConstant: 520),

            heartBadge.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            heartBadge.bottomAnchor.constraint(equalTo: cardView.topAnchor, constant: 30),
            heartBadge.widthAnchor.constraint(equalToConstant: 52),
            heartBadge.heightAnchor.constraint(equalToConstant: 52),

            posterImageView.topAnchor.constraint(equalTo: cardView.topAnchor),
            posterImageView.leftAnchor.constraint(equalTo: cardView.leftAnchor),
            posterImageView.rightAnchor.constraint(equalTo: cardView.rightAnchor),
            posterImageView.heightAnchor.constraint(equalToConstant: 380),

            gradientOverlay.leftAnchor.constraint(equalTo: posterImageView.leftAnchor),
            gradientOverlay.rightAnchor.constraint(equalTo: posterImageView.rightAnchor),
            gradientOverlay.bottomAnchor.constraint(equalTo: posterImageView.bottomAnchor),
            gradientOverlay.heightAnchor.constraint(equalToConstant: 180),

            titleLabel.topAnchor.constraint(equalTo: posterImageView.bottomAnchor, constant: 12),
            titleLabel.leftAnchor.constraint(equalTo: cardView.leftAnchor, constant: 16),

            tagsStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            tagsStack.leftAnchor.constraint(equalTo: titleLabel.leftAnchor),

            likeLabel.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            likeLabel.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            likeLabel.widthAnchor.constraint(equalToConstant: 160),
            likeLabel.heightAnchor.constraint(equalToConstant: 160),

            nopeLabel.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            nopeLabel.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            nopeLabel.widthAnchor.constraint(equalToConstant: 160),
            nopeLabel.heightAnchor.constraint(equalToConstant: 160)
        ])
    }

    private func setupButtons() {
        view.addSubview(likeButton)
        view.addSubview(dislikeButton)

        likeButton.addTarget(self, action: #selector(didLike), for: .touchUpInside)
        dislikeButton.addTarget(self, action: #selector(didDislike), for: .touchUpInside)

        NSLayoutConstraint.activate([
            likeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            likeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 80),
            likeButton.widthAnchor.constraint(equalToConstant: 68),
            likeButton.heightAnchor.constraint(equalToConstant: 68),

            dislikeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            dislikeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -80),
            dislikeButton.widthAnchor.constraint(equalToConstant: 68),
            dislikeButton.heightAnchor.constraint(equalToConstant: 68)
        ])
    }

    private func addGestures() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        cardView.addGestureRecognizer(pan)
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let card = gesture.view!
        let translation = gesture.translation(in: view)

        let x = translation.x
        let strength = min(abs(x) / 150, 1)

        switch gesture.state {

        case .changed:
            // Move
            card.center = CGPoint(x: view.center.x + x, y: view.center.y + translation.y)

            // Rotate
            let rotation = x / 300
            card.transform = CGAffineTransform(rotationAngle: rotation)

            // LIKE / NOPE animation
            if x > 0 {
                likeLabel.alpha = strength
                nopeLabel.alpha = 0
                likeLabel.transform = CGAffineTransform(rotationAngle: -0.15)
                nopeLabel.transform = .identity
            } else if x < 0 {
                nopeLabel.alpha = strength
                likeLabel.alpha = 0
                nopeLabel.transform = CGAffineTransform(rotationAngle: 0.15)
                likeLabel.transform = .identity
            }

        case .ended:
            if x > 120 {
                swipeRight(card)
            } else if x < -120 {
                swipeLeft(card)
            } else {
                resetCard(card)
            }

        default: break
        }
    }


    private func swipeRight(_ card: UIView) {
        UIView.animate(withDuration: 0.3, animations: {
            card.center.x += 400
            card.alpha = 0
        }) { _ in
            self.loadNextCard()
        }
    }

    private func swipeLeft(_ card: UIView) {
        UIView.animate(withDuration: 0.3, animations: {
            card.center.x -= 400
            card.alpha = 0
        }) { _ in
            self.loadNextCard()
        }
    }

    private func resetCard(_ card: UIView) {
        UIView.animate(withDuration: 0.25) {
            card.center = self.view.center
            card.transform = .identity
            card.alpha = 1
            self.likeLabel.alpha = 0
            self.nopeLabel.alpha = 0
        }
    }


    @objc private func didLike() { swipeRight(cardView) }
    @objc private func didDislike() { swipeLeft(cardView) }

    private func loadNextCard() {
        // Reset
        cardView.alpha = 1
        cardView.center = view.center
        cardView.transform = .identity
        likeLabel.alpha = 0
        nopeLabel.alpha = 0
    }
}

// Simple label with padding for tag pills
private final class PaddingLabel: UILabel {
    private let insets: UIEdgeInsets

    init(insets: UIEdgeInsets) {
        self.insets = insets
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        self.insets = .zero
        super.init(coder: coder)
    }

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: insets))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + insets.left + insets.right,
                      height: size.height + insets.top + insets.bottom)
    }
}
