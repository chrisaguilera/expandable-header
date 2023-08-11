//
//  ContentHeaderView.swift
//  ExpandableHeader
//
//  Created by Christopher Aguilera on 8/10/23.
//

import UIKit

class ContentHeaderView: UIView {
    
    // Constants should not take safe area into consideration
    private static let contentHeight: CGFloat = 60
    private static let tabBarHeight: CGFloat = 44
    
    // Height at which blur effect begins taking effect
    private static let blurEffectThresholdHeight: CGFloat = preferredHeight
    // Height at which blur effect reaches full effect
    private static let blurEffectFullHeight: CGFloat = preferredHeight + 100
    // Height at which opacity effect begins taking effect
    private static let opacityEffectThresholdHeight: CGFloat = minHeight + 30
    // Height at which opacity effect reaches full effect
    private static let opacityEffectFullHeight: CGFloat = minHeight
    
    static let minHeight: CGFloat = tabBarHeight
    static let preferredHeight: CGFloat = tabBarHeight + contentHeight
    
    private let backgroundImageView: UIImageView = {
        let view = UIImageView(image: UIImage(named: "polka_dots"))
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        return view
    }()
    
    private let blurView: UIVisualEffectView = {
        let effect = UIBlurEffect(style: .light)
        return UIVisualEffectView(effect: effect)
    }()
    
    private let opacityView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.alpha = 0
        return view
    }()
    
    private let contentContainerView: UIView = {
        return UIView()
    }()
    
    private lazy var button: UIButton = {
        let action = UIAction(title: "Button") { _ in print(#function) }
        return UIButton(configuration: .filled(), primaryAction: action)
    }()
    
    private let tabBarView: UIView = {
        let view = UIView()
        view.backgroundColor = .brown
        return view
    }()
    
    var onTapTab: (() -> Void)?
    
    init() {
        super.init(frame: .zero)
        
        self.contentContainerView.addSubview(self.button)
        self.addSubview(self.backgroundImageView)
        self.addSubview(self.blurView)
        self.addSubview(self.opacityView)
        self.addSubview(self.contentContainerView)
        self.addSubview(self.tabBarView)
        
        self.button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.button.centerXAnchor.constraint(equalTo: self.contentContainerView.centerXAnchor),
            self.button.centerYAnchor.constraint(equalTo: self.contentContainerView.centerYAnchor)
        ])
        
        self.backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.backgroundImageView.topAnchor.constraint(equalTo: self.topAnchor),
            self.backgroundImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.backgroundImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
        
        self.blurView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.blurView.leadingAnchor.constraint(equalTo: self.backgroundImageView.leadingAnchor),
            self.blurView.topAnchor.constraint(equalTo: self.backgroundImageView.topAnchor),
            self.blurView.trailingAnchor.constraint(equalTo: self.backgroundImageView.trailingAnchor),
            self.blurView.bottomAnchor.constraint(equalTo: self.backgroundImageView.bottomAnchor)
        ])
        
        self.opacityView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.opacityView.leadingAnchor.constraint(equalTo: self.backgroundImageView.leadingAnchor),
            self.opacityView.topAnchor.constraint(equalTo: self.backgroundImageView.topAnchor),
            self.opacityView.trailingAnchor.constraint(equalTo: self.backgroundImageView.trailingAnchor),
            self.opacityView.bottomAnchor.constraint(equalTo: self.backgroundImageView.bottomAnchor)
        ])
        
        self.contentContainerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.contentContainerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.contentContainerView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
            self.contentContainerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.contentContainerView.bottomAnchor.constraint(equalTo: self.backgroundImageView.bottomAnchor)
        ])
        
        self.tabBarView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.tabBarView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.tabBarView.topAnchor.constraint(equalTo: self.backgroundImageView.bottomAnchor),
            self.tabBarView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.tabBarView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            self.tabBarView.heightAnchor.constraint(equalToConstant: Self.tabBarHeight)
        ])
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleTapTabBar))
        self.tabBarView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    required init?(coder: NSCoder) {
        return nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let height = self.bounds.height - self.safeAreaInsets.top
        
        // Apply blur effect if height is within defined range
        let blurFraction = (height - Self.blurEffectThresholdHeight) / (Self.blurEffectFullHeight - Self.blurEffectThresholdHeight)
        self.blurView.alpha = min(max(blurFraction, 0), 1)
        
        // Apply opacity effect if height is within defined range
        let opacityFraction = 1 - (height - Self.opacityEffectFullHeight) / (Self.opacityEffectThresholdHeight - Self.opacityEffectFullHeight)
        self.opacityView.alpha = min(max(opacityFraction, 0), 1)
        
        // Hide content if height is smaller than preferred height
        self.contentContainerView.isHidden = height < Self.preferredHeight - 20
    }
    
    @objc private func handleTapTabBar() {
        self.onTapTab?()
    }
}
