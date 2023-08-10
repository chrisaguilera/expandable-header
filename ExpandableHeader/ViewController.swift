//
//  ViewController.swift
//  ExpandableHeader
//
//  Created by Christopher Aguilera on 8/9/23.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private static let minHeaderHeight: CGFloat = 100
    private static let maxHeaderHeight: CGFloat = 250
    
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
            
            let contentOffset = scrollView.contentOffset.y
            
            var newHeaderHeight = self.headerHeightConstraint!.constant
            if contentOffset > 0 {
                newHeaderHeight = max(Self.minHeaderHeight, self.headerHeightConstraint!.constant - contentOffset)
            } else if contentOffset < 0 {
                newHeaderHeight = min(Self.maxHeaderHeight, self.headerHeightConstraint!.constant - contentOffset)
            }
            
            if newHeaderHeight != self.headerHeightConstraint!.constant {
                self.headerHeightConstraint!.constant = newHeaderHeight
                self.tableView1.contentOffset.y = 0
            }
        } else {
            
            let contentOffset = scrollView.contentOffset.y

            var newHeaderHeight = self.headerHeightConstraint!.constant
            if contentOffset > 0 {
                newHeaderHeight = max(Self.minHeaderHeight, self.headerHeightConstraint!.constant - contentOffset)
            } else if contentOffset < 0 {
                newHeaderHeight = min(Self.maxHeaderHeight, self.headerHeightConstraint!.constant - contentOffset)
            }

            if newHeaderHeight != self.headerHeightConstraint!.constant {
                self.headerHeightConstraint!.constant = newHeaderHeight
                self.tableView2.contentOffset.y = 0 
            }
        }
    }
    
    // MARK: Helpers
    
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

