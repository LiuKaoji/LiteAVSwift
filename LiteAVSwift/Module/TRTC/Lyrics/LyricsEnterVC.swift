//
//  LyricsEnterVCViewController.swift
//  LiteAVSwift
//
//  Created by kaoji on 2021/1/26.
//  Copyright © 2021 kaoji. All rights reserved.
//

import UIKit

class LyricsEnterVC: RoomEnterVC {

    override func joinRoom(){
        
        let roomId = (nRoomView.roomIDTextField.text?.count)! > 0 ?nRoomView.roomIDTextField.text:nRoomView.roomIDTextField.placeholder
        let userId = (nRoomView.usrIDTextField.text?.count)! > 0 ?nRoomView.usrIDTextField.text:nRoomView.usrIDTextField.placeholder
        UserDefaults.standard.setValue(roomId, forKey: "ROOMID")
        
        let param = TRTCParams()
        param.sdkAppId = UInt32(_SDKAppID)
        param.userId = userId!
        param.roomId = UInt32(roomId!)!
        param.userSig = GenerateTestUserSig.genTestUserSig(userId!)
        param.privateMapKey = ""
        param.role = TRTCRoleType(rawValue: nRoomView.roleInputView.segment.selectedSegmentIndex + 20) ?? .anchor
        
        let lrcVC =  LyricsVC.init(rtcParam: param)
        self.navigationController?.pushViewController(lrcVC, animated: true)
 
    }
    
}
