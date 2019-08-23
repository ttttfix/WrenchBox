//
//  SwizzleHelper.swift
//  iUtil
//
//  Created by wendachuan on 19/3/22.
//  Copyright © 2019年 wendachuan. All rights reserved.
//

import UIKit

/// swizzling辅助类
public class SwizzleHelper {
    /// 方法替换
    /// - parameter originalSelector: 原始方法
    /// - parameter swizzledSelector: 替换后的方法
    public class func replaceMethod(_ originalSelector: Selector, withMethod swizzledSelector: Selector) {
        guard let originalMethod = class_getInstanceMethod(self, originalSelector) else {
            return
        }
        
        guard let swizzledMethod = class_getInstanceMethod(self, swizzledSelector) else {
            return
        }
        
        let didAddMethod = class_addMethod(self, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))
        
        if didAddMethod {
            class_replaceMethod(self, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
    }
}
