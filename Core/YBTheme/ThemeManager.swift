//
//  ThemeManager.swift
//  iUtil
//
//  Created by wendachuan on 19/3/22.
//  Copyright © 2019年 wendachuan. All rights reserved.
//
import UIKit
/// 主题管理器
open class ThemeManager {
    // 全局共享对象
    public static var shared = ThemeManager()
    
    // 主题集合
    private var themes = [String: Theme]()
    
    // 当前主题
    public private(set) var currentTheme: Theme? = nil
    
    /// 添加主题
    ///
    /// - parameter theme: 被添加的主题
    public func addTheme(theme: Theme) {
        themes[theme.name] = theme
    }
    
    /// 删除主题
    ///
    /// - parameter name: 需要删除的主题名
    public func removeTheme(name: String) {
        themes.removeValue(forKey: name)
    }
    
    /// 返回所有主题
    ///
    /// - returns: 主题数组
    public func getThemes() -> [Theme] {
        return themes.map({ (_, theme) -> Theme in
            return theme
        })
    }
    
    /// 应用主题
    public func applyTheme(name: String) {
        guard let keyWindow = UIApplication.shared.keyWindow else {
            return
        }
        
        guard let theme = themes[name] else {
            return
        }
        
        currentTheme = theme
        
        for view in keyWindow.subviews {
            view.removeFromSuperview()
            keyWindow.addSubview(view)
        }
        keyWindow.makeKey()
    }
}

/*
fileprivate extension UIApplication {
    private static let runOnce: Void = {
        //UIViewController.setupClass()
    }()
    
    override open var next: UIResponder? {
        // Called before applicationDidFinishLaunching
        UIApplication.runOnce
        return super.next
    }
}*/

