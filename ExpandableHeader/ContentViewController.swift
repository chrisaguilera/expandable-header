//
//  ContentViewController.swift
//  ExpandableHeader
//
//  Created by Christopher Aguilera on 8/9/23.
//

import UIKit

class ContentViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    private static let phonyHeaderMinHeight: CGFloat = ContentHeaderView.minHeight
    private static let phonyHeaderMaxHeight: CGFloat = ContentHeaderView.preferredHeight
    
    private var minHeaderHeight: CGFloat = 0
    private var prevContentOffset1: CGFloat = 0
    private var prevContentOffset2: CGFloat = 0
    private var didDragCollectionView = false
    private var phonyHeaderHeightConstraint: NSLayoutConstraint?
    private var contentHeaderBottomConstraint: NSLayoutConstraint?
    
    private var currentScrollView: UIScrollView? {
        willSet {
            self.currentScrollView?.removeFromSuperview()
        }
        didSet {
            guard let currentScrollView else { return }
            self.setupScrollView(currentScrollView)
        }
    }
    
    // Defines the fixed position of the header view. Used for layout.
    private let phonyHeaderView: UIView = {
        return UIView()
    }()
    
    // References the actual header view. This view should contain the actual content to display.
    // Its leading, top and trailing anchors are fixed to the phony header view. Its height is fixed
    // to the height of the phony header view, plus some constant. In the case where the user drags
    // beyond top content (content offset is negative), the height of this view grows to fill the
    // empty space.
    private let contentHeaderView = {
        return ContentHeaderView()
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .white
        tableView.allowsSelection = false
        tableView.rowHeight = 80
        tableView.estimatedRowHeight = 80
        // Disable automatic adjustments of scroll indicator to remove additional inset added to
        // the top of the table view
        tableView.automaticallyAdjustsScrollIndicatorInsets = false
        tableView.sectionHeaderTopPadding = 0
        return tableView
    }()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 80, height: 80)
        layout.headerReferenceSize = CGSize(width: 0, height: 44)
        layout.sectionHeadersPinToVisibleBounds = true
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "Header")
        return collectionView
    }()
    
    private var phonyHeaderHeight: CGFloat {
        self.phonyHeaderHeightConstraint!.constant
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        self.contentHeaderView.onTapTab = { [weak self] in self?.handleTapTabBar() }
    }
    
    required init?(coder: NSCoder) {
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.overrideUserInterfaceStyle = .light
        self.title = "Content"
        
        self.navigationController?.navigationBar.barStyle = .default
        self.setNavBar(isTransparent: true)
        self.view.addSubview(self.phonyHeaderView)
        self.view.addSubview(self.contentHeaderView)
        
        // Note that phony header view accounts for top safe area
        self.phonyHeaderView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.phonyHeaderView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.phonyHeaderView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.phonyHeaderView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
        ])
        self.phonyHeaderHeightConstraint = self.phonyHeaderView.heightAnchor.constraint(equalToConstant: Self.phonyHeaderMaxHeight)
        self.phonyHeaderHeightConstraint?.isActive = true
        
        // Note that content header view may extend beyond the top safe area
        self.contentHeaderView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.contentHeaderView.leadingAnchor.constraint(equalTo: self.phonyHeaderView.leadingAnchor),
            self.contentHeaderView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.contentHeaderView.trailingAnchor.constraint(equalTo: self.phonyHeaderView.trailingAnchor)
        ])
        self.contentHeaderBottomConstraint = self.contentHeaderView.bottomAnchor.constraint(equalTo: self.phonyHeaderView.bottomAnchor)
        self.contentHeaderBottomConstraint?.isActive = true
        
        self.currentScrollView = self.tableView
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    // MARK: UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 40
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.contentView.backgroundColor = .cyan
        
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        
        let label = UILabel()
        label.textColor = .black
        label.text = String(indexPath.row)
        cell.contentView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerXAnchor.constraint(equalTo: cell.contentView.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor).isActive = true
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }
    
    // MARK: UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 60
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        cell.contentView.backgroundColor = .green
        
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        
        let label = UILabel()
        label.textColor = .black
        label.text = String(indexPath.row)
        cell.contentView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerXAnchor.constraint(equalTo: cell.contentView.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor).isActive = true
        
        return cell
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "Header", for: indexPath)
        header.backgroundColor = .blue
        return header
    }
    
    // MARK: UIScrollViewDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.tableView {
            if let newContentOffset = self.handleScrollViewDidScroll(scrollView, prevContentOffset: self.prevContentOffset1) {
                self.prevContentOffset1 = newContentOffset
            }
        } else if self.didDragCollectionView {
            if let newContentOffset = self.handleScrollViewDidScroll(scrollView, prevContentOffset: self.prevContentOffset2) {
                self.prevContentOffset2 = newContentOffset
            }
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        // Flag is required to fix an issue caused by scrollViewDidScroll being unexpectedly invoked
        // when collectionView is first added to the view hierarchy. Ignore scroll event handling for
        // collectionView until the user initiates scroll.
        if scrollView == self.collectionView {
            self.didDragCollectionView = true
        }
    }
    
    // MARK: Helpers
    
    private func handleScrollViewDidScroll(_ scrollView: UIScrollView, prevContentOffset: CGFloat) -> CGFloat? {
        
        defer {
            
            // Stretch content header view beyond preferred height
            if scrollView.contentOffset.y < 0 && self.phonyHeaderHeight == Self.phonyHeaderMaxHeight {
                self.contentHeaderBottomConstraint?.constant = abs(scrollView.contentOffset.y)
                scrollView.verticalScrollIndicatorInsets.top = abs(scrollView.contentOffset.y)
            } else {
                self.contentHeaderBottomConstraint?.constant = 0
                scrollView.verticalScrollIndicatorInsets.top = 0
            }
            
            // Update nav bar appearance
            if self.phonyHeaderHeight == Self.phonyHeaderMinHeight {
                self.setNavBar(isTransparent: false)
            } else {
                self.setNavBar(isTransparent: true)
            }
        }
        
        let offsetDiff = scrollView.contentOffset.y - prevContentOffset
        
        // If scrolling up and header is not collapsed, collapse the header only
        if offsetDiff > 0 && self.phonyHeaderHeight > Self.phonyHeaderMinHeight {
            self.phonyHeaderHeightConstraint!.constant = max(Self.phonyHeaderMinHeight, self.phonyHeaderHeightConstraint!.constant - offsetDiff)
            scrollView.contentOffset.y = prevContentOffset
            return nil
            
        }
        
        // If scrolling down and scroll view is at top of content, expand header only
        if offsetDiff < 0 && scrollView.contentOffset.y < 0 {
            self.phonyHeaderHeightConstraint!.constant = min(Self.phonyHeaderMaxHeight, self.phonyHeaderHeightConstraint!.constant - offsetDiff)
            return nil
        }
        
        return scrollView.contentOffset.y
    }
    
    private func handleTapTabBar() {
        if let currentScrollView, currentScrollView == self.tableView {
            self.currentScrollView = self.collectionView
        } else {
            self.currentScrollView = self.tableView
        }
    }
    
    private func setupScrollView(_ scrollView: UIScrollView) {
        self.view.insertSubview(scrollView, belowSubview: self.contentHeaderView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            scrollView.topAnchor.constraint(equalTo: self.phonyHeaderView.bottomAnchor),
            scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
    }
    
    private func setNavBar(isTransparent: Bool) {
        if isTransparent {
            let appearance = UINavigationBarAppearance()
            // TODO: Should we use configureWithTransparentBackground()
            appearance.configureWithOpaqueBackground()
            appearance.shadowColor = .clear
            appearance.backgroundColor = .clear
            appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            self.navigationController?.navigationBar.standardAppearance = appearance
            self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
            self.navigationController?.navigationBar.tintColor = .white
        } else {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.shadowColor = .lightGray
            appearance.backgroundColor = .white
            appearance.titleTextAttributes = [.foregroundColor: UIColor.black]
            self.navigationController?.navigationBar.standardAppearance = appearance
            self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
            self.navigationController?.navigationBar.tintColor = .black
        }
    }
}

