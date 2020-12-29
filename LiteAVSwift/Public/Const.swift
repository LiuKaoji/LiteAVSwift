//
//  Common.swift
//  LiteAVSDKDemo
//
//  Created by Kaoji on 2020/4/5.
//  Copyright © 2020 by Kaoji. All rights reserved.
//

@_exported import SnapKit
@_exported import RxSwift
@_exported import RxCocoa
@_exported import RxDataSources
@_exported import RxRelay
@_exported import TXLiteAVSDK_Professional
@_exported import SwiftMessages

// MARK: - 当播放BGM时 默认资源是本地还是预设线上
//true:使用本地音乐
//false:使用线上音乐
let isOnlineBGMTest = true

// MARK: - 适配
let SCREEN_WIDTH = UIScreen.main.bounds.size.width//屏幕宽度
let SCREEN_HEIGHT = UIScreen.main.bounds.size.height//屏幕高度
let NAV_HEIGHT : CGFloat = isBangDevice ? 88 : 64
let TAB_HEIGHT : CGFloat = isBangDevice ? 83 : 49
let STATUSBAR_HEIGHT : CGFloat = NAV_HEIGHT - 44
let Key_Window = UIApplication.shared.keyWindow
let lessThanIphone6 = SCREEN_HEIGHT < 667 ?true:false
let commonMargin = 16
//-mark 提示类
let networkNoGood = "网络不佳，换个姿势再来~"

//是否刘海屏
var isBangDevice: Bool {
    if #available(iOS 11, *) {
        guard let w = UIApplication.shared.delegate?.window, let unwrapedWindow = w else {
            return false
        }
        if unwrapedWindow.safeAreaInsets.left > 0 || unwrapedWindow.safeAreaInsets.bottom > 0 {
            print(unwrapedWindow.safeAreaInsets)
            return true
        }
    }
    return false
}


//-mark 沙盒
let DOC_PATH = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0] + "/"
let CACHE_PATH = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0]
let TEMP_PATH = NSTemporaryDirectory()
let LOG_PATH = DOC_PATH + "log/"



// MARK: - 颜色
func rgba(_ R:CGFloat,_ G:CGFloat,_ B:CGFloat,_ A:CGFloat) -> UIColor {
    return UIColor.init(red: R/255.0, green: G/255.0, blue: B/255.0, alpha: A)
}

func rgb(_ R:CGFloat,_ G:CGFloat,_ B:CGFloat) -> UIColor {
    return UIColor.init(red: R/255.0, green: G/255.0, blue: B/255.0, alpha: 1.0)
}

// MARK: - TRTC隐藏API
func setExperiment(_ key: String, params: Dictionary<String,Any>){
    //将数据包装 通过隐藏接口发送给SDK
    let json = ["api":key,"params":params] as [String : Any]
    let jsonData: Data! = try? JSONSerialization.data(withJSONObject: json, options: [])
    let jsonStr = String(data: jsonData, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
    TRTCCloud.sharedInstance().callExperimentalAPI(jsonStr)
}
