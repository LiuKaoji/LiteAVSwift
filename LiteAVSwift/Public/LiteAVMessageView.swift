//
//  LiteAVMessageView.swift
//  LiteAVSwift
//
//  Created by kaoji on 2020/11/24.
//  Copyright © 2020 kaoji. All rights reserved.
//

import UIKit

enum LiteAVMessageStyle: Int {
    case info = 0
    case success = 1
    case warning = 2
    case error   = 3
}

class LiteAVMessageView: NSObject {
    
    class func showMessage(_ title: String,_ body: String,_ style:LiteAVMessageStyle){
        
        
        let view: MessageView = MessageView.viewFromNib(layout: .cardView)
        let iconStyle: IconStyle = .subtle
        switch style {
        case .info:
            view.configureTheme(.info, iconStyle: iconStyle)
            view.accessibilityPrefix = "提示"
        case .success:
            view.configureTheme(.success, iconStyle: iconStyle)
            view.titleLabel?.text = "提示"
        case .warning:
            view.configureTheme(.warning, iconStyle: iconStyle)
            view.accessibilityPrefix = "警告"
        case .error:
            view.configureTheme(.error, iconStyle: iconStyle)
            view.accessibilityPrefix = "错误"
        }
        
        view.titleLabel?.text = title
        view.bodyLabel?.text = body
        view.button?.isHidden = true
        
        var config = SwiftMessages.defaultConfig
        config.presentationContext = .window(windowLevel: UIWindow.Level.statusBar)
        config.duration = .seconds(seconds: 1.2)
        config.dimMode = .color(color: rgba(0, 0, 0, 0), interactive: true)
        SwiftMessages.show(config: config, view: view)
        
    }
}
