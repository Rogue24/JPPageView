//
//  TableViewController.swift
//  JPPageView_Example
//
//  Created by 周健平 on 2018/7/26.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit

private let kCellID = "kCellID"

class TableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Example"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: kCellID)
        
//        let a = JPPageView()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kCellID, for: indexPath)
        cell.textLabel?.text = indexPath.row == 0 ? "PageView" : "PageCollectionView"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = ViewController()
        vc.isPageView = indexPath.row == 0
        navigationController?.pushViewController(vc, animated: true)
    }

}
