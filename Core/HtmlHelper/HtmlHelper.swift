//
//  HtmlHelper.swift
//  iUtil
//
//  Created by wendachuan on 19/3/22.
//  Copyright © 2019年 wendachuan. All rights reserved.
//

import UIKit
import HTMLReader
import WebKit

open class HtmlHelper: NSObject {

    /// 获得img标签的src值
    ///
    /// - parameter img: 标签
    /// - parameter error: 错误信息
    /// - returns: 失败返回nil，否则返回src值
    public static func getImgSrc(_ img: String, error: NSErrorPointer) -> String? {
        let xmlDoc = HTMLDocument(string: img)
        if let imgElem = xmlDoc.firstNode(matchingSelector: "img") {
            if let src = imgElem.attributes["src"] {
                return src
            } else {
                error?.pointee = NSError(errorCode: 0, errorDescription: "传入的img没有src属性")
            }
        } else {
            error?.pointee = NSError(errorCode: 0, errorDescription: "传入的参数有误，没有img标签")
        }

        return nil
    }
    
    /// 获得a标签的链接地址
    ///
    /// - Parameters:
    ///   - a: 标签
    ///   - error: 错误信息
    /// - Returns: 失败返回nil，否则返回链接地址
    public static func getALink(_ a: String, error: NSErrorPointer) -> String? {
        let xmlDoc = HTMLDocument(string: a)
        if let aElem = xmlDoc.firstNode(matchingSelector: "a") {
            return aElem.textContent
        } else {
            error?.pointee = NSError(errorCode: 0, errorDescription: "传入的参数有误，没有a标签")
        }
        return nil
    }

    /// 对html进行调整，以适配手机显示
    ///
    /// - parameter html: 源html
    /// - parameter error: 返回的错误
    /// - returns: 调整过后的html
    public static func makeHTMLAdapteToPhone(_ html: String, error: NSErrorPointer) -> String? {
        let xmlDoc = HTMLDocument(string: html)
        if let bodyElem = xmlDoc.bodyElement {
            var nodeStack = [bodyElem]
            while !nodeStack.isEmpty {
                let elem = nodeStack.removeFirst()
                nodeStack.append(contentsOf: elem.childElementNodes)
                if elem.childElementNodes.count == 0 {
                    let textContext = elem.textContent.replacingOccurrences(of: "\r\n", with: "\n", options: String.CompareOptions.caseInsensitive, range: nil)
                    let paragraphs = textContext.components(separatedBy: "\n")
                    if paragraphs.count > 1 {
                        elem.textContent = ""
                        for index in 0 ..< paragraphs.count {
                            let textNode = HTMLTextNode(data: paragraphs[index])
                            elem.addChild(textNode)
                            if index < paragraphs.count - 1 {
                                let brNode = HTMLElement(tagName: "br", attributes: nil)
                                elem.addChild(brNode)
                            }
                        }
                    }
                }

                switch elem.tagName.lowercased() {
                case "img":
                    makeImgTagAdapteToPhone(elem)
                case "video":
                    makeVideoTagAdapteToPhone(elem)
                case "p":
                    makePTagAdapteToPhone(elem)
                case "a":
                    makeATagAdapteToPhone(elem)
                case "audio":
                    makeAudioTagAdapteToPhone(elem)
                default:
                    setStyle(elem)
                }
            }
            return xmlDoc.serializedFragment
        } else {
            return nil
        }
    }

    /// 对html进行调整，使得img的src为绝对路径
    ///
    /// - parameter html: 源html
    /// - parameter baseUrl: 基地址
    /// - parameter error: 返回的错误
    /// - returns: 调整过后的html
    public static func makeImgSrcAbsolute(_ html: String, baseUrl: String, error: NSErrorPointer) -> String {
        let xmlDoc = HTMLDocument(string: html)
        if let bodyElem = xmlDoc.bodyElement {
            var nodeStack = [bodyElem]
            while !nodeStack.isEmpty {
                let elem = nodeStack.removeFirst()
                nodeStack.append(contentsOf: elem.childElementNodes)

                switch elem.tagName.lowercased() {
                case "img":
                    if let src = elem.attributes["src"] {
                        if src.hasPrefix("/") {
                            elem.setValue("\(baseUrl)\(src)", forKey: "src")
                        }
                    }
                default:
                    break
                }
            }
            return xmlDoc.serializedFragment
        } else {
            return html
        }
    }
    
    /// 对img标签进行调整，以适配手机显示
    ///
    /// - parameter html: 源html
    /// - returns: 调整过后的html
    public static func makeImgTagAdapteToPhone(_ html: String) -> String {
        let xmlDoc = HTMLDocument(string: html)
        if let bodyElem = xmlDoc.bodyElement {
            var nodeStack = [bodyElem]
            while !nodeStack.isEmpty {
                let elem = nodeStack.removeFirst()
                nodeStack.append(contentsOf: elem.childElementNodes)
                
                switch elem.tagName.lowercased() {
                case "img":
                    makeImgTagAdapteToPhone(elem)
                default:
                    break
                }
            }
            return xmlDoc.serializedFragment
        } else {
            return html
        }
    }

    /// 对img标签进行调整，以适配手机显示
    ///
    /// - parameter elem: 待处理的HTML元素
    fileprivate static func makeImgTagAdapteToPhone(_ elem: HTMLElement) {
        if elem.tagName.lowercased().compare("img") == ComparisonResult.orderedSame {
            var imgOriginalWidth: Float? = nil
            var imgOriginalHeight: Float? = nil
            for (attrName, attrValue) in elem.attributes {
                switch attrName.lowercased() {
                case "src":
                    break
                case "width":
                    imgOriginalWidth = Float(attrValue)
                case "height":
                    imgOriginalHeight = Float(attrValue)
                default:
                    elem.removeAttribute(withName: attrName)
                }
            }
            
            var styleContent = ""
            if let style = elem.value(forKey: "style") as? String {
                styleContent = style
            }
            
            if imgOriginalWidth != nil && imgOriginalHeight != nil {
                let imgWidth = Float(UIScreen.main.bounds.width)
                if imgWidth < imgOriginalWidth! {
//                    elem.setObject("\(imgWidth)", forKeyedSubscript: "width")
//                    elem.setObject("\(imgOriginalHeight! * imgWidth / imgOriginalWidth!)", forKeyedSubscript: "height")
//                    elem.setObject(styleContent + " width:auto/9; width:100%;", forKeyedSubscript: "style")
                    elem.setValue(styleContent + "display:block;max-width: 100%;height:auto;", forKey: "style")
                } else {
                    elem.setValue(styleContent + " width:\(imgOriginalWidth!)px; height:\(imgOriginalHeight!)px;", forKey: "style")
                }
            } else {
                elem.setValue(styleContent + "display:block;max-width: 100%;height:auto;", forKey: "style")
            }
        }
    }

    /// 对video标签进行调整，以适配手机显示
    ///
    /// - parameter elem: 待处理的HTML元素
    fileprivate static func makeVideoTagAdapteToPhone(_ elem: HTMLElement) {
        if elem.tagName.lowercased().compare("video") == ComparisonResult.orderedSame {
            for (attrName, _) in elem.attributes {
                switch attrName.lowercased() {
                case "autoplay", "controls", "loop", "muted", "poster", "preload", "src", "webkit-playsinline", "playsinline":
                    break
                default:
                    elem.removeAttribute(withName: attrName)
                }
            }
            elem.setValue("display: block", forKey: "style")
        }
    }
    
    /// 对audio标签进行调整，以适配手机显示
    ///
    /// - Parameter elem: 待处理的HTML元素
    fileprivate static func makeAudioTagAdapteToPhone(_ elem: HTMLElement) {
        if elem.tagName.lowercased().compare("audio") == ComparisonResult.orderedSame {
            for (attrName, _) in elem.attributes {
                switch attrName.lowercased() {
                case "autoplay", "controls", "loop", "muted", "poster", "preload", "src", "webkit-playsinline", "playsinline":
                    break
                default:
                    elem.removeAttribute(withName: attrName)
                }
            }
            elem.setValue("display: block", forKey: "style")
        }
    }

    /// 对p标签进行调整，以适配手机显示
    ///
    /// - parameter elem: 待处理的HTML元素
    fileprivate static func makePTagAdapteToPhone(_ elem: HTMLElement) {
        if elem.tagName.lowercased().compare("p") == ComparisonResult.orderedSame {
            //保留p标签style中的display属性
            var displayValue = ""
            if let styleStr = elem.attributes["style"] {
                let styleAttributes = styleStr.components(separatedBy: ";")
                for styleAttribute in styleAttributes {
                    if styleAttribute.contains("display:") {
                        displayValue = styleAttribute
                        break
                    }
                }
            }
            removeTagAllAttributes(elem)
            if !displayValue.isEmpty {
                elem.setValue("text-indent: 0em; word-wrap: break-word; \(displayValue)", forKey: "style")
            } else {
                elem.setValue("text-indent: 0em; word-wrap: break-word", forKey: "style")
            }
        }
    }
    
    /// 重置标签的text-indent属性
    ///
    /// - parameter html: 源HTML
    /// - returns: 处理后的html
    public static func resetTagTextIndent(_ html: String) -> String {
        let xmlDoc = HTMLDocument(string: html)
        if let rootElem = xmlDoc.rootElement {
            var nodeStack = [rootElem]
            while !nodeStack.isEmpty {
                let elem = nodeStack.removeFirst()
                nodeStack.append(contentsOf: elem.childElementNodes)
                if let style = elem.attributes["style"]?.lowercased() {
                    if style.contains("text-indent") {
                        var styleArray = style.split(separator: ";").map(String.init).filter({ (elem) -> Bool in
                            return !elem.contains("text-indent")
                        })
                        styleArray.append("text-indent: 0em")
                        let editedStyle = styleArray.joined(separator: ";")
                        elem.setValue(editedStyle, forKey: "style")
                    }
                }
            }
            return xmlDoc.serializedFragment
        } else {
            return html
        }
    }


    /// 对a标签进行调整，以适配手机显示
    ///
    /// - parameter elem: 待处理的HTML元素
    fileprivate static func makeATagAdapteToPhone(_ elem: HTMLElement) {
        if elem.tagName.lowercased().compare("a") == ComparisonResult.orderedSame {
            for (attrName, _) in elem.attributes {
                switch attrName.lowercased() {
                case "href":
                    break
                default:
                    elem.removeAttribute(withName: attrName)
                }
            }
        }
    }

    /// 移除标签的全部属性
    ///
    /// - parameter elem: 待处理的HTML元素
    fileprivate static func removeTagAllAttributes(_ elem: HTMLElement) {
        for (attrName, _) in elem.attributes {
            elem.removeAttribute(withName: attrName)
        }
    }

    /// 对标签进行调整，以适配手机显示
    ///
    /// - parameter elem: 待处理的HTML元素
    fileprivate static func setStyle(_ elem: HTMLElement) {
        removeTagAllAttributes(elem)
    }

    /// 获得html文本内容
    ///
    /// - parameter html: 源html
    /// - returns: 文本内容
    public static func getInnerText(_ html: String) -> String? {
        let xmlDoc = HTMLDocument(string: html)
        if let rootElem = xmlDoc.rootElement {
            return rootElem.textContent
        } else {
            return nil
        }
    }

    /// 获得给定html的body的innerHTML
    ///
    /// - parameter html: 源html
    /// - returns: html body
    public static func getBodyHTML(_ html: String) -> String? {
        let xmlDoc = HTMLDocument(string: html)
        if let bodyElem = xmlDoc.bodyElement {
            return bodyElem.innerHTML
        } else {
            return nil
        }
    }

    /// 获得第一个img标签的src
    ///
    /// - parameter html: 源html
    /// - returns: 第一个img标签的src值
    public static func getFirstImgSrc(_ html: String) -> String? {
        let xmlDoc = HTMLDocument(string: html)
        if let rootElem = xmlDoc.rootElement {
            var nodeStack = [rootElem]
            while !nodeStack.isEmpty {
                let elem = nodeStack.removeFirst()
                nodeStack.append(contentsOf: elem.childElementNodes)
                if elem.tagName.lowercased().compare("img") == ComparisonResult.orderedSame {
                    if let src = elem.attributes["src"] {
                        return src
                    }
                }
            }
            return nil
        } else {
            return nil
        }
    }

    /// 图片延迟加载
    ///
    /// - parameter html: 源html
    /// - parameter placeHolderImg: 占位图片路径
    /// - returns: 成功则返回处理后的html，否则返回nil
    public static func makeImgLazyLoad(_ html: String, placeHolderImg: String? = nil) -> String? {
        let xmlDoc = HTMLDocument(string: html)
        if let rootElem = xmlDoc.rootElement {
            for child in rootElem.children {
                if (child as AnyObject).tagName?.compare("head") == ComparisonResult.orderedSame {
                    var jqueryContent = ""
                    if let jqueryFilePath = Bundle.iutilBundle().path(forResource: "jquery-1.12.4", ofType: "js") {
                        do {
                            jqueryContent = try String(contentsOfFile: jqueryFilePath)
                        } catch {
                            print("读取jquery-1.12.4.js失败")
                        }
                    }

                    var jqueryLazyloadContent = ""
                    if let jqueryLazyloadFilePath = Bundle.iutilBundle().path(forResource: "jquery.lazyload", ofType: "js") {
                        do {
                            jqueryLazyloadContent = try String(contentsOfFile: jqueryLazyloadFilePath)
                        } catch {
                            print("读取jquery.lazyload.js失败")
                        }
                    }

                    var htmlHelperContent = ""
                    if let htmlHelperFilePath = Bundle.iutilBundle().path(forResource: "HtmlHelper", ofType: "js") {
                        do {
                            htmlHelperContent = try String(contentsOfFile: htmlHelperFilePath)
                        } catch {
                            print("读取HTMLHelper.js失败")
                        }
                    }

                    let scriptElem = HTMLElement(tagName: "script", attributes: ["type": "text/javascript"])
                    scriptElem.textContent = "\(jqueryContent)\n\(jqueryLazyloadContent)\n\(htmlHelperContent)"

                    (child as AnyObject).addChild(scriptElem)
                }
            }
        }

        if let bodyElem = xmlDoc.bodyElement {
            var nodeStack = [bodyElem]
            while !nodeStack.isEmpty {
                let elem = nodeStack.removeFirst()
                nodeStack.append(contentsOf: elem.childElementNodes)

                if elem.tagName.lowercased().compare("img") == ComparisonResult.orderedSame {
                    guard let _ = elem.attributes["width"] else {
                        continue
                    }
                    
                    guard let _ = elem.attributes["height"] else {
                        continue
                    }
                    
                    if let src = elem.attributes["src"] {
                        elem.setValue(String.toNoneNIL(placeHolderImg), forKey: "src")
                        elem.setValue(src, forKey: "data-original")
                        elem.setValue("lazy", forKey: "class")
                    }
                }
            }
            
            
            let containerElem = HTMLElement.init(tagName: "div", attributes: ["style": "visibility: hidden; width: 300px; height: 300px; background-color: aquamarine; position: fixed; top: 0px; left: 0px; ",
                                                                              "id": "container"])
            bodyElem.addChild(containerElem)
            
            let scriptElem = HTMLElement.init(tagName: "script", attributes: ["type": "text/javascript"])
            scriptElem.textContent = "$(window).ready(function() { $('img.lazy').lazyload( {container: $('#container'), threshold: 300} ); });"
            bodyElem.addChild(scriptElem)

            return xmlDoc.serializedFragment
        } else {
            return nil
        }
    }
    
    /// 手动触发window的scroll事件
    /// 当UIWebView的高度等于内容高度时，外层的scrollView滚动不会触发window的scroll事件，因此需要手动触发scroll事件
    ///
    /// - parameter webView:
    public static func manualFireWindowScrollEvent(_ webView: UIWebView, _ scrollOffset: Float) {
        let script = "notifyScrollEvent(\(scrollOffset));"
        webView.stringByEvaluatingJavaScript(from: script)
    }
    
    /// 手动触发window的scroll事件
    /// 当UIWebView的高度等于内容高度时，外层的scrollView滚动不会触发window的scroll事件，因此需要手动触发scroll事件
    ///
    /// - parameter webView:
    public static func manualFireWindowScrollEventWith(wkWebView webView: WKWebView, _ scrollOffset: Float) {
        let script = "notifyScrollEvent(\(scrollOffset));"
        webView.evaluateJavaScript(script, completionHandler: nil)
    }
}
