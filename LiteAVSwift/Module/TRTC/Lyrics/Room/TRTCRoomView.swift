//
//  TRTCRoomView.swift
//  TRTCSwift
//
//  Created by Kaoji on 2020/4/26.
//  Copyright © 2020 by Kaoji. All rights reserved.
//

import UIKit

class TRTCRoomView: UIView {
    var holderView = UIView()
    var remoteViewDic = Dictionary<String,TRTCVideoView>()
    var mainViewUserId:String = String()
    var param:TRTCParams!
    var appScene:TRTCAppScene!
    
    var layoutEngin:TRTCVideoViewLayout!
    var backBtn:UIButton!
    var roomTitle:UILabel!
    
    
    lazy var toastView: UITextView = {
        let toast = UITextView()
        toast.isUserInteractionEnabled = false
        toast.isScrollEnabled = false
        toast.backgroundColor = .white
        toast.alpha = 0.5
        toast.isHidden = true
        self.addSubview(toast)
        return toast
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createView()
    }
    
    required init?(coder: NSCoder) {fatalError("init(coder:) has not been implemented")}
    
    func createView(){
        
        holderView.frame = self.frame
        holderView.backgroundColor = .darkGray
        self.addSubview(self.holderView)
        
        layoutEngin = TRTCVideoViewLayout()
        layoutEngin.view = holderView
        layoutEngin.setupFrames()
        
        //标题
        let roomID:String = UserDefaults.standard.value(forKey: "ROOMID") as! String
        roomTitle = createLabel(font: .systemFont(ofSize: 18), color: .init(white: 1.0, alpha: 0.8), text: roomID, alignment: .center)
        self.addSubview(roomTitle)
        roomTitle.snp.makeConstraints { (make) in
            make.width.equalTo(150)
            make.height.equalTo(44)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(STATUSBAR_HEIGHT)
        }
        
        //返回按钮
        backBtn = UIButton()
        backBtn.setImage(UIImage.init(named: "navback"), for: .normal)
        self.addSubview(backBtn)
        backBtn.snp.makeConstraints { (make) in
            make.size.equalTo(40)
            make.centerY.equalTo(roomTitle.snp.centerY)
            make.left.equalTo(8)
        }
    
        
        toastView.snp.makeConstraints { (make) in
            make.bottom.equalTo(-74)
            make.left.width.equalToSuperview()
            make.height.equalTo(30)
        }
    }

    func showToast(text:String){
        
        DispatchQueue.main.async {
            self.toastView.isHidden = false
            self.toastView.text = text
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.toastView.isHidden = true
            }
        }
    }
    
    
    
    override func layoutSubviews() {
    }
}
