//
//  QRCodeGenerator.swift
//  LiteAVSwift
//
//  Created by kaoji on 2020/9/20.
//  Copyright © 2020 kaoji. All rights reserved.
//

import UIKit
import CoreImage

class QRCodeGenerator: NSObject {
    
    public class func createQRCode(scanResult:String) ->UIImage{
        
        //MARK: -- - 根据扫描结果生成二维码，默认白底黑灰 需要自定义 调用'createCode'方法
        let qrImage  = QRCodeGenerator.createCode(codeType: "CIQRCodeGenerator", codeString: scanResult, size: .init(width: 100, height: 100), qrColor: .darkGray, bkColor: .white)
        return qrImage!
    }

    //MARK: -- - 生成二维码，背景色及二维码颜色设置
    public static func createCode(codeType: String, codeString: String, size: CGSize, qrColor: UIColor, bkColor: UIColor) -> UIImage? {
        let stringData = codeString.data(using: .utf8)

        // 系统自带能生成的码
        //        CIAztecCodeGenerator
        //        CICode128BarcodeGenerator
        //        CIPDF417BarcodeGenerator
        //        CIQRCodeGenerator
        let qrFilter = CIFilter(name: codeType)
        qrFilter?.setValue(stringData, forKey: "inputMessage")
        qrFilter?.setValue("H", forKey: "inputCorrectionLevel")

        // 上色
        let colorFilter = CIFilter(name: "CIFalseColor",
                                   parameters: [
                                       "inputImage": qrFilter!.outputImage!,
                                       "inputColor0": CIColor(cgColor: qrColor.cgColor),
                                       "inputColor1": CIColor(cgColor: bkColor.cgColor),
                                   ]
        )

        guard let qrImage = colorFilter?.outputImage,
        let cgImage = CIContext().createCGImage(qrImage, from: qrImage.extent) else {
            return nil
        }

        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()!
        context.interpolationQuality = CGInterpolationQuality.none
        context.scaleBy(x: 1.0, y: -1.0)
        context.draw(cgImage, in: context.boundingBoxOfClipPath)
        let codeImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return codeImage
    }
    
    class func QRCodeWithText(text: String,barCodeImage :UIImage)-> UIImage {
        
        let size = CGSize.init(width: barCodeImage.size.width, height: barCodeImage.size.height + 20) //比原图高一些以放置文字

        UIGraphicsBeginImageContextWithOptions(size,false,0.0)//初始化画布

        barCodeImage.draw(at: .zero)//把条形码图片添加到画布中

        let context = UIGraphicsGetCurrentContext()//画布上下文

        context!.drawPath(using: .fill)

        let textStyle = NSMutableParagraphStyle()

        textStyle.lineBreakMode = .byWordWrapping
        textStyle.alignment = .center

        (text as NSString).draw(in: CGRect(x: 0,y: size.height - 15,width: size.width,height: 40), withAttributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 13),NSAttributedString.Key.foregroundColor: UIColor.red
        ])
        
        let codeImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return codeImage!
    }
}
