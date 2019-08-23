//
//  ThemeSearchBar.swift
//  iUtil
//
//  Created by wendachuan on 19/3/22.
//  Copyright © 2019年 wendachuan. All rights reserved.
//

import UIKit

/// 主题UISearchBar
open class ThemeSearchBar: UISearchBar, ThemeProtocol {
    
    open override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        if let theme = ThemeManager.shared.currentTheme {
            applyTheme(theme: theme)
        }
    }
    
    // MARK: - ThemeProtocol
    
    /// 应用主题
    ///
    /// - parameter theme: 目标主题
    public func applyTheme(theme: Theme) {
        
    }
}
