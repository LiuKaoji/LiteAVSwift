//
//  CaptureVC.swift
//  LiteAVSwift
//
//  Created by kaoji on 2020/11/10.
//  Copyright © 2020 kaoji. All rights reserved.
//

import UIKit
import GPUImage


class CaptureVC: LiteAVBeautyBaseVC {

    override func viewDidLoad() {
        
        self.outputType = .pixel
        
        super.viewDidLoad()
        
        self.titleLabel.text = "自定义采集-\(ROOM_ID)"

        navigationController?.navigationBar.barStyle = .black
        self.view.backgroundColor = .black
        
        self.backBtn.addTarget(self, action: #selector(onClickBack), for: .touchUpInside)
        
        trtc = self.setupTRTC()
        
        /// 开启自定义采集 SDK音频采集 进房
        trtc.enableCustomVideoCapture(true)
        trtc.startLocalAudio()
        trtc.enterRoom(self.defautTRTCParam(), appScene: .LIVE)
        
        //额外的配置测试
//        let encodeEx = Bundle.main.path(forResource: "VideoEncEx", ofType: "plist")
//        let encodeExDict: Dictionary = NSDictionary.init(contentsOfFile: encodeEx!) as! Dictionary<String, Any>
//        trtc.callExperimentalAPI(encodeExDict.toString(dictionary: encodeExDict))
    }
    
    override func beautyOutputPixelBuffer(_ pixelBuffer: CVPixelBuffer!) {
          
        let frame = TRTCVideoFrame()
        frame.pixelFormat = ._32BGRA
        frame.bufferType  = .pixelBuffer
        frame.pixelBuffer = pixelBuffer
        frame.timestamp = 0
        trtc.sendCustomVideoData(frame)
    }

    @objc override func onClickBack(){
        
        camera?.removeAllTargets()
        camera?.stopCapture()
        trtc.stopLocalAudio()
        trtc.exitRoom()
        
        self.navigationController?.popViewController(animated: true)
    }

    deinit {
        TRTCCloud.destroySharedIntance()
    }

}


