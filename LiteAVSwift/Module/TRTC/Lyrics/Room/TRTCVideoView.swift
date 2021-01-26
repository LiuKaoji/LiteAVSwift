//
//  TRTCVideoView.swift
//  TRTCSwift
//
//  Created by kaoji on 2020/5/5.
//  Copyright © 2020 kaoji. All rights reserved.
//

import UIKit

@objc public protocol TRTCVideoViewDelegate {
    func onTapVideoView(userId:String)
}

class TRTCVideoView: UIImageView,UIGestureRecognizerDelegate {

    weak var tapDelegate: TRTCVideoViewDelegate?
    
    lazy var qualutyImages:Dictionary<TRTCQuality,String> = [
        TRTCQuality.down:"signal5",
        TRTCQuality.vbad:"signal5",
        TRTCQuality.bad:"signal4",
        TRTCQuality.poor:"signal3",
        TRTCQuality.good:"signal2",
        TRTCQuality.excellent:"signal1",
    ]
    
    //画面配置
    var userId = "0"
    var type:VideoViewAreaType = .local
    var sizeType:videoViewSizeType? {
        didSet{
            self.updateNetIndicateTop()
        }
    }
    var enableMove = false
    var streamType:Int = 0
    var touchPoint:CGPoint = .zero
    var tapGesture = UITapGestureRecognizer()
    var qualityInfo:TRTCQualityInfo?
    var isAvailible:Bool = true {
        willSet{
            //仅当值改变时才做这个操作 有可能会layout几次
            isAvailible != newValue ?self.showVideoCloseTip(show: isAvailible):nil
        }
    }
    
    //UI
    lazy var btnMuteVideo: UIButton = {
        let btn = createIconBtn(icon: UIImage.init(named: "muteVideo")!)
        addSubview(btn)
        return btn
    }()
    
    lazy var btnMuteAudio: UIButton = {
        let btn = createIconBtn(icon: UIImage.init(named: "muteAudio")!)
        addSubview(btn)
        return btn
    }()
    
    lazy var btnScaleMode: UIButton = {
        let btn = createIconBtn(icon: UIImage.init(named: "scaleFill")!)
        addSubview(btn)
        return btn
    }()
    
    lazy var closeView: UIView = {
        
        let tipBgView = createView(bgColor: .darkGray)
        faceImageView = createImageView(image: UIImage.init(named: "VideoClosed")!, mode: .scaleAspectFit, interface: false)
        faceImageView.center = .init(x: tipBgView.center.x, y: tipBgView.center.y)
        
        uidLabel = createLabel(font: .systemFont(ofSize: 15), color: .lightText, text: self.userId, alignment: .center)
        
        let prefix = (type == .local) ?"您自己":""
        let uidText = prefix + "视频已关闭"
        closeLabel = createLabel(font: .systemFont(ofSize: 15), color: .lightText, text: uidText, alignment: .center)
        
        self.insertSubview(tipBgView, at: 0)
        tipBgView.addSubview(faceImageView)
        tipBgView.addSubview(uidLabel)
        tipBgView.addSubview(closeLabel)
        
        tipBgView.snp.makeConstraints { (make) in
            make.left.top.width.height.equalToSuperview()
        }
        
        faceImageView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-20)
            make.width.height.equalTo(self.snp.width).multipliedBy(0.3)
        }
        
        uidLabel.snp.makeConstraints { (make) in
            make.top.equalTo(faceImageView.snp.bottom).offset(10)
            make.left.width.equalToSuperview()
            make.height.equalTo(uidLabel.font.pointSize)
        }
        
        closeLabel.snp.makeConstraints { (make) in
            make.top.equalTo(uidLabel.snp.bottom).offset(10)
            make.left.width.equalToSuperview()
            make.height.equalTo(uidLabel.font.pointSize)
        }
        
        return tipBgView
    }()
    
    
    
    class func getNewVideoView(type:VideoViewAreaType,userId:String) ->TRTCVideoView{
        let videoView  = TRTCVideoView()
        videoView.type = type
        videoView.userId = userId
        if type == .local {
            videoView.hideButtons(isHidden: true)
            videoView.audioVolumeIndicator.isHidden = true
        }
        videoView.isUserInteractionEnabled = true
        //videoView.backgroundColor = UIColor.init(red:CGFloat(arc4random_uniform(255))/CGFloat(255.0), green:CGFloat(arc4random_uniform(255))/CGFloat(255.0), blue:CGFloat(arc4random_uniform(255))/CGFloat(255.0) , alpha: 1)
        videoView.backgroundColor = .darkGray
        videoView.tapGesture.delegate = videoView
        videoView.tapGesture.addTarget(videoView, action: #selector(onTapVideoView))
        videoView.addGestureRecognizer(videoView.tapGesture)
        let panGesture = UIPanGestureRecognizer(target: videoView, action: #selector(panAction(_ :)))
        videoView.addGestureRecognizer(panGesture)
        
        videoView.networkIndicator.snp.makeConstraints { (make) in
            make.top.equalTo(videoView.snp.top).offset(videoView.frame.size == UIScreen.main.bounds.size ?STATUSBAR_HEIGHT+10:0)
            make.right.equalToSuperview().offset(-15)
            make.width.equalTo(20)
            make.height.equalTo(24)
        }
        
        return videoView
    }

    
    lazy var audioVolumeIndicator: UIProgressView = {
        let progressView = UIProgressView()
        //addSubview(progressView)
        return progressView
    }()
    
    lazy var networkIndicator:UIImageView = {
        let indicate = UIImageView()
        indicate.contentMode = .scaleAspectFit
        self.addSubview(indicate)
        return indicate
    }()
    
    //var tipBgView:UIView!
    var faceImageView:UIImageView!
    var uidLabel:UILabel!
    var closeLabel:UILabel!
    
    var netTranslation:CGPoint!//平移

    func hideButtons(isHidden:Bool){
        btnMuteVideo.isHidden = isHidden
        btnMuteAudio.isHidden = isHidden
        btnScaleMode.isHidden = isHidden
    }

    func updateNetworkIndicatorImage() {
        let quality = self.qualityInfo?.quality ?? TRTCQuality.unknown
        if quality == .unknown {
            networkIndicator.image = nil
            return
        }
        networkIndicator.image = UIImage.init(named: self.qualutyImages[self.qualityInfo!.quality]!)
    }
    
    func setAudioVolumeRadio(volumeRadio:Float){
        audioVolumeIndicator.progress = volumeRadio
    }
    
    func showVideoCloseTip(show:Bool){
        
        closeView.isHidden = !show
    }
    
    func showAudioVolume(show:Bool){
        self.audioVolumeIndicator.isHidden = !show
    }
    
    func showNetworkIndicatorImage(show:Bool){
        self.networkIndicator.isHidden = !show
    }
    
    func updateNetIndicateTop() {
        networkIndicator.snp.updateConstraints { (make) in
            make.top.equalTo(self.snp.top).offset((sizeType == .big) ?STATUSBAR_HEIGHT+10:0)
            make.right.equalTo(self.snp.right).offset((sizeType == .big) ? -15:-5)
        }
    }
    
    
    @objc func panAction(_ pan:UIPanGestureRecognizer){
        
        //确保重叠时始终在最前面 划到别人底部 不太好看
        if pan.state == .began && (self.frame != UIScreen.main.bounds){
            self.superview!.bringSubviewToFront(self)
        } else if pan.state == .changed{
            
            let translation = pan.translation(in: self.superview)
            
            //防止左右滑出边界
            let maxX  = (self.superview?.frame.size.width)! - self.frame.size.width/2
            let moveX = CGFloat.maximum(self.frame.size.width/2, CGFloat.minimum(maxX, self.center.x + translation.x))
            
            //防止上下滑出边界
            let maxY  = (self.superview?.frame.size.height)! - self.frame.size.height/2
            let moveY = CGFloat.maximum(self.frame.size.height/2, CGFloat.minimum(maxY, self.center.y + translation.y))
            
            self.center = CGPoint(x: moveX, y: moveY)
            pan.setTranslation(CGPoint.zero, in: self.superview)
        }
        //结束时弹一弹
        else if pan.state == .ended {
            
            guard (self.frame != UIScreen.main.bounds) else { return }
            self.bounceAnimation()
        }

    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    @objc func onTapVideoView(){
        
        if (self.tapDelegate != nil){
            self.tapDelegate?.onTapVideoView(userId: self.userId)
        }
    }
}
