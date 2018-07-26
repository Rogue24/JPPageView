//
//  JPPageStyle.swift
//  JPPageView
//
//  Created by 周健平 on 2018/4/22.
//  Copyright © 2018年 周健平. All rights reserved.
//

import UIKit

// Swift中的类可以不继承任何类，那这个类就是基类
// 例如【只保存数据】的话，就不需要继承任何类（NSObject里面的一堆方法也不需要用到的情况）
//class JPPageStyle {
//
//}

// Swift中的结构体（struct，无法继承）不仅可以定义属性，还可以定义方法
public struct JPPageStyle {
    
    public init() {
        
    }
    
    public var titleHeight : CGFloat = 44
    
    public var titleNormalColor : UIColor = UIColor.purple
    
    public var titleSelectColor : UIColor = UIColor.magenta
    
    public var titleFont : UIFont = UIFont.systemFont(ofSize: 14.0)
    
    public var isScrollEnable : Bool = false
    
    public var titleMargin : CGFloat = 28.0
    
    public var isShowBottomLine : Bool = true
    public var bottomLineColor : UIColor = UIColor(r: 255, g: 127, b: 0)
    public var bottomLineHeight : CGFloat = 2
    
    public var isNeedTitleScale : Bool = false
    public var maxTitleScale : CGFloat = 1.2
    
    public var isShowCoverView : Bool = false
    public var coverViewColor : UIColor = UIColor.purple
    public var coverViewAlpha : CGFloat = 0.3
    public var coverViewHeight : CGFloat = 28
    public var coverViewRadius : CGFloat = 14
    public var coverViewMargin : CGFloat = 8.0
    
    public var pageControlHeight : CGFloat = 20
    public var isTitleInTop: Bool = false
}
