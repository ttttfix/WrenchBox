//
//  Theme.swift
//  iUtil
//
//  Created by wendachuan on 19/3/22.
//  Copyright © 2019年 wendachuan. All rights reserved.
//
import UIKit
/// 主题
open class Theme {
    // 主题名称
    public let name: String
    
    // 状态栏风格
    public var statusBarStyle: UIStatusBarStyle = .default
    
    // 导航栏风格
    public var navigationBarStyle: UIBarStyle = .default
    
    // TabBar风格
    public var tabBarStyle: UIBarStyle = .default
    
    // 背景色
    public var backgroundColor: UIColor? = nil
    
    // 文字颜色
    public var textColor: UIColor? = nil
    
    // tintColor
    public var tintColor: UIColor? = nil
    
    // placeholderColor
    public var placeholderColor: UIColor? = nil
    
    public init(name: String) {
        self.name = name
    }
}
