//
//  FormCardView.swift
//  ios
//
//  Card Container for Form Fields
//

import UIKit

class FormCardView: UIView {
    
    private let contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = DesignSpacing.base
        stackView.distribution = .fill
        return stackView
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
        backgroundColor = DesignColors.backgroundSecondary
        layer.cornerRadius = DesignBorder.radiusLG
        
        // Subtle shadow
        let shadow = DesignShadow.shadow(for: .low)
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = shadow.offset
        layer.shadowRadius = shadow.radius
        layer.shadowOpacity = shadow.opacity
        
        addSubview(contentStackView)
        
        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: topAnchor, constant: DesignSpacing.lg),
            contentStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: DesignSpacing.lg),
            contentStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -DesignSpacing.lg),
            contentStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -DesignSpacing.lg)
        ])
    }
    
    func addArrangedSubview(_ view: UIView) {
        contentStackView.addArrangedSubview(view)
    }
}

