//
//  LiveQRCodeVC.swift
//  LiteAVSwift
//
//  Created by kaoji on 2020/12/4.
//  Copyright © 2020 kaoji. All rights reserved.
//

import UIKit

typealias QRCodeRequsetAlias = (_ pushURL: String, _ qrParams: Dictionary<String, String>) -> Void
typealias QRCodeRetryAlias = () -> Void

class LiveQRCodeVC: UIViewController {
    
    var viewContainer: UIView!
    var qrKeys: Array<String>!
    var qrParams: Dictionary<String, String>!
    
    convenience init(keys:Array<String>,params:Dictionary<String,String>) {
        self.init()
        self.qrKeys = keys
        self.qrParams = params
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }

    func setupView(){
        
        var codeViews = Array<UIView>()
        
        for key in qrKeys {
            
            let image = QRCodeGenerator.createQRCode(scanResult: qrParams[key]!)
            let textCode = QRCodeGenerator.QRCodeWithText(text: key, barCodeImage: image)
            let imageView = UIImageView.init(image: textCode)
            imageView.contentMode = .scaleAspectFit
            self.view.addSubview(imageView)
            codeViews.append(imageView)
        }
        
        codeViews.snp.distributeSudokuViews(verticalSpacing: 10, horizontalSpacing: 10, warpCount: 2)
    }

    //使用SwiftMessage框架弹出控制器
    func show(_ sender: UIViewController){
        
        let containerWH = SCREEN_WIDTH * 0.8
        
        self.preferredContentSize = .init(width: containerWH, height: containerWH + 20)
        
        let segue = SwiftMessagesSegue(identifier: nil, source: sender, destination: self)
        segue.duration = .forever
        segue.presentationStyle = .center
        segue.dimMode = .gray(interactive: true)
        segue.perform()
    }
}

extension LiveQRCodeVC{
    
    /// 获取测试推拉流地址
  class func getURLs(qrCallBack: @escaping QRCodeRequsetAlias,retryCallback: @escaping QRCodeRetryAlias){
        
        //获取测试ACC加速流地址
        let fetchURL = "https://lvb.qcloud.com/weapp/utils/get_test_pushurl"
        let request  = URLRequest.init(url: URL.init(string: fetchURL)!)
        let session  = URLSession.init(configuration: .default, delegate: nil, delegateQueue: .main)
        let dataTask = session.dataTask(with: request) { (data, response, error) in
            if(error != nil){
                retryCallback()
                
            }else{
                
                let resultDict = try? JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? Dictionary<String, String>
                
                let rtmpPlayUrl = resultDict!["url_play_rtmp"]
                let flvPlayUrl = resultDict!["url_play_flv"]
                let hlsPlayUrl = resultDict!["url_play_hls"]
                let accPlayUrl = resultDict!["url_play_acc"]
    
                let playUrls = "rtmp播放地址:\(rtmpPlayUrl!)\n\nflv播放地址:\(flvPlayUrl!)\n\nhls播放地址:\(hlsPlayUrl!)\n\n低延时播放地址:\(accPlayUrl!)"

                let pasteboard = UIPasteboard.general
                pasteboard.string = playUrls
                
                LiteAVMessageView.showMessage("获取推拉流地址成功", "已复制到剪贴板", .success)
                
                qrCallBack(resultDict!["url_push"]!, resultDict!)
            }
        }
        dataTask.resume()
    }
    
}
