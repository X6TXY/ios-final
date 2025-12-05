//
//  TermsCheckbox.swift
//  ios
//
//  Terms and Conditions Checkbox Component
//

import UIKit

class TermsCheckbox: UIView {
    
    var isChecked: Bool = false {
        didSet {
            updateCheckbox()
        }
    }
    
    var onToggle: ((Bool) -> Void)?
    
    private let checkbox: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.borderWidth = 2
        button.layer.borderColor = DesignColors.borderSecondary.cgColor
        button.layer.cornerRadius = 4
        button.backgroundColor = DesignColors.backgroundSecondary
        return button
    }()
    
    private let checkmarkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = DesignColors.primary
        imageView.isHidden = true
        let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .bold)
        imageView.image = UIImage(systemName: "checkmark", withConfiguration: config)
        return imageView
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = DesignTypography.body
        label.textColor = DesignColors.textSecondary
        label.numberOfLines = 0
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        addSubview(checkbox)
        checkbox.addSubview(checkmarkImageView)
        addSubview(label)
        
        // Create tappable area
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(toggleCheckbox))
        addGestureRecognizer(tapGesture)
        
        checkbox.addTarget(self, action: #selector(toggleCheckbox), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            // Checkbox
            checkbox.leadingAnchor.constraint(equalTo: leadingAnchor),
            checkbox.topAnchor.constraint(equalTo: topAnchor),
            checkbox.widthAnchor.constraint(equalToConstant: 24),
            checkbox.heightAnchor.constraint(equalToConstant: 24),
            
            // Checkmark
            checkmarkImageView.centerXAnchor.constraint(equalTo: checkbox.centerXAnchor),
            checkmarkImageView.centerYAnchor.constraint(equalTo: checkbox.centerYAnchor),
            
            // Label
            label.leadingAnchor.constraint(equalTo: checkbox.trailingAnchor, constant: DesignSpacing.sm),
            label.trailingAnchor.constraint(equalTo: trailingAnchor),
            label.topAnchor.constraint(equalTo: topAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor),
            label.centerYAnchor.constraint(equalTo: checkbox.centerYAnchor)
        ])
    }
    
    func setTermsText(_ text: String) {
        label.text = text
    }
    
    func setAttributedTermsText(_ attributedText: NSAttributedString) {
        label.attributedText = attributedText
    }
    
    @objc private func toggleCheckbox() {
        isChecked.toggle()
        onToggle?(isChecked)
    }
    
    private func updateCheckbox() {
        UIView.animate(withDuration: DesignAnimation.durationFast) {
            if self.isChecked {
                self.checkbox.backgroundColor = DesignColors.primary
                self.checkbox.layer.borderColor = DesignColors.primary.cgColor
                self.checkmarkImageView.isHidden = false
                self.checkmarkImageView.alpha = 1.0
            } else {
                self.checkbox.backgroundColor = DesignColors.backgroundSecondary
                self.checkbox.layer.borderColor = DesignColors.borderSecondary.cgColor
                self.checkmarkImageView.isHidden = true
                self.checkmarkImageView.alpha = 0.0
            }
        }
    }
}

