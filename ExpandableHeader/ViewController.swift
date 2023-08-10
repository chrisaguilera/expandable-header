//
//  ViewController.swift
//  ExpandableHeader
//
//  Created by Christopher Aguilera on 8/9/23.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private static let minHeaderHeight: CGFloat = 80
    private static let maxHeaderHeight: CGFloat = 320
    
    private let headerView: UIView = {
        let view = UIView()
        view.backgroundColor = .brown
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
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleTapHeader))
        self.headerView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(self.headerView)
        
        self.headerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.headerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.headerView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.headerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
        ])
        self.headerHeightConstraint = self.headerView.heightAnchor.constraint(equalToConstant: Self.maxHeaderHeight)
        self.headerHeightConstraint?.isActive = true
        
        self.currentTableView = self.tableView1
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
        if offsetDiff > 0 && self.headerHeight > Self.minHeaderHeight {
            self.headerHeightConstraint!.constant = max(Self.minHeaderHeight, self.headerHeightConstraint!.constant - offsetDiff)
            scrollView.contentOffset.y = prevContentOffset
            return nil
            
        }
        
        // If scrolling down and scroll view is at top of content, expand header only
        if offsetDiff < 0 && scrollView.contentOffset.y < 0 {
            self.headerHeightConstraint!.constant = min(Self.maxHeaderHeight, self.headerHeightConstraint!.constant - offsetDiff)
            return nil
        }
        
        return scrollView.contentOffset.y
    }
    
    @objc private func handleTapHeader() {
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
            tableView.topAnchor.constraint(equalTo: self.headerView.bottomAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
    }
}

