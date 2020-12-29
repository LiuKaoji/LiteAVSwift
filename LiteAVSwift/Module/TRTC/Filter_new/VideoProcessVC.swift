//
//  VideoProcessVC.swift
//  LiteAVSwift
//
//  Created by kaoji on 2020/12/15.
//  Copyright © 2020 kaoji. All rights reserved.
//

import UIKit


class VideoProcessVC: UIViewController,TRTCCloudDelegate,TRTCVideoFrameDelegate {
    
    //MARK:  UI
    var linkMicView: UIView!///连麦
    lazy var backBtn = self.setupBackBtn()///返回
    lazy var titleLabel = self.setupTitleLabel()///房间名
    lazy var trtc = self.setupTRTC()///TRTC初始化
    
    lazy var processTypeSelector:UISegmentedControl = {
        let segment = UISegmentedControl.init(items: ["纹理","NV12","BGRA","I420"])
        segment.selectedSegmentIndex = 0;
        segment.tintColor = rgba(15, 168, 45, 1.0);
        segment.setTitleTextAttributes([.foregroundColor:rgba(15, 168, 45, 1.0)], for: .normal)
        segment.addTarget(self, action: #selector(onClickFilter), for: .valueChanged)
        return segment
    }()///回调类型选择
    
    lazy var lutTipLabel: UILabel = {
        let lutLabel = createLabel(font: .systemFont(ofSize: 13), color: .white, text: "单击空白处选择效果", alignment: .center)
        lutLabel.frame = .init(x: 0, y: processTypeSelector.frame.minY - 20, width: SCREEN_WIDTH, height: 20)
        self.view.addSubview(lutLabel)
        return lutLabel
        
    }()///提示NV12和BGRA时选择滤镜类型
    

    //MARK: 处理数据对象
    lazy var lutSelector: LUTCIFilterContainer = {
        let filter = LUTCIFilterContainer.init(lutName: "")
       return filter
    }()///LUT滤镜选择
    
    lazy var textureProccessor: TextureProcessor = {
        return TextureProcessor()
    }()///纹理

    override func viewDidLoad() {
        super.viewDidLoad()
        startTRTC()
    }
    
    func startTRTC(){
        
        self.titleLabel.text = "美颜新接口-\(ROOM_ID)"
        
        navigationController?.navigationBar.barStyle = .black
        self.view.backgroundColor = .white
        
        //link Mic
        linkMicView = UIView.init(frame: LiveFloatWindow.getFlowSourceRect(souceRect: self.view.frame))
        linkMicView.backgroundColor = .clear
        self.view.addSubview(linkMicView)
        
        self.backBtn.addTarget(self, action: #selector(onClickBack), for: .touchUpInside)
        
        //添加滤镜开关
        processTypeSelector.frame = .init(x: self.view.frame.size.width/2 - 150, y: self.view.frame.size.height - (isBangDevice ?34:10) - 40, width: 300, height: 40)
        self.view.addSubview(processTypeSelector)
        
        //启动音视频
        trtc.delegate = self
        
        trtc.startLocalPreview(true, view: self.view)
        trtc.startLocalAudio()
       
        
        //开启新的美颜接口
        self.processTypeSelector.selectedSegmentIndex = 2//->指定先开BGRA
        self.onClickFilter()
        
        //进房
        trtc.enterRoom(self.defautTRTCParam(), appScene: .LIVE)
    
    }
    
    //MARK: - video process delegate
    func onProcessVideoFrame(_ srcFrame: TRTCVideoFrame, dstFrame: TRTCVideoFrame) -> UInt32 {
        
        if (srcFrame.pixelFormat == ._Texture_2D) {

            let size = CGSize.init(width: CGFloat(srcFrame.width), height: CGFloat(srcFrame.height))
            dstFrame.textureId = textureProccessor.renderToTextureWithSize(size, srcFrame.textureId)
        }
        
        else if (srcFrame.pixelFormat == ._NV12 || srcFrame.pixelFormat == ._32BGRA) {
            
            lutSelector.processFrameBuffer(src: srcFrame, dst: dstFrame)
            
        } else if (srcFrame.pixelFormat == ._I420) {
            /// Bad Case CoreImage不支持 此处略过
            dstFrame.pixelBuffer = srcFrame.pixelBuffer;
        }
        
        
        return 0
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
    

    @objc func onClickFilter(){
        
        let selectedIndex = processTypeSelector.selectedSegmentIndex
        lutTipLabel.isHidden = !(selectedIndex == 1 || selectedIndex == 2)
        
        if self.processTypeSelector.selectedSegmentIndex == 0 {
            
            trtc.setLocalVideoProcessDelegete(self, pixelFormat: ._Texture_2D, bufferType: .texture)
            
        }else if self.processTypeSelector.selectedSegmentIndex == 1{
            
            trtc.setLocalVideoProcessDelegete(self, pixelFormat: ._NV12, bufferType: .pixelBuffer)
            
        }else if self.processTypeSelector.selectedSegmentIndex == 2{
            
            trtc.setLocalVideoProcessDelegete(self, pixelFormat: ._32BGRA, bufferType: .pixelBuffer)
            
        }else if self.processTypeSelector.selectedSegmentIndex == 3{
            
            trtc.setLocalVideoProcessDelegete(self, pixelFormat: ._I420, bufferType: .pixelBuffer)
            
        }
        
    }
    
    @objc func onClickBack(){
        
        trtc.stopLocalAudio()
        trtc.stopLocalPreview()
        trtc.exitRoom()
        
        self.navigationController?.popViewController(animated: true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let selectedIndex = processTypeSelector.selectedSegmentIndex
        guard selectedIndex == 1 || selectedIndex == 2  else {
            return
        }
        
        lutSelector.showLUTSelectView(sender: self)
    }
    
    deinit {
        TRTCCloud.destroySharedIntance()
    }
}
