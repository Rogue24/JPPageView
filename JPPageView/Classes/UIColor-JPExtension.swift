//
//  UIColor-JPExtension.swift
//  JPPageView
//
//  Created by 周健平 on 2018/5/6.
//  Copyright © 2018年 周健平. All rights reserved.
//

import UIKit

extension UIColor {
    
    /**
     * convenience：便利，使用convenience修饰的构造函数叫做【便利构造函数】
     * 便利构造函数特点：
        1.便利构造函数通常都是写在extension里面（extension xxx {这里}）
        2.便利构造函数init前面需要添加convenience修饰
        3.在便利构造函数中，必须要调用self.init()或该类其他原有的构造函数（init开头的函数）
     */
    
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat = 1.0) {
        self.init(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: a)
    }
    
    convenience init?(hexStr: String) {
        // ## # 0x 0X
        
        // 1.判断字符串的长度是否大于等于6位
        guard hexStr.count >= 6 else {
            return nil
        }
        
        // 2.将字符串转成大写（可能有大写也可能有小写，这里统一转成大写）
        var HEXStr = hexStr.uppercased()
        
        // 3.判断字符串是否“0X”、“##”、“#”开头
        if HEXStr.hasPrefix("0X") || HEXStr.hasPrefix("##") {
            HEXStr = (HEXStr as NSString).substring(from: 2) as String
        }
        if HEXStr.hasPrefix("#") {
            HEXStr = (HEXStr as NSString).substring(from: 1) as String
        }
        
        guard HEXStr.count == 6 else {
            return nil
        }
        
        // 4.获取rgb值
        
        var range = NSRange(location: 0, length: 2)
        let rHex = (HEXStr as NSString).substring(with: range) as String
        
        range.location = 2
        let gHex = (HEXStr as NSString).substring(with: range) as String
        
        range.location = 4
        let bHex = (HEXStr as NSString).substring(with: range) as String
        
        var r : UInt32 = 0
        var g : UInt32 = 0
        var b : UInt32 = 0
        // String -> UInt32：使用Scanner扫描转换
        Scanner(string: rHex).scanHexInt32(&r)
        Scanner(string: gHex).scanHexInt32(&g)
        Scanner(string: bHex).scanHexInt32(&b)
        
        self.init(r: CGFloat(r), g: CGFloat(g), b: CGFloat(b))
    }
    
    // CGFloat(arc4random_uniform(256))
    public class func jp_randomColor() -> UIColor {
        return UIColor(r: CGFloat(arc4random_uniform(256)), g: CGFloat(arc4random_uniform(256)), b: CGFloat(arc4random_uniform(256)))
    }
}

// MARK:- 从颜色中获取rgb的值
extension UIColor {
    /**
     * 从颜色中获取rgb的值
     * 为了确保拿到的是准确值而不是可选类型，先可选绑定（guard）判断该颜色是否通过rgb创建的颜色，不是直接跑出异常（让你崩溃！），确保这个颜色肯定有rgb值
     */
    func getRGBValue() -> (CGFloat, CGFloat, CGFloat) {
        guard let components = cgColor.components else {
            fatalError("错误！请确定该颜色是通过rgb创建的！")
        }
        return (components[0] * 255, components[1] * 255, components[2] * 255)
    }
}
