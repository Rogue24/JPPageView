//
//  JPTitleView.swift
//  JPPageView
//
//  Created by 周健平 on 2018/4/22.
//  Copyright © 2018年 周健平. All rights reserved.
//

import UIKit

// “: class”：说明该协议只能被【类】遵守（结构体、基本数据等其他类型无法继承）
// 当声明这个协议属性使用weak修饰时，由于weak只能修饰对象类型，所以这个协议要继承于class，说明这个协议属性是某个类的对象遵守了这个协议
protocol JPTitleViewDelegate : class {
    func titleView(_ titleView : JPTitleView, titleDidClick targetIndex : Int)
}

class JPTitleView: UIView {
    // MARK:- 属性
    // weak：只能修饰对象类型
    weak var delegate : JPTitleViewDelegate?
    
    var titles : [String]
    var style : JPPageStyle
    
    fileprivate lazy var scrollView : UIScrollView = {
        let scrollView = UIScrollView(frame: self.bounds)
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.scrollsToTop = false
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        }
        return scrollView
    }()
    
    fileprivate lazy var titleLabels : [UILabel] = [UILabel]()
    fileprivate var currentIndex : Int = 0
    
    fileprivate lazy var normalRGB : (CGFloat, CGFloat, CGFloat) = self.style.titleNormalColor.getRGBValue()
    fileprivate lazy var selectRGB : (CGFloat, CGFloat, CGFloat) = self.style.titleSelectColor.getRGBValue()
    fileprivate lazy var deltaRGB : (CGFloat, CGFloat, CGFloat) = {
        return (self.selectRGB.0 - self.normalRGB.0,
                self.selectRGB.1 - self.normalRGB.1,
                self.selectRGB.2 - self.normalRGB.2)
    }()
    
    fileprivate lazy var bottomLine : UIView = {
        let bottomLine = UIView()
        bottomLine.backgroundColor = self.style.bottomLineColor
        return bottomLine
    }()
    
    fileprivate lazy var coverView : UIView = {
        let coverView = UIView()
        coverView.backgroundColor = self.style.coverViewColor
        coverView.alpha = self.style.coverViewAlpha
        return coverView
    }()
    
    // MARK:- 构造函数
    init(frame: CGRect, titles: [String], style: JPPageStyle) {
        
        self.titles = titles
        self.style = style
        
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK:- 设置ui界面
extension JPTitleView {
    fileprivate func setupUI() {
        // 1.添加scrollView
        addSubview(scrollView)
        
        // 2.初始化所有的label
        setupTitleLabels()
        
        // 3.初始化底部的line
        if style.isShowBottomLine {
            setupBottomLine()
        }
        
        // 4.初始化遮盖view
        if style.isShowCoverView {
            setupCoverView()
        }
    }
    
    private func setupCoverView() {
        scrollView.insertSubview(coverView, at: 0)
        guard let firstLabel = titleLabels.first else {
            return
        }
        var w : CGFloat = firstLabel.frame.width
        let h : CGFloat = style.coverViewHeight
        var x : CGFloat = firstLabel.frame.origin.x
        let y : CGFloat = (style.titleHeight - h) * 0.5
        if style.isScrollEnable {
            x -= style.coverViewMargin
            w += style.coverViewMargin * 2
        }
        coverView.frame = CGRect(x: x, y: y, width: w, height: h)
        coverView.layer.cornerRadius = style.coverViewRadius
        coverView.layer.masksToBounds = true
    }
    
    private func setupBottomLine() {
        scrollView.addSubview(bottomLine)
        let titleLabel : UILabel = titleLabels.first!
        let w = titleLabel.frame.width
        let h = style.bottomLineHeight
        let x = titleLabel.frame.origin.x
        let y = style.titleHeight - h
        bottomLine.frame = CGRect(x: x, y: y, width: w, height: h)
    }
    
    private func setupTitleLabels() {
//        for i in 0 ..< titles.count {
//
//        }
        
        // 1.创建所有label
        // 快速遍历
        for (i, title) in titles.enumerated() {
            // 1.创建label
            let titleLabel = UILabel()
            
            // 2.设置label的属性
            titleLabel.tag = i
            titleLabel.isUserInteractionEnabled = true
            titleLabel.text = title
            titleLabel.textAlignment = .center
            titleLabel.textColor = i == 0 ? style.titleSelectColor : style.titleNormalColor
            titleLabel.font = style.titleFont
            
            // 3.将label添加到scrollView
            scrollView.addSubview(titleLabel)
            
            // 4.监听label的点击
            // #selector(方法名)
            // 显示外部参数：titleLabelClick(tapGR:)
            // 不限时外部参数：titleLabelClick(_:)
            let tapGR = UITapGestureRecognizer(target: self, action: #selector(titleLabelClick(_:)))
            titleLabel.addGestureRecognizer(tapGR)
            
            // 5.将label添加到数组中
            titleLabels.append(titleLabel)
        }
        
        // 2.设置所有label的frame
        var labelW : CGFloat = bounds.width / CGFloat(titles.count)
        let labelH : CGFloat = style.titleHeight
        var labelX : CGFloat = 0
        let labelY : CGFloat = 0
        for (i, titleLabel) in titleLabels.enumerated() {
            if style.isScrollEnable {
                labelW = (titleLabel.text! as NSString).boundingRect(with: CGSize(width: 999.0, height: style.titleHeight), options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font : style.titleFont], context: nil).width
                labelX = i == 0 ? style.titleMargin * 0.5 : (titleLabels[i - 1].frame.maxX + style.titleMargin)
            } else {
                labelX = labelW * CGFloat(i)
            }
            titleLabel.frame = CGRect(x: labelX, y: labelY, width: labelW, height: labelH)
        }
        
        // 3.设置contentSize
        if style.isScrollEnable {
            scrollView.contentSize = CGSize(width: (titleLabels.last?.frame.maxX)! + style.titleMargin * 0.5, height: 0)
        }
        
        // 4.设置缩放
        if style.isNeedTitleScale {
            titleLabels.first?.transform = CGAffineTransform(scaleX: style.maxTitleScale, y: style.maxTitleScale)
        }
    }
}

// MARK:- 点击事件监听
extension JPTitleView {
    // ?. 可选链
    // tapGR：是外部参数，如果不希望有外部参数的显示，可以在外部参数前面加上“_”
    // 显示外部参数：titleLabelClick(tapGR:)
    // 不限时外部参数：titleLabelClick(_:)
    @objc func titleLabelClick(_ tapGR: UITapGestureRecognizer) {
        // 0.校验label是否有值
        guard let targetLabel = tapGR.view as? UILabel else {
            return
        }
        
        // 1.跳转到目标偏移量
        scrollToIndex(targetLabel.tag)
        
        // 2.通知代理
//        if let delegate = delegate {
//            delegate.titleView(self, targetIndex: currentIndex)
//        }
        // 可选链（例如使用可选类型调用其函数）：如果可选类型有值，就执行代码，没有值，什么事都不发生
        delegate?.titleView(self, titleDidClick: currentIndex)
    }
    
    fileprivate func scrollToIndex(_ targetIndex : Int) {
        // 1.判断是不是之前选中的label
        guard targetIndex != currentIndex else {
            return
        }
        
        let sourceLabel = titleLabels[currentIndex]
        let targetLabel = titleLabels[targetIndex]
        
        // 2.让之前的label不选中，让新的label可以选中
        sourceLabel.textColor = style.titleNormalColor
        targetLabel.textColor = style.titleSelectColor
        
        // 3.调整文字缩放
        if style.isNeedTitleScale {
            UIView.animate(withDuration: 0.25) {
                sourceLabel.transform = CGAffineTransform.identity
                targetLabel.transform = CGAffineTransform(scaleX: self.style.maxTitleScale, y: self.style.maxTitleScale)
            }
        }
        
        // 4.调整bottomLine和coverView的位置
        if style.isShowBottomLine || style.isShowCoverView {
            var x = targetLabel.frame.origin.x
            var w = targetLabel.frame.width
            UIView.animate(withDuration: 0.25) {
                if self.style.isShowBottomLine {
                    self.bottomLine.frame.origin.x = targetLabel.frame.origin.x
                    self.bottomLine.frame.size.width = targetLabel.frame.width
                    // 读可以这样：xxx.frame.width
                    // 但写要这样：xxx.frame.size.width
                }
                if self.style.isShowCoverView {
                    if self.style.isScrollEnable {
                        x -= self.style.coverViewMargin
                        w += self.style.coverViewMargin * 2
                    }
                    self.coverView.frame = CGRect(x: x, y: self.coverView.frame.origin.y, width: w, height: self.coverView.frame.height)
                }
            }
        }
        
        // 5.让新的tag作为currentIndex
        currentIndex = targetLabel.tag
        
        // 6.调整点击的label的位置，滚动到中间
        if style.isScrollEnable {
            var offsetX = targetLabel.center.x - scrollView.bounds.width * 0.5
            if offsetX < 0 {
                offsetX = 0
            } else {
                let maxOffsetX = scrollView.contentSize.width - scrollView.bounds.width
                if offsetX > maxOffsetX {
                    offsetX = maxOffsetX
                }
            }
            scrollView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: true)
        }
    }
    
}

// MARK:- JPContentViewDelegate
extension JPTitleView : JPContentViewDelegate {
    func contentView(_ contentView: JPContentView, didEndScroll targetIndex: Int) {
        scrollToIndex(targetIndex)
    }
    
    func contentView(_ contentView: JPContentView, sourceIndex: Int, targetIndex: Int, progress: CGFloat) {
        // 1.获取对应的label
        let sourceLabel = titleLabels[sourceIndex]
        let targetLabel = titleLabels[targetIndex]
        
        // 2.颜色渐变
        sourceLabel.textColor = UIColor(r: selectRGB.0 - deltaRGB.0 * progress,
                                        g: selectRGB.1 - deltaRGB.1 * progress,
                                        b: selectRGB.2 - deltaRGB.2 * progress)
        targetLabel.textColor = UIColor(r: normalRGB.0 + deltaRGB.0 * progress,
                                        g: normalRGB.1 + deltaRGB.1 * progress,
                                        b: normalRGB.2 + deltaRGB.2 * progress)
        
        // 3.缩放变化
        if style.isNeedTitleScale {
            let deltaScale = style.maxTitleScale - 1.0
            let sourceSclae : CGFloat = style.maxTitleScale - deltaScale * progress
            let targetSclae : CGFloat = 1.0 + deltaScale * progress
            sourceLabel.transform = CGAffineTransform(scaleX: sourceSclae, y: sourceSclae)
            targetLabel.transform = CGAffineTransform(scaleX: targetSclae, y: targetSclae)
        }
        
        // 4.计算bottomLine和coverView的xw变化
        if style.isShowBottomLine || style.isShowCoverView {
            var x = sourceLabel.frame.origin.x + (targetLabel.frame.origin.x - sourceLabel.frame.origin.x) * progress
            var w = sourceLabel.frame.width + (targetLabel.frame.width - sourceLabel.frame.width) * progress
            if style.isShowBottomLine {
                bottomLine.frame = CGRect(x: x, y: bottomLine.frame.origin.y, width: w, height: bottomLine.frame.height)
            }
            if style.isShowCoverView {
                if style.isScrollEnable {
                    x -= style.coverViewMargin
                    w += style.coverViewMargin * 2
                }
                coverView.frame = CGRect(x: x, y: coverView.frame.origin.y, width: w, height: coverView.frame.height)
            }
        }
    }
}

// MARK:- 公开方法
extension JPTitleView {
    func setCurrentIndex(_ index: Int) {
        scrollToIndex(index)
    }
}
