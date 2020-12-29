//
//  LivePlayerView.swift
//  LiteAVSwift
//
//  Created by kaoji on 2020/9/17.
//  Copyright © 2020 kaoji. All rights reserved.
//

import UIKit

//MARK: -- -用于承载画面的View 带一个菊花
class LiveVideoView: UIView {
    
    //菊花
    lazy var loadingView:UIActivityIndicatorView = {
        let indicateView = UIActivityIndicatorView.init(style: .whiteLarge)
        return indicateView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        loadingView.center = self.center
        self.addSubview(loadingView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: -- -直播播放器的View
class LivePlayerView: UIView {

    //返回
    lazy var backBtn:UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage.init(named: "navback"), for: .normal)
        return btn
    }()
    
    //帮助
    lazy var helpBtn:UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage.init(named: "help"), for: .normal)
        return btn
    }()
    
    //标题
    lazy var titleLabel:UILabel = {
        
        let label = createLabel(font: .boldSystemFont(ofSize: 18), color: .white, text: "直播播放器", alignment: .center)
        return label
    }()
    
    //地址栏
    lazy var linkInputView:UITextField = {
        
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.clearButtonMode = .whileEditing
        textField.placeholder = "http://liteavapp.qcloud.com/live/liteavdemoplayerstreamid.flv"
        return textField;
    }()
    
    //qrCode touch事件
    lazy var qrTap:UITapGestureRecognizer = {
        
        let tap = UITapGestureRecognizer()
        return tap;
    }()

    //扫描二维码图标
    lazy var qrCodeView:UIImageView = {
        let imageView = UIImageView.init(image: UIImage.init(named: "QR_code"))
        imageView.isUserInteractionEnabled = true
        return imageView;
    }()
    
    lazy var playerBarContainer:UIView = {
        let view = createView(bgColor: .clear)
        return view
        
    }()
    var playerBarDict:Dictionary<LivePlayerBar,UIButton> = Dictionary<LivePlayerBar,UIButton>()

    
    //播放器的容器
    lazy var videoView:LiveVideoView = {
        let view = LiveVideoView.init(frame: self.frame)
        return view
    }()
    
    //toastView
    lazy var toastView:UITextView = {
       let toast = UITextView()
        toast.isUserInteractionEnabled = false
        toast.backgroundColor = .white
        toast.alpha = 0.5
        toast.textColor = .black
        self.addSubview(toast)
        toast.snp.makeConstraints { (make) in
            make.left.width.equalToSuperview()
            make.height.equalTo(20)
            make.bottom.equalTo(playerBarContainer.snp.top).offset(-8)
        }
        return toast
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupPlayerView()
    }
    
    func setupPlayerView(){
        
        //背景图
        let livePlayerBundle = Bundle.main.path(forResource: "Live", ofType: "bundle")
        let iconPath = livePlayerBundle! + "/background.jpg"
        let bgImage = UIImage.init(contentsOfFile: iconPath)
        UIGraphicsBeginImageContext(self.frame.size)
        bgImage?.draw(in: self.bounds)
        let drawImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.backgroundColor = UIColor.init(patternImage: drawImage!)
        
        //添加到当前视图
        self.addSubview(videoView)
        self.addSubview(backBtn)
        self.addSubview(titleLabel)
        self.addSubview(helpBtn)
        self.addSubview(linkInputView)
        self.addSubview(qrCodeView)
        self.addSubview(playerBarContainer)
        
        //状态栏高度
        //返回按钮位置
        let topOffset = UIApplication.shared.statusBarFrame.size.height
        backBtn.frame = .init(x: 10, y: topOffset, width: 40, height: 30)
        
        //帮助按钮位置
        helpBtn.frame = .init(x: self.frame.size.width - 50, y: topOffset, width: 40, height: 30)
        
        //标题位置
        let titleW = self.frame.size.width - backBtn.frame.maxX - 50
        titleLabel.frame = CGRect.init(x: backBtn.frame.maxX, y: topOffset, width: titleW, height: 30)
        
        //地址栏位置
        let inputW = self.frame.size.width - 10 - 44 - 10 - 8
        linkInputView.frame = .init(x: 10, y: titleLabel.frame.maxY + 8, width: inputW, height: 44)
        
        //二维码地址
        qrCodeView.frame = .init(x: linkInputView.frame.maxX + 8, y: linkInputView.frame.minY+2, width: 40, height: 40)
        qrCodeView.addGestureRecognizer(qrTap)
        
        //工具栏
        playerBarContainer.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.snp.bottom).offset(isBangDevice ? -34:-4)
            make.height.equalTo(40)
            make.left.equalToSuperview().offset(8)
            make.width.equalToSuperview().offset(-16)
        }
        var layoutViews = Array<UIButton>()
        for item in bottomImages{
            let button = UIButton()
            let btnImageName = item[item.keys.first!]![0]
            let btnImageSELName = item[item.keys.first!]![1]
            button.setImage(UIImage.init(named: btnImageName), for: .normal)
            button.setImage(UIImage.init(named: btnImageSELName), for: .selected)
            button.imageView?.contentMode = .scaleAspectFill
            button.tag = item.keys.first!.rawValue
            playerBarContainer.addSubview(button)
            layoutViews.append(button)
            playerBarDict[item.keys.first!] = button
            
        }
        layoutViews.snp.distributeSudokuViews(verticalSpacing: 0, horizontalSpacing: 0, warpCount: playerBarDict.count)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
