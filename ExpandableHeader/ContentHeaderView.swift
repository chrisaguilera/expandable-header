//
//  ContentHeaderView.swift
//  ExpandableHeader
//
//  Created by Christopher Aguilera on 8/10/23.
//

import UIKit

class ContentHeaderView: UIView {
    private static let headerHeight: CGFloat = 220
    private static let tabBarHeight: CGFloat = 44
    
    static var minHeight: CGFloat {
        return tabBarHeight
    }
    
    static var preferredHeight: CGFloat {
        return headerHeight + tabBarHeight
    }
    
    private let backgroundImageView: UIImageView = {
        let view = UIImageView(image: UIImage(named: "polka_dots"))
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        return view
    }()
    
    private let tabBarView: UIView = {
        let view = UIView()
        view.backgroundColor = .brown
        return view
    }()
    
    private let visualEffectView: UIVisualEffectView = {
        return UIVisualEffectView()
    }()
    
    private let animator: UIViewPropertyAnimator
    var onTapTab: (() -> Void)?
    
    init() {
        self.animator = UIViewPropertyAnimator(duration: 1, curve: .linear)
        super.init(frame: .zero)
        
        self.addSubview(self.backgroundImageView)
        self.addSubview(self.visualEffectView)
        self.addSubview(self.tabBarView)
        
        self.backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.backgroundImageView.topAnchor.constraint(equalTo: self.topAnchor),
            self.backgroundImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.backgroundImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
        
        self.visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.visualEffectView.leadingAnchor.constraint(equalTo: self.backgroundImageView.leadingAnchor),
            self.visualEffectView.topAnchor.constraint(equalTo: self.backgroundImageView.topAnchor),
            self.visualEffectView.trailingAnchor.constraint(equalTo: self.backgroundImageView.trailingAnchor),
            self.visualEffectView.bottomAnchor.constraint(equalTo: self.backgroundImageView.bottomAnchor)
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
        
        self.animator.addAnimations {
            self.visualEffectView.effect = UIBlurEffect(style: .light)
        }
    }
    
    required init?(coder: NSCoder) {
        return nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let alpha = (self.bounds.height - Self.preferredHeight) / (364 - Self.preferredHeight)
        self.animator.fractionComplete = alpha
    }
    
    @objc private func handleTapTabBar() {
        self.onTapTab?()
    }
}
