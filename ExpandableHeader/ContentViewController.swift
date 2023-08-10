//
//  ContentViewController.swift
//  ExpandableHeader
//
//  Created by Christopher Aguilera on 8/9/23.
//

import UIKit

class ContentViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private static let headerHeight: CGFloat = 220
    private static let tabBarHeight: CGFloat = 44
    
    private let headerView: UIView = {
        let view = UIView()
        view.backgroundColor = .brown
        return view
    }()
    
    private let tabBarView: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        return view
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
    
    private var minHeaderHeight: CGFloat = 0
    private var prevContentOffset1: CGFloat = 0
    private var prevContentOffset2: CGFloat = 0
    private var headerHeightConstraint: NSLayoutConstraint?
    private var currentTableView: UITableView? {
        willSet {
            self.currentTableView?.removeFromSuperview()
        }
        didSet {
            guard let currentTableView else { return }
            self.setupTableView(currentTableView)
        }
    }
    
    private var headerHeight: CGFloat {
        self.headerHeightConstraint!.constant
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        self.tableView1.delegate = self
        self.tableView1.dataSource = self
        self.tableView1.rowHeight = 80
        self.tableView1.estimatedRowHeight = 80
        
        self.tableView2.delegate = self
        self.tableView2.dataSource = self
        self.tableView2.rowHeight = 80
        self.tableView2.estimatedRowHeight = 80
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleTapTabBar))
        self.tabBarView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    required init?(coder: NSCoder) {
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Content"
        
        self.view.addSubview(self.headerView)
        self.view.addSubview(self.tabBarView)
        
        let layoutGuide = self.view.safeAreaLayoutGuide
        
        self.headerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.headerView.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor),
            self.headerView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.headerView.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor),
        ])
        self.headerHeightConstraint = self.headerView.heightAnchor.constraint(equalToConstant: Self.headerHeight)
        self.headerHeightConstraint?.isActive = true
        
        self.tabBarView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.tabBarView.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor),
            self.tabBarView.topAnchor.constraint(equalTo: self.headerView.bottomAnchor),
            self.tabBarView.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor),
            self.tabBarView.heightAnchor.constraint(equalToConstant: Self.tabBarHeight)
        ])
        
        self.currentTableView = self.tableView1
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.minHeaderHeight = self.view.safeAreaInsets.top
    }
    
    // MARK: UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 40
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        if tableView === self.tableView1 {
            cell.contentView.backgroundColor = .yellow
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
        print(scrollView.contentOffset.y)
        
        if scrollView == self.tableView1 {
            if let newContentOffset = self.handleScrollViewDidScroll(scrollView, prevContentOffset: self.prevContentOffset1) {
                self.prevContentOffset1 = newContentOffset
            }
        } else {
            if let newContentOffset = self.handleScrollViewDidScroll(scrollView, prevContentOffset: self.prevContentOffset2) {
                self.prevContentOffset2 = newContentOffset
            }
        }
    }
    
    // MARK: Helpers
    
    private func handleScrollViewDidScroll(_ scrollView: UIScrollView, prevContentOffset: CGFloat) -> CGFloat? {
        let offsetDiff = scrollView.contentOffset.y - prevContentOffset
        
        // If scrolling up and header is not collapsed, collapse the header only
        if offsetDiff > 0 && self.headerHeight > self.minHeaderHeight {
            self.headerHeightConstraint!.constant = max(self.minHeaderHeight, self.headerHeightConstraint!.constant - offsetDiff)
            scrollView.contentOffset.y = prevContentOffset
            return nil
            
        }
        
        // If scrolling down and scroll view is at top of content, expand header only
        if offsetDiff < 0 && scrollView.contentOffset.y < 0 {
            self.headerHeightConstraint!.constant = min(Self.headerHeight, self.headerHeightConstraint!.constant - offsetDiff)
            return nil
        }
        
        return scrollView.contentOffset.y
    }
    
    @objc private func handleTapTabBar() {
        if let currentTableView, currentTableView == self.tableView1 {
            self.currentTableView = self.tableView2
        } else {
            self.currentTableView = self.tableView1
        }
    }
    
    private func setupTableView(_ tableView: UITableView) {
        self.view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            tableView.topAnchor.constraint(equalTo: self.tabBarView.bottomAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
    }
}

