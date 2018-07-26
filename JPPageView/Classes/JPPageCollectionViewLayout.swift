//
//  JPPageCollectionViewLayout.swift
//  JPPageView
//
//  Created by 周健平 on 2018/7/24.
//  Copyright © 2018 周健平. All rights reserved.
//

import UIKit

public class JPPageCollectionViewLayout: UICollectionViewLayout {
    public var sectionInsets : UIEdgeInsets = UIEdgeInsets.zero
    public var itemMargin : CGFloat = 0
    public var lineMargin : CGFloat = 0
    public var colCount : Int = 4
    public var rowCount : Int = 2
    
    fileprivate lazy var attributes : [UICollectionViewLayoutAttributes] = [UICollectionViewLayoutAttributes]()
    
    fileprivate var totalWidth : CGFloat = 0
}

extension JPPageCollectionViewLayout {
    override public func prepare() {
        super.prepare()
        
        // 0.对collectionView进行校验
        guard let collectionView = collectionView else {
            return
        }
        
        attributes.removeAll()
        totalWidth = 0
        
        // 1.获取collectionView中有多少组数据
        let sections = collectionView.numberOfSections
        
        // 2.遍历所有的组
        let itemW = (collectionView.bounds.width - sectionInsets.left - sectionInsets.right - itemMargin * CGFloat(colCount - 1)) / CGFloat(colCount)
        let itemH = (collectionView.bounds.height - sectionInsets.top - sectionInsets.bottom - lineMargin * CGFloat(rowCount - 1)) / CGFloat(rowCount)
        let onePageMaxOfNum = colCount * rowCount
        var totalNumOfPage : Int = 0
        for section in 0 ..< sections {
            // 3.获取数组中有多少个item
            let items = collectionView.numberOfItems(inSection: section)
            // 4.遍历所有的item
            for item in 0 ..< items {
                // 5.根据section、item创建UICollectionViewLayoutAttributes
                let indexPath = IndexPath(item: item, section: section)
                let attribute = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                
                // 6.给attribute中的frame进行赋值
                // 自己写的
//                let page = item / onePageMaxOfNum
//                let col : Int = item % colCount
//                let row : Int = item / colCount - page * rowCount
//                let itemX : CGFloat = collectionView.bounds.width * CGFloat(previousNumOfPage + page) + sectionInsets.left + (itemMargin + itemW) * CGFloat(col)
//                let itemY : CGFloat = sectionInsets.top + (lineMargin + itemH) * CGFloat(row)
                // 老师写的
                let currentPage = item / onePageMaxOfNum
                let currentIndex : Int = item % onePageMaxOfNum
                let itemX : CGFloat = collectionView.bounds.width * CGFloat(totalNumOfPage + currentPage) + sectionInsets.left + (itemMargin + itemW) * CGFloat(currentIndex % colCount)
                let itemY : CGFloat = sectionInsets.top + (lineMargin + itemH) * CGFloat(currentIndex / colCount)
                
                attribute.frame = CGRect(x: itemX, y: itemY, width: itemW, height: itemH)
                attributes.append(attribute)
            }
            
            // 页数 = (总数 - 1) / 每页最大数 + 1
            totalNumOfPage += (items - 1) / onePageMaxOfNum + 1
        }
        
        totalWidth = CGFloat(totalNumOfPage) * collectionView.bounds.width
    }
}

extension JPPageCollectionViewLayout {
    override public func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return attributes
    }
}

extension JPPageCollectionViewLayout {
    override public var collectionViewContentSize: CGSize {
        return CGSize(width: totalWidth, height: 0)
    }
}

