//
//  ContentViewController.swift
//  ExpandableHeader
//
//  Created by Christopher Aguilera on 8/9/23.
//

import UIKit

class ContentViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private static let phonyHeaderMinHeight: CGFloat = ContentHeaderView.minHeight
    private static let phonyHeaderMaxHeight: CGFloat = ContentHeaderView.preferredHeight
    
    private var minHeaderHeight: CGFloat = 0
    private var prevContentOffset1: CGFloat = 0
    private var prevContentOffset2: CGFloat = 0
    private var didDragTableView2 = false
    private var phonyHeaderHeightConstraint: NSLayoutConstraint?
    private var contentHeaderHeightConstraint: NSLayoutConstraint?
    private var currentTableView: UITableView? {
        willSet {
            self.currentTableView?.removeFromSuperview()
        }
        didSet {
            guard let currentTableView else { return }
            self.setupTableView(currentTableView)
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
    
    private let tableView1: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .white
        tableView.allowsSelection = false
        return tableView
    }()
    
    private let tableView2: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .white
        tableView.allowsSelection = false
        return tableView
    }()
    
    private var phonyHeaderHeight: CGFloat {
        self.phonyHeaderHeightConstraint!.constant
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        self.tableView1.delegate = self
        self.tableView1.dataSource = self
        self.tableView1.rowHeight = 80
        self.tableView1.estimatedRowHeight = 80
        // Disable automatic adjustments of scroll indicator to remove additional inset added to
        // the top of the table view
        self.tableView1.automaticallyAdjustsScrollIndicatorInsets = false
        
        self.tableView2.delegate = self
        self.tableView2.dataSource = self
        self.tableView2.rowHeight = 80
        self.tableView2.estimatedRowHeight = 80
        // Disable automatic adjustments of scroll indicator to remove additional inset added to
        // the top of the table view
        self.tableView2.automaticallyAdjustsScrollIndicatorInsets = false
        
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
        self.contentHeaderHeightConstraint = self.contentHeaderView.bottomAnchor.constraint(equalTo: self.phonyHeaderView.bottomAnchor)
        self.contentHeaderHeightConstraint?.isActive = true
        
        self.currentTableView = self.tableView1
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
        if tableView === self.tableView1 {
            cell.contentView.backgroundColor = .cyan
        } else {
            cell.contentView.backgroundColor = .green
        }
        
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
    
    // MARK: UITableViewDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.tableView1 {
            if let newContentOffset = self.handleScrollViewDidScroll(scrollView, prevContentOffset: self.prevContentOffset1) {
                self.prevContentOffset1 = newContentOffset
            }
        } else if self.didDragTableView2 {
            if let newContentOffset = self.handleScrollViewDidScroll(scrollView, prevContentOffset: self.prevContentOffset2) {
                self.prevContentOffset2 = newContentOffset
            }
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        // Flag is required to fix an issue caused by scrollViewDidScroll being unexpectedly invoked
        // when tableView2 is first added to the view hierarchy. Ignore scroll event handling for tableView2
        // until the user initiates scroll.
        if scrollView == self.tableView2 {
            self.didDragTableView2 = true
        }
    }
    
    // MARK: Helpers
    
    private func handleScrollViewDidScroll(_ scrollView: UIScrollView, prevContentOffset: CGFloat) -> CGFloat? {
        
        defer {
            
            // Stretch content header view beyond preferred height
            if scrollView.contentOffset.y < 0 && self.phonyHeaderHeight == Self.phonyHeaderMaxHeight {
                self.contentHeaderHeightConstraint?.constant = abs(scrollView.contentOffset.y)
                scrollView.verticalScrollIndicatorInsets.top = abs(scrollView.contentOffset.y)
            } else {
                self.contentHeaderHeightConstraint?.constant = 0
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
        if let currentTableView, currentTableView == self.tableView1 {
            self.currentTableView = self.tableView2
        } else {
            self.currentTableView = self.tableView1
        }
    }
    
    private func setupTableView(_ tableView: UITableView) {
        self.view.insertSubview(tableView, belowSubview: self.contentHeaderView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            tableView.topAnchor.constraint(equalTo: self.phonyHeaderView.bottomAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
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

