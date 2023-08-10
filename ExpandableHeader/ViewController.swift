//
//  ViewController.swift
//  ExpandableHeader
//
//  Created by Christopher Aguilera on 8/9/23.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let action = UIAction(title: "Push Content") { [weak self] _ in
            self?.navigationController?.pushViewController(ContentViewController(), animated: true)
        }
        let button = UIButton(configuration: .filled(), primaryAction: action)
        
        self.view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        button.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
    }
}
