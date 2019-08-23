//
//  YBPDFExport.swift
//  WrenchBox
//
//  Created by yang bin on 2019/8/23.
//  Copyright © 2019 ttttfix. All rights reserved.
//

import UIKit

class YBPDFExport: NSObject {


    /// 多张图片转PDF
    ///
    /// - Parameters:
    ///   - filePath: PDF路径
    ///   - images: 需要转换的图片数组
    class func genratePDF(_ filePath:String,_ images: Array<UIImage>) {
        UIGraphicsBeginPDFContextToFile(filePath, .zero, nil)
        for image in images {
            UIGraphicsBeginPDFPage()
            let imageHeight = image.size.height / image.size.width * 512
            image.draw(in: CGRect(x: 50, y: (792-imageHeight)/2, width: 512, height: imageHeight))
        }
        UIGraphicsEndPDFContext()
    }
    

}
