//
//  ContentHeaderView.swift
//  ExpandableHeader
//
//  Created by Christopher Aguilera on 8/10/23.
//

import UIKit

class ContentHeaderView: UIView {
    private static let headerHeight: CGFloat = 100
    private static let tabBarHeight: CGFloat = 44
    
    static let minHeight: CGFloat = tabBarHeight
    static let preferredHeight: CGFloat = headerHeight + tabBarHeight
    
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
    
    private let overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.alpha = 0
        return view
    }()
    
    private let tabBarView: UIView = {
        let view = UIView()
        view.backgroundColor = .brown
        return view
    }()
    
    var onTapTab: (() -> Void)?
    
    init() {
        super.init(frame: .zero)
        
        self.addSubview(self.backgroundImageView)
        self.addSubview(self.blurView)
        self.addSubview(self.overlayView)
        self.addSubview(self.tabBarView)
        
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
        
        self.overlayView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.overlayView.leadingAnchor.constraint(equalTo: self.backgroundImageView.leadingAnchor),
            self.overlayView.topAnchor.constraint(equalTo: self.backgroundImageView.topAnchor),
            self.overlayView.trailingAnchor.constraint(equalTo: self.backgroundImageView.trailingAnchor),
            self.overlayView.bottomAnchor.constraint(equalTo: self.backgroundImageView.bottomAnchor)
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
        
        // Account for additonal top inset since header may extend beyond the safe area
        let minHeight = self.safeAreaInsets.top + Self.minHeight
        let preferredHeight = self.safeAreaInsets.top + Self.preferredHeight
        
        // TODO: Define the significance of 364
        let blurFraction = (self.bounds.height - preferredHeight) / (364 - preferredHeight)
        self.blurView.alpha = min(max(blurFraction, 0), 1)
        
        // TODO: Define the significance of 50
        let overlayFraction = (preferredHeight - 50 - self.bounds.height) / (preferredHeight - 50 - minHeight)
        self.overlayView.alpha = min(max(overlayFraction, 0), 1)
    }
    
    @objc private func handleTapTabBar() {
        self.onTapTab?()
    }
}
