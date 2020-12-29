//
//  TRTCRenderVC.swift
//  LiteAVSwift
//
//  Created by kaoji on 2020/9/21.
//  Copyright © 2020 kaoji. All rights reserved.
//

import UIKit

class RenderVC: UIViewController,TRTCVideoRenderDelegate,TRTCCloudDelegate,TRTCVideoFrameDelegate {
    
    //自定义渲染视图
    lazy var renderView :GLView = {
        let render = GLView.init(frame: self.view.frame)
        return render
    }()
    
    //简约测试滤镜
    lazy var sFilter :RenderFilter = {
       let filter = RenderFilter()
       return filter
    }()
    
    //是否开启滤镜
    lazy var filterSegment:UISegmentedControl = {
        let segment = UISegmentedControl.init(items: ["原始","滤镜"])
        segment.selectedSegmentIndex = 1;
        segment.tintColor = rgba(15, 168, 45, 1.0);
        segment.setTitleTextAttributes([.foregroundColor:rgba(15, 168, 45, 1.0)], for: .normal)
        segment.addTarget(self, action: #selector(onClickFilter), for: .valueChanged)
        return segment
    }()
    
    //标题与返回
    lazy var backBtn = self.setupBackBtn()
    lazy var titleLabel = self.setupTitleLabel()
    lazy var trtc = self.setupTRTC()
    
    //成员视图,只支持一个
    var linkMicView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        startTRTC()
    }
    
    func startTRTC(){
        
        self.titleLabel.text = "美颜老接口-\(ROOM_ID)"
        
        navigationController?.navigationBar.barStyle = .black
        self.view.backgroundColor = .white
        //添加自定义渲染视图
        self.view.insertSubview(renderView, at:0)
        
        //link Mic
        linkMicView = UIView.init(frame: LiveFloatWindow.getFlowSourceRect(souceRect: self.view.frame))
        linkMicView.backgroundColor = .clear
        renderView.addSubview(linkMicView)
        
        self.backBtn.addTarget(self, action: #selector(onClickBack), for: .touchUpInside)
        
        //添加滤镜开关
        filterSegment.frame = .init(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height - (isBangDevice ?34:10) - 40, width: 150, height: 40)
        self.view.addSubview(filterSegment)
        
        //启动音视频
        trtc.startLocalPreview(true, view: self.view)
        //trtc.startLocalAudio()
        
        //开启自定义采集
        trtc.setLocalVideoRenderDelegate(self, pixelFormat: ._NV12, bufferType: .pixelBuffer)
        setExperiment("setCustomRenderMode", params: ["mode":1])
        
        trtc.delegate = self
        
        //进房
        trtc.enterRoom(self.defautTRTCParam(), appScene: .videoCall)
        
    
    }
    
    func onRenderVideoFrame(_ frame: TRTCVideoFrame, userId: String?, streamType: TRTCVideoStreamType) {
        //原始
        if filterSegment.selectedSegmentIndex == 0 {
            renderView.render(frame)
            return
        }
        //滤镜
        let filtedImage = sFilter.filterFrame(frame)
        sFilter.ciContext.render(filtedImage, to: frame.pixelBuffer!)
        renderView.renderCIImage(filtedImage)
    }

    
    func onUserVideoAvailable(_ userId: String, available: Bool) {
        //TODO: to do
        debugPrint("onUserVideoAvailable:\(userId) available:\(available)")
//        if available {
//            trtc.startRemoteView(userId, view: linkMicView)
//        }
//        else{
//            trtc.stopRemoteView(userId)
//        }
    }
    

    

    @objc func onClickFilter(){}
    
    @objc func onClickBack(){
        self.navigationController?.popViewController(animated: true)
        
        trtc.stopLocalAudio()
        trtc.stopLocalPreview()
        trtc.exitRoom()
    }

    deinit {
        TRTCCloud.destroySharedIntance()
    }
   
}
