//
//  JPPageCollectionView.swift
//  JPPageView
//
//  Created by 周健平 on 2018/7/23.
//  Copyright © 2018 周健平. All rights reserved.
//

import UIKit

public protocol JPPageCollectionViewDataSource : class {
    // 有多少组数据
    func jp_numberOfSections(in pageCollectionView: JPPageCollectionView) -> Int
    
    // 每组有多少数据
    func jp_pageCollectionView(_ pageCollectionView: JPPageCollectionView, numberOfItemsInSection section: Int) -> Int
    
    // 每个cell
    func jp_pageCollectionView(_ pageCollectionView: JPPageCollectionView, _ collectionView : UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
}

public class JPPageCollectionView: UIView {
    
    public weak var jp_dataSource : JPPageCollectionViewDataSource?
    
    fileprivate var titles: [String]
    fileprivate var style: JPPageStyle
    fileprivate var layout: JPPageCollectionViewLayout
    
    // 属性如果使用“!”声明，那么之后使用这个属性系统都会自动对这个属性值进行强制解包，必须得保证这个属性肯定有值，不然对空值强制解包会崩溃
    fileprivate var collectionView : UICollectionView!
    fileprivate var pageControl : UIPageControl!
    fileprivate var titleView : JPTitleView!
    
    fileprivate lazy var currentIndexPath : IndexPath = IndexPath(item: 0, section: 0)
    
    public init(frame: CGRect, titles: [String], style: JPPageStyle, layout: JPPageCollectionViewLayout) {
        self.titles = titles
        self.style = style
        self.layout = layout
        super.init(frame: frame)
        setupUI()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension JPPageCollectionView {
    fileprivate func setupUI() {
        // 1.titleView
        let titleY = style.isTitleInTop ? 0 : bounds.height - style.titleHeight
        let titleFrame = CGRect(x: 0, y: titleY, width: bounds.width, height: style.titleHeight)
        titleView = JPTitleView(frame: titleFrame, titles: titles, style: style)
        titleView.delegate = self
        addSubview(titleView)
        titleView.backgroundColor = UIColor.jp_randomColor()
        
        // 2.UICollectionView
        let collectionY = style.isTitleInTop ? style.titleHeight : 0
        let collectionH = bounds.height - style.titleHeight - style.pageControlHeight
        let collectionFrame = CGRect(x: 0, y: collectionY, width: bounds.width, height: collectionH)
        collectionView = UICollectionView(frame: collectionFrame, collectionViewLayout: layout)
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        }
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = true
        collectionView.dataSource = self
        collectionView.delegate = self
        addSubview(collectionView)
        collectionView.backgroundColor = UIColor.jp_randomColor()
        
        // 3.UIPageControl
        let pageFrame = CGRect(x: 0, y: collectionFrame.maxY, width: bounds.width, height: style.pageControlHeight)
        pageControl = UIPageControl(frame: pageFrame)
        addSubview(pageControl)
        pageControl.backgroundColor = UIColor.jp_randomColor()
    }
}

extension JPPageCollectionView {
    public func jp_register(_ cellClass: Swift.AnyClass?, forCellWithReuseIdentifier identifier: String) {
        collectionView.register(cellClass, forCellWithReuseIdentifier: identifier)
    }
    
    public func jp_register(_ nib: UINib?, forCellWithReuseIdentifier identifier: String) {
        collectionView.register(nib, forCellWithReuseIdentifier: identifier)
    }
    
    public func jp_reloadData() {
        collectionView.reloadData()
    }
}

extension JPPageCollectionView : UICollectionViewDataSource {
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return jp_dataSource?.jp_numberOfSections(in: self) ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let items = jp_dataSource?.jp_pageCollectionView(self, numberOfItemsInSection: section) ?? 0
        if pageControl.numberOfPages == 0 {
            let numberOfPages = (items - 1) / (layout.colCount * layout.rowCount) + 1
            pageControl.numberOfPages = numberOfPages
        }
        return items
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return jp_dataSource!.jp_pageCollectionView(self, collectionView, cellForItemAt: indexPath)
    }
}

extension JPPageCollectionView : UICollectionViewDelegate {
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollViewDidEndScroll()
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        // 拖拽停止有减速会自动执行scrollViewDidEndDecelerating
        if !decelerate {
            // 拖拽停止没有减速不会执行scrollViewDidEndDecelerating
            scrollViewDidEndScroll()
        }
    }
    
    private func scrollViewDidEndScroll() {
        // 1.获取滚动位置对应的indexPath
        let point = CGPoint(x: collectionView.contentOffset.x + layout.sectionInsets.left + 1, y: layout.sectionInsets.top + 1)
        guard let indexPath = collectionView.indexPathForItem(at: point) else {
            return
        }
        
        // 2.判断是否需要改变组
        let onePageCount = layout.colCount * layout.rowCount
        if indexPath.section != currentIndexPath.section {
            let items = jp_dataSource?.jp_pageCollectionView(self, numberOfItemsInSection: indexPath.section) ?? 0
            pageControl.numberOfPages = (items - 1) / onePageCount + 1
            
            // 改变titleView的下标
            titleView .setCurrentIndex(indexPath.section)
        }
        pageControl.currentPage = indexPath.item / onePageCount
        
        currentIndexPath = indexPath
    }
}

extension JPPageCollectionView : JPTitleViewDelegate {
    func titleView(_ titleView: JPTitleView, titleDidClick targetIndex: Int) {
        // 1.根据targetIndex创建对应组的indexPath
        let indexPath = IndexPath(item: 0, section: targetIndex)
        
        guard indexPath.section != currentIndexPath.section else {
            return
        }
        
        // 2.滚动到正确位置
        collectionView.scrollToItem(at: indexPath, at: .left, animated: false)
        
        // 3.调整正确的位置
        // 如果是最后一组并且最后一组的数量不超过一页，那么scrollToItem方法只会偏移到最大偏移量
        // scrollToItem方法不会超过最大偏移量（偏移量加上collectionView宽度等于contentSize的最大宽度）
        // 判断这时候的偏移量是否小于最大偏移量，如果是，说明还没到底还可以偏移，那就往右再挪一点（原本是贴边）
        if (collectionView.contentOffset.x + collectionView.bounds.width) < collectionView.contentSize.width {
            collectionView.contentOffset.x -= layout.sectionInsets.left
        }
        
        // 4.设置pageControl
        let items = jp_dataSource?.jp_pageCollectionView(self, numberOfItemsInSection: targetIndex) ?? 0
        let numberOfPages = (items - 1) / (layout.colCount * layout.rowCount) + 1
        pageControl.numberOfPages = numberOfPages
        pageControl.currentPage = 0
        
        currentIndexPath = indexPath
        
    }
}
