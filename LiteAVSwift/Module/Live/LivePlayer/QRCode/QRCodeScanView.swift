//
//  QRCodeScanView.swift
//  LiteAVSwift
//
//  Created by kaoji on 2020/9/18.
//  Copyright © 2020 kaoji. All rights reserved.
//

import UIKit

class QRCodeScanView: UIView {
    
    var captureSession:QRCapture!
    
      //缩放手势
      lazy var pinchGesture:UIPinchGestureRecognizer = {
          let pinch = UIPinchGestureRecognizer()
          return pinch
      }()
      
      //扫描框
      lazy var scanBorderView:QRSCanBorder = {
        let boderView = QRSCanBorder()
        boderView.contentMode = .scaleAspectFill
        return boderView
      }()
      
      //扫描线条
      lazy var scanLineView:UIImageView = {
          let boderView = UIImageView()
          return boderView
      }()
    
    override init(frame:CGRect) {
        super.init(frame:frame)
        setupQRScanUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupQRScanUI(){
        
        self.backgroundColor = .white
        
        let selfW = self.frame.size.width
        let selfH = self.frame.size.height
        let boderWH = selfW * 0.7
        let boderOriginX = (selfW - boderWH)/2
        let boderOriginY = (selfH - boderWH)/2
        
        scanBorderView.frame = .init(x: boderOriginX, y: boderOriginY, width: boderWH, height: boderWH)
        scanBorderView.layer.frame = scanBorderView.frame
        let boderImage = UIImage.init(contentsOfFile: Bundle.main.path(forResource:"ScanBorder", ofType: "png")!)
        scanBorderView.image = boderImage
        self.addSubview(scanBorderView)
        
        //扫描区域(上下左右)
        let xPosion = (selfH - boderWH) / 2 / selfH
        let yPosion = (selfW - boderWH) / 2 / selfW
        let wPosion = boderWH / selfH
        let hPosion = boderWH / selfW
        let scanRect = CGRect.init(x: xPosion, y: yPosion, width: wPosion, height: hPosion)
        
        //开始扫描动画
        scanBorderView.startQRAnimating()
        
        //添加蒙版 挖空中心
        let digRect = CGRect.init(x: boderOriginX, y: boderOriginY, width: scanBorderView.frame.width, height: scanBorderView.frame.height)
        let path = UIBezierPath.init(rect: self.frame)
        let digPath = UIBezierPath.init(rect: digRect)
        path.append(digPath)
        path.usesEvenOddFillRule = true
        
        let fillLayer = CAShapeLayer()
        fillLayer.path = path.cgPath
        fillLayer.fillRule = .evenOdd
        fillLayer.opacity = 0.5
        fillLayer.backgroundColor = UIColor.black.cgColor
        self.layer.insertSublayer(fillLayer, at: 0)
        
        //开启摄像头扫描
        self.captureSession = QRCapture.init(parentView: self)
        self.captureSession.updateOutputSCanRect(rect: scanRect)
        self.captureSession.startSession()
    }
    
    deinit {
        scanBorderView.stopStepAnimating()
    }
    


    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
         self.scanBorderView.stopStepAnimating()
         self.captureSession.stopSession()
         self.removeFromSuperview()
    }
}
