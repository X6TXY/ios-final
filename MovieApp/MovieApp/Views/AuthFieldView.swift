//
//  AuthFieldView.swift
//  MovieApp
//
//  Created by Uldana Shyndali on 14.12.2025.
//

import UIKit

final class AuthFieldView: UIView {

    enum FieldType {
        case username
        case email
        case password
        case confirmPassword
    }

    private let iconImageView = UIImageView()
    let textField = UITextField()
    private let toggleButton = UIButton(type: .system) // only for password

    var text: String? {
        return textField.text
    }

    var fieldType: FieldType = .username {
        didSet {
            configureFieldType()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        layer.borderColor = UIColor.lightGray.cgColor
        layer.borderWidth = 1
        layer.cornerRadius = 12
        backgroundColor = UIColor.darkGray

        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = .lightGray
        addSubview(iconImageView)
        iconImageView.translatesAutoresizingMaskIntoConstraints = false

        textField.textColor = .white
        textField.backgroundColor = .clear
        textField.attributedPlaceholder = NSAttributedString(
            string: "Placeholder",
            attributes: [.foregroundColor: UIColor.lightGray]
        )
        textField.autocapitalizationType = .none   // disable autocapitalize
        addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false

        toggleButton.tintColor = .lightGray
        toggleButton.imageView?.contentMode = .scaleAspectFit // <--- this keeps proportions
        toggleButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        addSubview(toggleButton)
        toggleButton.translatesAutoresizingMaskIntoConstraints = false
        toggleButton.isHidden = true

        // Layout
        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            iconImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 28),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),

            toggleButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            toggleButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            toggleButton.widthAnchor.constraint(equalToConstant: 24),
            toggleButton.heightAnchor.constraint(equalToConstant: 24),

            textField.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 8),
            textField.trailingAnchor.constraint(equalTo: toggleButton.leadingAnchor, constant: -8),
            textField.topAnchor.constraint(equalTo: topAnchor),
            textField.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    private func configureFieldType() {
        switch fieldType {
        case .username:
            iconImageView.image = UIImage(systemName: "person.fill")
            textField.placeholder = "Username"
            textField.isSecureTextEntry = false
            toggleButton.isHidden = true
        case .email:
            iconImageView.image = UIImage(systemName: "envelope.fill")
            textField.placeholder = "Email"
            textField.keyboardType = .emailAddress
            textField.isSecureTextEntry = false
            toggleButton.isHidden = true
        case .password, .confirmPassword:
            iconImageView.image = UIImage(systemName: "lock.fill")
            textField.placeholder = fieldType == .password ? "Password" : "Confirm Password"
            textField.isSecureTextEntry = true
            textField.textContentType = .none
            textField.autocorrectionType = .no
            textField.passwordRules = nil
            toggleButton.isHidden = false
            toggleButton.setImage(UIImage(systemName: "eye.slash.fill"), for: .normal)

        }
    }

    @objc private func togglePasswordVisibility() {
        textField.isSecureTextEntry.toggle()
        let imageName = textField.isSecureTextEntry ? "eye.slash.fill" : "eye.fill"
        toggleButton.setImage(UIImage(systemName: imageName), for: .normal)
    }
}
