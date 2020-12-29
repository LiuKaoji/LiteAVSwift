//
//  QRCapture.swift
//  LiteAVSwift
//
//  Created by kaoji on 2020/9/18.
//  Copyright © 2020 kaoji. All rights reserved.
//

import UIKit


class QRCapture: NSObject,AVCaptureMetadataOutputObjectsDelegate {
    
    //返回扫描结果
    typealias AVCaptureMetaResult = ((String) -> (Void))
    
    var captureCallback:AVCaptureMetaResult?
    
    //打开视频设备
    lazy var captureDevice:AVCaptureDevice = {
        let device = AVCaptureDevice.default(for: .video)
        return device!
    }()
    
    //设备输入类
    lazy var captureInput:AVCaptureDeviceInput = {
        let inputer = try? AVCaptureDeviceInput.init(device: captureDevice)
        return inputer!
    }()
    
    //打开MetadataOutput以获取扫描信息
    lazy var captureOutput:AVCaptureMetadataOutput = {
        let outputer = AVCaptureMetadataOutput()
        outputer.setMetadataObjectsDelegate(self, queue: .main)
        return outputer
    }()
    
    //会话
    lazy var captureSession:AVCaptureSession = {
        let session = AVCaptureSession()
        session.sessionPreset = .high
        if(session.canAddInput(captureInput)){
            session.addInput(captureInput)
        }
        if(session.canAddOutput(captureOutput)){
            session.addOutput(captureOutput)
            self.captureOutput.metadataObjectTypes = [.ean13, .ean8, .code128, .qr]
        }
        return session
    }()
    
    //预览图层
    lazy var previewLayer:AVCaptureVideoPreviewLayer = {
        let preview = AVCaptureVideoPreviewLayer.init(session: captureSession)
        return preview
    }()
    
    
    convenience init(parentView:UIView) {
        self.init()
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        if status == .authorized {
            setupCapture(containView:parentView)
        }
    }
    
    
    //配置启动Session
    func setupCapture(containView:UIView){
        self.captureSession.commitConfiguration()
        self.previewLayer.frame = containView.frame
        previewLayer.videoGravity = .resize
        previewLayer.backgroundColor = UIColor.red.cgColor
        containView.layer.insertSublayer(previewLayer, at: 0)
    }
    
    //更新(限制)扫描范围,通常二维码需要限制只扫描 扫描框 内的内容
    func updateOutputSCanRect(rect:CGRect){
        captureOutput.rectOfInterest = rect
    }
    
    //开启
    func startSession(){
        guard !self.captureSession.isRunning else { return }
        self.captureSession.startRunning()
    }
    
    //停止
    func stopSession(){
        guard self.captureSession.isRunning else { return }
        previewLayer.removeFromSuperlayer()
        self.captureSession.stopRunning()
    }
    
    // MARK:- AVCaptureMetadataOutputObjectsDelegate
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        if metadataObjects.count < 0 || captureCallback == nil{
            return
        }
        
        //将扫描结果抛出
        let metadataObject = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        if metadataObject.isKind(of: AVMetadataMachineReadableCodeObject.classForCoder()) {
            
            let resultString = metadataObject.stringValue
            if resultString?.count ?? 0 > 0 {
                self.captureSession.stopRunning()
                captureCallback!(resultString!)
                debugPrint("扫描结果\(resultString!)")
            }
        }
        
    }
}
