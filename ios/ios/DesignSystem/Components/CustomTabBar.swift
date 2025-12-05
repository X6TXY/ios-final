//
//  CustomTabBar.swift
//  ios
//
//  Custom Tab Bar Component with Blur Effect
//

import UIKit

struct TabBarItem {
    let title: String
    let iconName: String
    let selectedIconName: String?
    let isCenterItem: Bool
    var badgeCount: Int = 0
    
    static let home = TabBarItem(
        title: "Home",
        iconName: "house.fill",
        selectedIconName: nil,
        isCenterItem: false
    )
    
    static let search = TabBarItem(
        title: "Search",
        iconName: "magnifyingglass",
        selectedIconName: nil,
        isCenterItem: false
    )
    
    static let discover = TabBarItem(
        title: "Discover",
        iconName: "rectangle.stack.fill",
        selectedIconName: nil,
        isCenterItem: true
    )
    
    static let friends = TabBarItem(
        title: "Friends",
        iconName: "person.2.fill",
        selectedIconName: nil,
        isCenterItem: false
    )
    
    static let profile = TabBarItem(
        title: "Profile",
        iconName: "person.circle.fill",
        selectedIconName: nil,
        isCenterItem: false
    )
}

protocol CustomTabBarDelegate: AnyObject {
    func tabBar(_ tabBar: CustomTabBar, didSelectItemAt index: Int)
}

class CustomTabBar: UIView {
    
    weak var delegate: CustomTabBarDelegate?
    
    private var items: [TabBarItem] = []
    private var buttons: [UIButton] = []
    private var labels: [UILabel] = []
    private var badgeViews: [UIView] = []
    
    private(set) var selectedIndex: Int = 0 {
        didSet {
            updateSelection()
        }
    }
    
    private let blurView: UIVisualEffectView = {
        let blur = UIBlurEffect(style: .dark)
        let view = UIVisualEffectView(effect: blur)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let separatorLine: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        return view
    }()
    
    private let containerStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        stack.alignment = .center
        stack.spacing = 0
        return stack
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
        backgroundColor = UIColor(hex: "#1C1C1E")
        
        addSubview(blurView)
        addSubview(separatorLine)
        addSubview(containerStackView)
        
        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: topAnchor),
            blurView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            separatorLine.topAnchor.constraint(equalTo: topAnchor),
            separatorLine.leadingAnchor.constraint(equalTo: leadingAnchor),
            separatorLine.trailingAnchor.constraint(equalTo: trailingAnchor),
            separatorLine.heightAnchor.constraint(equalToConstant: 0.5),
            
            containerStackView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            containerStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            containerStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            containerStackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -8)
        ])
    }
    
    func configure(with items: [TabBarItem]) {
        self.items = items
        buttons.removeAll()
        labels.removeAll()
        badgeViews.removeAll()
        containerStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for (index, item) in items.enumerated() {
            let itemContainer = createTabItem(for: item, at: index)
            containerStackView.addArrangedSubview(itemContainer)
        }
        
        updateSelection()
    }
    
    private func createTabItem(for item: TabBarItem, at index: Int) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tag = index
        
        let iconSize: CGFloat = item.isCenterItem ? 28 : 24
        let config = UIImage.SymbolConfiguration(pointSize: iconSize, weight: .medium)
        let image = UIImage(systemName: item.iconName, withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = UIColor(hex: "#8E8E93")
        button.addTarget(self, action: #selector(tabItemTapped(_:)), for: .touchUpInside)
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = item.title
        label.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        label.textColor = UIColor(hex: "#8E8E93")
        label.textAlignment = .center
        
        container.addSubview(button)
        container.addSubview(label)
        
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: container.topAnchor),
            button.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            button.widthAnchor.constraint(equalToConstant: iconSize + 16),
            button.heightAnchor.constraint(equalToConstant: iconSize + 16),
            
            label.topAnchor.constraint(equalTo: button.bottomAnchor, constant: 4),
            label.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        
        // Badge view
        if item.badgeCount > 0 {
            let badge = createBadge(count: item.badgeCount)
            container.addSubview(badge)
            badgeViews.append(badge)
            
            NSLayoutConstraint.activate([
                badge.topAnchor.constraint(equalTo: button.topAnchor, constant: -4),
                badge.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: 4),
                badge.widthAnchor.constraint(greaterThanOrEqualToConstant: 18),
                badge.heightAnchor.constraint(equalToConstant: 18)
            ])
        } else {
            badgeViews.append(UIView()) // Placeholder
        }
        
        buttons.append(button)
        labels.append(label)
        
        // Center item should be larger
        if item.isCenterItem {
            NSLayoutConstraint.activate([
                container.widthAnchor.constraint(equalToConstant: 80)
            ])
        }
        
        return container
    }
    
    private func createBadge(count: Int) -> UIView {
        let badge = UIView()
        badge.translatesAutoresizingMaskIntoConstraints = false
        badge.backgroundColor = UIColor(hex: "#E50914")
        badge.layer.cornerRadius = 9
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = count > 99 ? "99+" : "\(count)"
        label.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        
        badge.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: badge.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: badge.centerYAnchor),
            label.leadingAnchor.constraint(greaterThanOrEqualTo: badge.leadingAnchor, constant: 4),
            label.trailingAnchor.constraint(lessThanOrEqualTo: badge.trailingAnchor, constant: -4)
        ])
        
        return badge
    }
    
    @objc private func tabItemTapped(_ sender: UIButton) {
        let index = sender.tag
        
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        // Animation
        if items[index].isCenterItem {
            animateCenterItem(sender)
        } else {
            animateItem(sender)
        }
        
        selectedIndex = index
        delegate?.tabBar(self, didSelectItemAt: index)
    }
    
    private func animateItem(_ button: UIButton) {
        UIView.animate(withDuration: 0.15, animations: {
            button.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        }) { _ in
            UIView.animate(withDuration: 0.15) {
                button.transform = .identity
            }
        }
    }
    
    private func animateCenterItem(_ button: UIButton) {
        UIView.animate(withDuration: 0.15, animations: {
            button.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        }) { _ in
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: [], animations: {
                button.transform = .identity
            })
        }
    }
    
    private func updateSelection() {
        for (index, button) in buttons.enumerated() {
            let isSelected = index == selectedIndex
            let color = isSelected ? UIColor(hex: "#E50914") : UIColor(hex: "#8E8E93")
            
            UIView.animate(withDuration: 0.2) {
                button.tintColor = color
                self.labels[index].textColor = color
            }
        }
    }
    
    func setSelectedIndex(_ index: Int, animated: Bool = true) {
        guard index >= 0 && index < items.count else { return }
        selectedIndex = index
    }
    
    func updateBadge(count: Int, at index: Int) {
        guard index >= 0 && index < items.count else { return }
        
        items[index].badgeCount = count
        
        // Remove existing badge
        if index < badgeViews.count && badgeViews[index].superview != nil {
            badgeViews[index].removeFromSuperview()
        }
        
        // Add new badge if count > 0
        if count > 0 {
            let container = containerStackView.arrangedSubviews[index]
            let badge = createBadge(count: count)
            container.addSubview(badge)
            
            let button = buttons[index]
            badge.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                badge.topAnchor.constraint(equalTo: button.topAnchor, constant: -4),
                badge.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: 4),
                badge.widthAnchor.constraint(greaterThanOrEqualToConstant: 18),
                badge.heightAnchor.constraint(equalToConstant: 18)
            ])
            
            if index < badgeViews.count {
                badgeViews[index] = badge
            } else {
                badgeViews.append(badge)
            }
        }
    }
}

// MARK: - UIColor Extension for Hex

extension UIColor {
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}

