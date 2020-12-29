//
//  QRCodeTool.swift
//  LiteAVSwift
//
//  Created by kaoji on 2020/9/18.
//  Copyright © 2020 kaoji. All rights reserved.
//

import UIKit

class QRCodeTool: NSObject {
    typealias QRCodeResult = ((String) -> (Void))
    class func showQRSCan(qrCallback:@escaping QRCodeResult){
    
        let qrScanView = QRCodeScanView.init(frame: UIApplication.shared.keyWindow!.frame)
        qrScanView.captureSession.captureCallback = { result in
            //得到结果震一下
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            //渐渐消失
            UIView.animate(withDuration: 0.2, animations: {
                qrScanView.alpha = 0
            }) { (complete) in
                qrScanView.removeFromSuperview()
            }
            //将扫描结果抛出
            qrCallback(result)
        }
        qrScanView.alpha = 0
        UIView.animate(withDuration: 0.2) {
            qrScanView.alpha = 1
        }
        UIApplication.shared.keyWindow?.addSubview(qrScanView)
    }
}
