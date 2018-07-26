//
//  TableViewController.swift
//  JPPageView_Example
//
//  Created by 周健平 on 2018/7/26.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit

private let kCellID = "kCellID"

enum JPVCType {
    case pageView
    case pageCollectionView
}

class TableViewController: UITableViewController {

    fileprivate var vcTitles : [JPVCType] = [.pageView, .pageCollectionView]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Example"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: kCellID)
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
        return vcTitles.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kCellID, for: indexPath)
        let vcType = vcTitles[indexPath.row]
        cell.textLabel?.text = vcType == .pageView ? "PageView" : "PageCollectionView"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = ViewController()
        vc.vcType = vcTitles[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }

}
