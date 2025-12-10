//
//  AuthViewController.swift
//  MovieApp
//
//  Created by Baha Toleu on 10.12.2025.
//

import UIKit

final class AuthViewController: UIViewController {

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Auth Screen"
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textAlignment = .center
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Auth"
        view.backgroundColor = .systemBackground
        setupLayout()
    }

    private func setupLayout() {
        view.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

