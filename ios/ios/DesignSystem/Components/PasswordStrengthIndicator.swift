//
//  PasswordStrengthIndicator.swift
//  ios
//
//  Password Strength Indicator Component
//

import UIKit

enum PasswordStrength {
    case weak
    case medium
    case strong
    
    var color: UIColor {
        switch self {
        case .weak: return DesignColors.error
        case .medium: return DesignColors.warning
        case .strong: return DesignColors.success
        }
    }
    
    var label: String {
        switch self {
        case .weak: return "Weak"
        case .medium: return "Medium"
        case .strong: return "Strong"
        }
    }
}

class PasswordStrengthIndicator: UIView {
    
    private let strengthLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = DesignTypography.caption
        label.textColor = DesignColors.textSecondary
        return label
    }()
    
    private let strengthBar: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = DesignColors.backgroundTertiary
        view.layer.cornerRadius = 2
        return view
    }()
    
    private let strengthFill: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 2
        return view
    }()
    
    private var fillWidthConstraint: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        addSubview(strengthBar)
        strengthBar.addSubview(strengthFill)
        addSubview(strengthLabel)
        
        NSLayoutConstraint.activate([
            // Strength Bar
            strengthBar.topAnchor.constraint(equalTo: topAnchor),
            strengthBar.leadingAnchor.constraint(equalTo: leadingAnchor),
            strengthBar.trailingAnchor.constraint(equalTo: trailingAnchor),
            strengthBar.heightAnchor.constraint(equalToConstant: 4),
            
            // Strength Fill
            strengthFill.topAnchor.constraint(equalTo: strengthBar.topAnchor),
            strengthFill.leadingAnchor.constraint(equalTo: strengthBar.leadingAnchor),
            strengthFill.bottomAnchor.constraint(equalTo: strengthBar.bottomAnchor),
            
            // Label
            strengthLabel.topAnchor.constraint(equalTo: strengthBar.bottomAnchor, constant: DesignSpacing.xs),
            strengthLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            strengthLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            strengthLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        fillWidthConstraint = strengthFill.widthAnchor.constraint(equalTo: strengthBar.widthAnchor, multiplier: 0)
        fillWidthConstraint?.isActive = true
        
        isHidden = true
    }
    
    func updateStrength(_ password: String) {
        guard !password.isEmpty else {
            isHidden = true
            return
        }
        
        isHidden = false
        let strength = calculateStrength(password)
        
        UIView.animate(withDuration: DesignAnimation.durationFast) {
            self.strengthFill.backgroundColor = strength.color
            self.strengthLabel.textColor = strength.color
            self.strengthLabel.text = strength.label
            
            // Update width
            let multiplier: CGFloat
            switch strength {
            case .weak: multiplier = 0.33
            case .medium: multiplier = 0.66
            case .strong: multiplier = 1.0
            }
            
            self.fillWidthConstraint?.isActive = false
            self.fillWidthConstraint = self.strengthFill.widthAnchor.constraint(equalTo: self.strengthBar.widthAnchor, multiplier: multiplier)
            self.fillWidthConstraint?.isActive = true
            self.layoutIfNeeded()
        }
    }
    
    private func calculateStrength(_ password: String) -> PasswordStrength {
        var score = 0
        
        // Length
        if password.count >= 8 { score += 1 }
        if password.count >= 12 { score += 1 }
        
        // Character variety
        if password.rangeOfCharacter(from: CharacterSet.uppercaseLetters) != nil { score += 1 }
        if password.rangeOfCharacter(from: CharacterSet.lowercaseLetters) != nil { score += 1 }
        if password.rangeOfCharacter(from: CharacterSet.decimalDigits) != nil { score += 1 }
        if password.rangeOfCharacter(from: CharacterSet(charactersIn: "!@#$%^&*()_+-=[]{}|;:,.<>?")) != nil { score += 1 }
        
        if score <= 2 {
            return .weak
        } else if score <= 4 {
            return .medium
        } else {
            return .strong
        }
    }
}

