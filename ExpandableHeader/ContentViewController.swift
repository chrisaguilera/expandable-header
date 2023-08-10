//
//  ContentViewController.swift
//  ExpandableHeader
//
//  Created by Christopher Aguilera on 8/9/23.
//

import UIKit

class ContentViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
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
    
    private var headerHeight: CGFloat {
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
        
        self.view.addSubview(self.phonyHeaderView)
        self.view.addSubview(self.contentHeaderView)
        
        self.phonyHeaderView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.phonyHeaderView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.phonyHeaderView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.phonyHeaderView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
        ])
        self.phonyHeaderHeightConstraint = self.phonyHeaderView.heightAnchor.constraint(equalToConstant: ContentHeaderView.preferredHeight)
        self.phonyHeaderHeightConstraint?.isActive = true
        
        self.contentHeaderView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.contentHeaderView.leadingAnchor.constraint(equalTo: self.phonyHeaderView.leadingAnchor),
            self.contentHeaderView.topAnchor.constraint(equalTo: self.phonyHeaderView.topAnchor),
            self.contentHeaderView.trailingAnchor.constraint(equalTo: self.phonyHeaderView.trailingAnchor)
        ])
        self.contentHeaderHeightConstraint = self.contentHeaderView.heightAnchor.constraint(equalTo: self.phonyHeaderView.heightAnchor)
        self.contentHeaderHeightConstraint?.isActive = true
        
        self.currentTableView = self.tableView1
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.minHeaderHeight = self.view.safeAreaInsets.top + ContentHeaderView.minHeight
    }
    
    // MARK: UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 40
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        if tableView === self.tableView1 {
            cell.contentView.backgroundColor = .green
        } else {
            cell.contentView.backgroundColor = .cyan
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
        let offsetDiff = scrollView.contentOffset.y - prevContentOffset
        
        if scrollView.contentOffset.y < 0 && self.headerHeight == ContentHeaderView.preferredHeight {
            self.contentHeaderHeightConstraint?.constant = abs(scrollView.contentOffset.y)
            scrollView.verticalScrollIndicatorInsets.top = abs(scrollView.contentOffset.y)
        } else {
            self.contentHeaderHeightConstraint?.constant = 0
            scrollView.verticalScrollIndicatorInsets.top = 0
        }
        
        // If scrolling up and header is not collapsed, collapse the header only
        if offsetDiff > 0 && self.headerHeight > self.minHeaderHeight {
            self.phonyHeaderHeightConstraint!.constant = max(self.minHeaderHeight, self.phonyHeaderHeightConstraint!.constant - offsetDiff)
            scrollView.contentOffset.y = prevContentOffset
            return nil
            
        }
        
        // If scrolling down and scroll view is at top of content, expand header only
        if offsetDiff < 0 && scrollView.contentOffset.y < 0 {
            self.phonyHeaderHeightConstraint!.constant = min(ContentHeaderView.preferredHeight, self.phonyHeaderHeightConstraint!.constant - offsetDiff)
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
}

