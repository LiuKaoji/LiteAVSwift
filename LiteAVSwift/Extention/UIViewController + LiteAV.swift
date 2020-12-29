//
//  UIViewController(TRTC).swift
//  LiteAVSwift
//
//  Created by kaoji on 2020/11/30.
//  Copyright © 2020 kaoji. All rights reserved.
//

import UIKit

extension UIViewController{
    
    func setupBackBtn() -> UIButton {
        
        let backBtn = UIButton()
        backBtn.setImage(UIImage.init(named: "navback"), for: .normal)
        //状态栏高度
        let topOffset = UIApplication.shared.statusBarFrame.size.height
        backBtn.frame = .init(x: 10, y: topOffset, width: 40, height: 30)
        self.view.addSubview(backBtn)
        return backBtn
    }
    
    func setuprRightBtn(imageName: String) -> UIButton {
        
        let rightBtn = UIButton()
        rightBtn.setImage(UIImage.init(named: imageName), for: .normal)
        //状态栏高度
        let topOffset = UIApplication.shared.statusBarFrame.size.height
        rightBtn.frame = .init(x: self.view.frame.size.width - 50, y: topOffset, width: 40, height: 40)
        self.view.addSubview(rightBtn)
        return rightBtn
    }
    
    func setupTitleLabel() -> UILabel {
        
        let titleLabel = createLabel(font: .boldSystemFont(ofSize: 18), color: .white, text: "\(ROOM_ID)", alignment: .center)
        //标题位置
        let titleW = self.view.frame.size.width - 100
        let topOffset = UIApplication.shared.statusBarFrame.size.height
        titleLabel.frame = CGRect.init(x: 50, y: topOffset, width: titleW, height: 30)
        titleLabel.textColor = .white
        titleLabel.text = "R:\(ROOM_ID) U:\(USER_ID)"
        self.view.addSubview(titleLabel)
        return titleLabel
    }
    
    func setupTRTC() -> TRTCCloud {
        
        let trtc:TRTCCloud = TRTCCloud.sharedInstance()
        
        /// 视频基本配置
        let encParam = TRTCVideoEncParam()
        encParam.videoResolution = ._640_360
        encParam.videoFps = 18
        encParam.videoBitrate = 800
        encParam.resMode = .portrait

        trtc.setVideoEncoderParam(encParam)
        trtc.setLocalViewFillMode(.fill)
        trtc.setLocalViewMirror(.auto)
        trtc.setGSensorMode(.disable)

        /// 音频配置
        trtc.setAudioRoute(.modeSpeakerphone)


        //流控
        let qosParam = TRTCNetworkQosParam()
        qosParam.preference = .clear
        trtc.setNetworkQosParam(qosParam)
        
        return trtc
    }
    
    func defautTRTCParam()-> TRTCParams{
        
        let param = TRTCParams()
        param.sdkAppId = UInt32(_SDKAppID)
        param.userId = USER_ID
        param.roomId = UInt32(ROOM_ID)
        param.userSig = GenerateTestUserSig.genTestUserSig(param.userId)
        param.privateMapKey = ""
        param.role = .anchor
        return param;
    }
    
    
    func setupLivePush() ->TXLivePush{
        // config初始化
        let config = TXLivePushConfig()
        config.pauseFps = 10
        config.pauseTime = 300
        config.pauseImg = UIImage.init(named: "pause_publish")
        // 推流器初始化
        let pusher:TXLivePush = TXLivePush.init(config: config)
       
        return pusher
    }

}
