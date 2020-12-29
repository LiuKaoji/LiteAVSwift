//
//  AppDelegate.swift
//  LiteAVSDKDemo
//
//  Created by Kaoji on 2020/4/4.
//  Copyright © 2020 by Kaoji. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
//import UserNotifications

#if arch(arm64)
    import XlogPlugin
#endif

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,UNUserNotificationCenterDelegate {


    var window: UIWindow?
    let mainVC = MainViewController()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        //输入文本自动适应键盘高度
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = true
        
        //注册本地通知
//        UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.sound,.badge]) { (isAuthed, error) in}
//        UNUserNotificationCenter.current().delegate = self
        
        //窗口
        window = UIWindow.init(frame: UIScreen.main.bounds)
        let nav = UINavigationController.init(rootViewController: mainVC)
        window?.rootViewController = nav;
        window?.makeKeyAndVisible()
        
        //SDK Licence 初始化
        setuLiteAVSDK()
        
        let finalB = GenerateTestUserSig.genTestUserSig("123")
        debugPrint(finalB)
        
        return true
    }


    func setuLiteAVSDK(){
        
        ///直播证书==>https://cloud.tencent.com/document/product/454/34750
        let licence = <#T##licence: String###>
        let licenceKey = <#T##licenceKey: String###>
        TXLiveBase.setLicenceURL(licence, key: licenceKey)

        #if arch(arm64)
            XlogManager.shared().setup {
                debugPrint("xlogPlugin State:\(XlogManager.shared().xStatus.rawValue)")
                if(XlogManager.shared().xStatus == .OK){
                    XlogManager.shared().showFloatButton(in: self.mainVC.view)
                }
            }
        #endif

    }
    
}

