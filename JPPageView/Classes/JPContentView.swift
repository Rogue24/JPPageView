//
//  JPContentView.swift
//  JPPageView
//
//  Created by 周健平 on 2018/4/22.
//  Copyright © 2018年 周健平. All rights reserved.
//

import UIKit

/**
 * 【self.】常见有两个地方不能省略：
    1.如果和上下文中的其他标识符有歧义（例如名字一样）
    2.闭包中用到当前对象的属性时
 */

private let kContentCellID = "kContentCellID"

protocol JPContentViewDelegate : class {
    func contentView(_ contentView : JPContentView, didEndScroll targetIndex : Int)
    func contentView(_ contentView : JPContentView, sourceIndex : Int, targetIndex : Int, progress : CGFloat);
}

class JPContentView: UIView {

    // MARK:- 属性
    weak var delegate : JPContentViewDelegate?
    
    fileprivate var childVCs : [UIViewController]
    fileprivate var parentVC : UIViewController
    
    // lazy关键字：懒加载（如果这里不使用懒加载而是直接赋值的话，由于这时候还没调用【super.init(frame: frame)】，所以这时候self是没有frame的，使用懒加载就可以在之后用到collectionView时才会执行这个创建方法）
    // 1.直接创建并赋值
//    fileprivate lazy var collectionView = UICollectionView(frame: self.bounds, collectionViewLayout: UICollectionViewFlowLayout())
    // 2.使用闭包的形式，好处是不仅仅只执行创建代码，还可以执行更多代码
    fileprivate lazy var collectionView = { () -> UICollectionView in
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = self.bounds.size
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: self.bounds, collectionViewLayout: layout)
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        }
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.bounces = false
        collectionView.scrollsToTop = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: kContentCellID)
        return collectionView
    }()
    
    fileprivate var startOffsetX : CGFloat = 0
    fileprivate var isForbidDelegate : Bool = false
    
    // MARK:- 构造函数
    init(frame: CGRect, childVCs: [UIViewController], parentVC: UIViewController) {
        
        self.childVCs = childVCs
        self.parentVC = parentVC
        
        super.init(frame: frame)
        
        setUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

// MARK:- 设置UI界面
extension JPContentView {
    fileprivate func setUI() {
        // 1.将childVCs中所有控制器添加到parentVC中
        for childVc in childVCs {
            parentVC.addChildViewController(childVc)
        }
        
        // 2.添加collectionView
        addSubview(collectionView)
    }
}


// MARK:- UICollectionViewDataSource
extension JPContentView : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return childVCs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // 1.获取cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kContentCellID, for: indexPath)
        
        // 2.添加内容
        // 2.1 将之前的view删除
        for subview in cell.contentView.subviews {
            subview.removeFromSuperview()
        }
        
        // 2.2 将对应的view添加到cell中
        let childVC = childVCs[indexPath.item]
        cell.contentView.addSubview(childVC.view)
        
        return cell
    }
}

// MARK:- UICollectionViewDelegate
extension JPContentView : UICollectionViewDelegate {
    
}

// MARK:- UIScrollViewDelegate
extension JPContentView : UIScrollViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            scrollViewDidEndDecelerating(scrollView)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        delegate?.contentView(self, didEndScroll: Int(scrollView.contentOffset.x / scrollView.bounds.width))
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isForbidDelegate = false
        let offsetX = scrollView.contentOffset.x
        let scrollViewWidth = scrollView.bounds.width
        let index = Int((offsetX + scrollViewWidth * 0.5) / scrollViewWidth)
        startOffsetX = scrollViewWidth * CGFloat(index)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let offsetX = scrollView.contentOffset.x
        
        // 0.判断有没有进行滑动、有没有禁止代理
        guard offsetX != startOffsetX && !isForbidDelegate else {
            return
        }
        
        // 1.定义需要获取的变量
        var sourceIndex = 0
        var targetIndex = 0
        var progress : CGFloat = 0
        
        // 2.获取需要的参数
        let scrollViewWidth = scrollView.bounds.width
        
        // 滑动位置与初始位置的距离
        let offsetDistance = fabs(offsetX - startOffsetX)
        
        if offsetX > startOffsetX {
            // 左滑动
            sourceIndex = Int(offsetX / scrollViewWidth)
            targetIndex = sourceIndex + 1
            if targetIndex >= childVCs.count {
                targetIndex = childVCs.count - 1
            }
            progress = offsetDistance / scrollViewWidth
            
            // 这里要大于等于1
            // 例如 如果 startOffsetX = 0
            // 若 0 < offsetX < 375，0 < progress < 1，本来 sourceIndex = 0，targetIndex = 1
            // 但 375 <= offsetX，progress >= 1，导致 sourceIndex = 1，targetIndex = 2
            // 这比预期的目标值【大】1
            if progress >= 1 {
                progress = 1
                targetIndex = sourceIndex
                sourceIndex = targetIndex - 1
            }
        } else {
            // 右滑动
            targetIndex = Int(offsetX / scrollViewWidth)
            sourceIndex = targetIndex + 1
            progress = offsetDistance / scrollViewWidth
            
            // 这里只能大于1
            // 例如 如果 startOffsetX = 750
            // 若 375 <= offsetX < 750，0 < progress <= 1，本来 targetIndex = 1，sourceIndex = 2
            // 但 375 > offsetX，progress > 1，导致 targetIndex = 0，sourceIndex = 1
            // 这比预期的目标值【小】1
            if progress > 1 {
                progress = 1
                targetIndex = sourceIndex
                sourceIndex = targetIndex + 1
            }
        }
        
//        print("\(offsetX > startOffsetX ? "左":"右") sourceIndex:\(sourceIndex) targetIndex:\(targetIndex) progress:\(progress) offsetX:\(offsetX)")
        
        if offsetDistance >= scrollViewWidth {
            let index = Int((offsetX + scrollViewWidth * 0.5) / scrollViewWidth)
            startOffsetX = scrollViewWidth * CGFloat(index)
        }
        
        delegate?.contentView(self, sourceIndex: sourceIndex, targetIndex: targetIndex, progress: progress)
    }
}

// MARK:- JPTitleViewDelegate
extension JPContentView : JPTitleViewDelegate {
    func titleView(_ titleView: JPTitleView, titleDidClick targetIndex: Int) {
        
        // 禁止掉执行代理方法
        isForbidDelegate = true
        
        collectionView.scrollToItem(at: IndexPath(item: targetIndex, section: 0), at: .centeredHorizontally, animated: false)
    }
}
