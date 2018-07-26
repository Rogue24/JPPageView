//
//  JPPageView.swift
//  JPPageView
//
//  Created by 周健平 on 2018/4/22.
//  Copyright © 2018年 周健平. All rights reserved.
//

import UIKit

public class JPPageView: UIView {
    
    // MARK:- 属性
    // 在构造函数中调用super.init(xxx)之前，必须保证所有的属性有【被初始化】，不要编译报错
    
    // 1.定义时就初始化
//    var titles: [String] = []
//    var style: JPPageStyle = JPPageStyle()
//    var childVCs: [UIViewController] = []
//    var parentVC: UIViewController = UIViewController()
    
    // 2.使用可选类型（可选类型默认就为nil，不需要初始化）
//    var titles: [String]?
//    var style: JPPageStyle?
//    var childVCs: [UIViewController]?
//    var parentVC: UIViewController?
   
    // 3.在构造函数调用super.init(xxx)之前就赋值
    var titles: [String]
    var style: JPPageStyle
    var childVCs: [UIViewController]
    var parentVC: UIViewController
    
    // MARK:- 自定义构造函数
    public init(frame: CGRect, titles: [String], style: JPPageStyle, childVCs: [UIViewController], parentVC: UIViewController) {
        
        // 先给属性赋值之后（必须得有值）才能调用super.init(xxx)，不然编译不通过
        // 属性名和参数名一样时，需要用到self.xxx来区分
        self.titles = titles
        self.style = style
        self.childVCs = childVCs
        self.parentVC = parentVC
        
        super.init(frame: frame)
        
        setupUI()
        
    }
    
    // 用【required】修饰的构造函数
    // 如果子类有重写or自定义其他构造函数，那么必须重写这个构造函数
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}

// MARK:- 设置UI
extension JPPageView {
    
    private func setupUI() {
        
        // 1.创建titleView
        let titleFrame = CGRect(x: 0, y: 0, width: bounds.width, height: style.titleHeight)
        let titleView = JPTitleView(frame: titleFrame, titles: titles, style: style)
//        titleView.backgroundColor = UIColor.jp_randomColor()
        titleView.backgroundColor = UIColor.white
        addSubview(titleView)
        
        // 2.创建contentView
        let contentFrame = CGRect(x: 0, y: titleFrame.maxY, width: bounds.width, height: bounds.height - titleFrame.maxY)
        let contentView = JPContentView(frame: contentFrame, childVCs: childVCs, parentVC: parentVC)
        contentView.backgroundColor = UIColor.jp_randomColor()
        addSubview(contentView)
        
        // 3.titleView和contentView的联动
        titleView.delegate = contentView
        contentView.delegate = titleView
        
    }
    
}
