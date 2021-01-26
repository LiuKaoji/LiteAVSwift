//
//  TRTCVideoViewLayout.swift
//  TRTCSwift
//
//  Created by kaoji on 2020/7/22.
//  Copyright © 2020 kaoji. All rights reserved.
//

import UIKit
import SnapKit

//规则
//1.默认本地大画面
//2.新进变大画面
//3.大画面离开,最后一个进房变成大画面,最后是本地

struct VideoLayoutModel {
    
    //视图
    var player:TRTCVideoView!
    //视频流来源
    var source:TRTCVideoSource!
    //远程还是本地画面
    var videoArea:VideoViewAreaType!
    //是大窗口还是小窗口
    var videoSizeType:videoViewSizeType!{
        didSet{
            self.player.sizeType = self.videoSizeType
        }
    }
    //是否开启视频推流
    var availible:Bool!
    //用户Id
    var userId:String!
    
    //进房时间
    var enterRoomTime:TimeInterval!
    
    init(areaType:VideoViewAreaType,userId:String,vSize:videoViewSizeType,isAvailible:Bool,vSource:TRTCVideoSource) {
        self.player         = TRTCVideoView.getNewVideoView(type: areaType, userId: userId)
        self.source         = vSource
        self.videoArea      = areaType
        self.availible      = isAvailible
        self.userId         = userId
        self.videoSizeType  = vSize
        self.player.isUserInteractionEnabled = true
        self.enterRoomTime = Date().timeIntervalSince1970
    }
}


class TRTCVideoViewLayout: NSObject {
    
    let VSPACE:CGFloat = 10.0
    let HSPACE:CGFloat = 20.0
    let MARGIN:CGFloat = 10.0
    
    var view:UIView!
    let positionData = [8,5,2,6,3,0,0,3,4,1]
    var type:TCLayoutType! = .TC_Float{
        didSet{
            adjustBigAndSmallQueueWithAnimation()
        }
    }
    
    var subViews = Array<VideoLayoutModel>()
    var gridFrames:Array<CGRect>!
    var bigFrame:CGRect!
    var localUserId:String = ""
    var dashboardTopMargin:CGFloat = 0.15
    
    func setupFrames(){
        //主画面尺寸
        bigFrame = UIApplication.shared.keyWindow?.frame
        gridFrames = Array<CGRect>()
        //计算好九宫格位置
        for i in 0 ..< 9{
            gridFrames.append(grid(total: 9, at: positionData[i]))
        }
    }
    
    // 将view等分为total块，处理好边距
    func grid(total:Int,at:Int) ->CGRect{
        
        var atRect:CGRect = .zero
        let H:CGFloat = self.view.frame.size.height
        let W:CGFloat = self.view.frame.size.width
        
        
        atRect.size.width = (W - 2 * HSPACE - 2 * MARGIN) / 3
        atRect.size.height = FitH(rect: atRect)
        if (at / 3 == 0) {
            atRect.origin.y = H/2 - atRect.size.height/2 - VSPACE - atRect.size.height
        } else if (at / 3 == 1) {
            atRect.origin.y = H/2 - atRect.size.height/2
        } else {
            atRect.origin.y = H/2 + atRect.size.height/2 + VSPACE
        }
        
        if (at % 3 == 0) {
            atRect.origin.x = MARGIN
        } else if (at % 3 == 1) {
            atRect.origin.x = W/2 - atRect.size.width/2
        } else {
            atRect.origin.x = W - atRect.size.width - MARGIN
        }
        return atRect
    }
    
    func FitH(rect:CGRect) -> CGFloat{
        return (rect.size.width / 9.0) * 16
    }
    
    ///MARK:-排序
    func sortSmallViews(){
        
        subViews = subViews.sorted(by: { (dateOne, dateTwo) -> Bool in
            return dateOne.enterRoomTime < dateTwo.enterRoomTime
        })
    }
    
    //调整大画面和小画面
    func adjustBigAndSmallQueueWithAnimation(){
        UIView .animate(withDuration: 0.25) {
            self.commitChangeLayout()
        }
    }
    
    func commitChangeLayout(){
        //房间没有人
        if(self.subViews.count == 0){return}
        
        //房间只有一个人
        if(self.subViews.count == 1){
            self.subViews[0].player.frame = bigFrame;
            self.subViews[0].videoSizeType = .big
            self.view.addSubview(self.subViews[0].player)
            self.view.sendSubviewToBack(self.subViews[0].player)
            
        }else{
            sortSmallViews()
            
            for i in 0...(self.subViews.count - 1) {
                
                self.view.addSubview(self.subViews[i].player)
                //最后一名大画面
                if(i == self.subViews.count - 1) {
                    self.subViews[i].videoSizeType = .big
                    self.subViews[i].player.frame = bigFrame;
                    self.view.sendSubviewToBack(self.subViews[i].player)
                }
                    //小画面
                else{
                    self.subViews[i].videoSizeType = .small
                    self.subViews[i].player.frame = self.gridFrames[i];
                }
            }
        }
        
        adjustDebugMargin()
    }
    
    func adjustDebugMargin(){
        
        // 更新 dashboard 边距
        let margin = UIEdgeInsets(top: dashboardTopMargin,  left: 0, bottom: 0, right: 0);

        for playerModel in self.subViews {
            if(playerModel.videoSizeType == .big){
                TRTCCloud.sharedInstance()?.setDebugViewMargin(playerModel.userId, margin: margin)
                continue;
            }
            TRTCCloud.sharedInstance()?.setDebugViewMargin(playerModel.userId, margin: .zero)
        }
        
    }
}

extension TRTCVideoViewLayout{
    
    //用户进入
    func userAvailibleLayout(videoModel:VideoLayoutModel){
        adjustBigAndSmallQueueWithAnimation()
    }
    
    //用户离开
    func userLeaveLayout(videoModel:VideoLayoutModel){
        //移除Model
        self.subViews.removeAll { (item) -> Bool in
            let isMatch = (item.userId == videoModel.userId)
            return isMatch
        }
        videoModel.player.removeFromSuperview()
        //最后一个进房且有画面的变成大画面 都没有开的话 不变
        adjustBigAndSmallQueueWithAnimation()
    }
    
    //切换画面大小
    func exchangeSmallToBig(smallModel:VideoLayoutModel){
        
        //不是小画面
        if smallModel.videoSizeType == .big {return}
        var smallIndex = 0
        var bigIndex = 0
        for i in 0...(self.subViews.count - 1) {
            //小画面
            if(subViews[i].userId == smallModel.userId){smallIndex = i}
            //大画面
            if(subViews[i].videoSizeType == .big){bigIndex = i}
        }
        
        UIView.animate(withDuration: 0.25) {
            //交换大小画面
            self.subViews[bigIndex].videoSizeType = .small
            self.subViews[smallIndex].videoSizeType = .big
            self.subViews[bigIndex].player.frame = self.subViews[smallIndex].player.frame
            self.subViews[smallIndex].player.frame = self.bigFrame
            self.view.sendSubviewToBack(self.subViews[smallIndex].player)
        }
        
        adjustDebugMargin()
    }
    
    //此用户是否存在
    func isInRoom(userId:String)->VideoLayoutModel?{
        for playerModel in self.subViews {
            if(playerModel.userId == userId){return playerModel}
        }
        return nil
    }
}
