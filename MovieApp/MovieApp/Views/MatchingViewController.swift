//
//  MatchingViewController.swift
//  MovieApp
//
//  Created by Baha Toleu on 10.12.2025.
//

import UIKit

final class MatchingViewController: UIViewController {

    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.15, alpha: 1)
        view.layer.cornerRadius = 20
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

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Iron Man"
        label.font = .boldSystemFont(ofSize: 26)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()


    private let likeLabel: UILabel = {
        let label = UILabel()
        label.text = "LIKE"
        label.font = .boldSystemFont(ofSize: 45)
        label.textColor = .systemGreen
        label.alpha = 0
        label.layer.borderWidth = 4
        label.layer.borderColor = UIColor.systemGreen.cgColor
        label.layer.cornerRadius = 8
        label.layer.masksToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let nopeLabel: UILabel = {
        let label = UILabel()
        label.text = "NOPE"
        label.font = .boldSystemFont(ofSize: 45)
        label.textColor = .systemRed
        label.alpha = 0
        label.layer.borderWidth = 4
        label.layer.borderColor = UIColor.systemRed.cgColor
        label.layer.cornerRadius = 8
        label.layer.masksToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let likeButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        btn.tintColor = .systemGreen
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private let dislikeButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        btn.tintColor = .systemRed
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()


    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        setupCard()
        setupButtons()
        addGestures()
    }

    // MARK: — Layout
    private func setupCard() {
        view.addSubview(cardView)
        cardView.addSubview(posterImageView)
        cardView.addSubview(titleLabel)

        // Добавляем LIKE/NOPE поверх карточки
        cardView.addSubview(likeLabel)
        cardView.addSubview(nopeLabel)

        NSLayoutConstraint.activate([
            cardView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cardView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            cardView.widthAnchor.constraint(equalToConstant: 320),
            cardView.heightAnchor.constraint(equalToConstant: 500),

            posterImageView.topAnchor.constraint(equalTo: cardView.topAnchor),
            posterImageView.leftAnchor.constraint(equalTo: cardView.leftAnchor),
            posterImageView.rightAnchor.constraint(equalTo: cardView.rightAnchor),
            posterImageView.heightAnchor.constraint(equalToConstant: 380),

            titleLabel.topAnchor.constraint(equalTo: posterImageView.bottomAnchor, constant: 12),
            titleLabel.leftAnchor.constraint(equalTo: cardView.leftAnchor, constant: 16),

            likeLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 20),
            likeLabel.leftAnchor.constraint(equalTo: cardView.leftAnchor, constant: 20),

            nopeLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 20),
            nopeLabel.rightAnchor.constraint(equalTo: cardView.rightAnchor, constant: -20)
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
            likeButton.widthAnchor.constraint(equalToConstant: 60),
            likeButton.heightAnchor.constraint(equalToConstant: 60),

            dislikeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            dislikeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -80),
            dislikeButton.widthAnchor.constraint(equalToConstant: 60),
            dislikeButton.heightAnchor.constraint(equalToConstant: 60)
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
            } else if x < 0 {
                nopeLabel.alpha = strength
                likeLabel.alpha = 0
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
