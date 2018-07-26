//
//  ViewController.swift
//  JPPageView
//
//  Created by Rogue24 on 07/26/2018.
//  Copyright (c) 2018 Rogue24. All rights reserved.
//

import UIKit
import JPPageView

private let kCollectionViewCellID = "kCollectionViewCellID"

class ViewController: UIViewController {
    
    var isPageView : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.jp_randomColor()
        
        if #available(iOS 11.0, *) {
            
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        
        if isPageView {
            title = "PageView"
            setupPageView()
        } else {
            title = "PageCollectionView"
            setupPageCollectionView()
        }
    }
    
    private func setupPageView() {
        // 0.frame
        let pageFrame = CGRect(x: 0, y: 64, width: view.bounds.width, height: view.bounds.height - 64)

        // 1.标题
        let titles = ["推荐", "热门", "游戏", "娱乐", "美女",
                      "超爽推荐", "超爽热门", "超爽游戏", "超爽娱乐", "超爽美女",
                      "劲爆无敌推荐", "劲爆无敌热门", "劲爆无敌游戏", "劲爆无敌娱乐", "劲爆无敌美女"]

        // 2.子控制器
        // Swift中的【...】 <-小于等于-> OC中的【<=】
        // Swift中的【..<】 <-小于-> OC中的【<】
        var childVCs = [UIViewController]()
        // for i in 0 ..< titles.count 这里的【i】如果没有用到，则使用【_】代替，这样就不用再分配额外的内存空间
        for _ in 0 ..< titles.count {
            let vc = UIViewController()
            // Swift中不同类型之间不能进行计算
            // 例如Int/Double/CGFloat之间不能直接计算
            // 需要进行类型转换，例如转成CGFloat：CGFloat(xxx)
            vc.view.backgroundColor = UIColor.jp_randomColor()
            childVCs.append(vc)
        }

        // 3.样式
        var style = JPPageStyle()
        style.isScrollEnable = true
        style.isNeedTitleScale = true
        style.isShowCoverView = true
        style.isShowBottomLine = false

        let pageView = JPPageView(frame: pageFrame, titles: titles, style: style, childVCs: childVCs, parentVC: self)

        view.addSubview(pageView)
    }
    
    private func setupPageCollectionView() {
        // 1.设置frame
        let pageCollectionFrame = CGRect(x: 0, y: 100, width: view.bounds.width, height: 300)
        
        // 2.设置标题
        let titles = ["热门", "高级", "专属", "豪华"]
        
        // 3.设置样式
        let style = JPPageStyle()
        
        let layout = JPPageCollectionViewLayout()
        layout.sectionInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        layout.itemMargin = 5
        layout.lineMargin = 5
        layout.colCount = 8
        layout.rowCount = 3
        
        let pageCollectionView = JPPageCollectionView(frame: pageCollectionFrame, titles: titles, style: style, layout: layout)
        pageCollectionView.jp_dataSource = self
        pageCollectionView.jp_register(UICollectionViewCell.self, forCellWithReuseIdentifier: kCollectionViewCellID)
        
        view.addSubview(pageCollectionView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension ViewController : JPPageCollectionViewDataSource {
    func jp_numberOfSections(in pageCollectionView: JPPageCollectionView) -> Int {
        return 4
    }
    
    func jp_pageCollectionView(_ pageCollectionView: JPPageCollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 30
        case 1:
            return 20
        case 2:
            return 50
        case 3:
            return 40
        default:
            return 0
        }
    }
    
    func jp_pageCollectionView(_ pageCollectionView: JPPageCollectionView, _ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCollectionViewCellID, for: indexPath)
        cell.backgroundColor = UIColor.jp_randomColor()
        return cell
    }
}

