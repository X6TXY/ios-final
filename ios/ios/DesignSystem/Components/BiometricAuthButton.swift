//
//  BiometricAuthButton.swift
//  ios
//
//  Biometric Authentication Button
//

import UIKit
import LocalAuthentication

class BiometricAuthButton: UIButton {
    
    private let context = LAContext()
    private var biometricType: LABiometryType {
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return .none
        }
        return context.biometryType
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        let iconConfig = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        var buttonConfig = UIButton.Configuration.plain()
        
        buttonConfig.baseBackgroundColor = DesignColors.backgroundSecondary
        buttonConfig.baseForegroundColor = DesignColors.primary
        buttonConfig.contentInsets = NSDirectionalEdgeInsets(
            top: DesignSpacing.base,
            leading: DesignSpacing.base,
            bottom: DesignSpacing.base,
            trailing: DesignSpacing.base
        )
        buttonConfig.imagePadding = DesignSpacing.sm
        buttonConfig.imagePlacement = .leading
        
        switch biometricType {
        case .faceID:
            buttonConfig.image = UIImage(systemName: "faceid", withConfiguration: iconConfig)
            buttonConfig.title = "Sign in with Face ID"
        case .touchID:
            buttonConfig.image = UIImage(systemName: "touchid", withConfiguration: iconConfig)
            buttonConfig.title = "Sign in with Touch ID"
        default:
            isHidden = true
            return
        }
        
        buttonConfig.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = DesignTypography.body
            return outgoing
        }
        
        configuration = buttonConfig
        
        // Set border and corner radius on layer
        layer.cornerRadius = DesignBorder.radiusMD
        layer.borderWidth = DesignBorder.widthThin
        layer.borderColor = DesignColors.borderSecondary.cgColor
    }
}

// MARK: - Biometric Authentication Helper

class BiometricAuthManager {
    static let shared = BiometricAuthManager()
    
    private let context = LAContext()
    
    private init() {}
    
    var isAvailable: Bool {
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }
    
    var biometricType: LABiometryType {
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return .none
        }
        return context.biometryType
    }
    
    func authenticate(reason: String = "Authenticate to sign in") async throws -> Bool {
        let context = LAContext()
        context.localizedCancelTitle = "Cancel"
        
        return try await context.evaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            localizedReason: reason
        )
    }
}
