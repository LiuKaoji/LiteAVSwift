//
//  RoomEnterVC.swift
//  TRTCSwift
//
//  Created by Kaoji on 2020/4/16.
//  Copyright © 2020 by Kaoji. All rights reserved.
//

import UIKit

class RoomEnterVC: UIViewController {

    var nRoomView:RoomEnterView!
    let disposeBag = DisposeBag()
   
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "TRTC Room"
        self.navigationController?.navigationBar.barStyle = .blackTranslucent
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor : UIColor.white]
        createRoomView()
        checkInfo()
    }
    
    func checkInfo(){
        
        if(_SDKAppID == 0 || _SECRETKEY.isEmpty){
            let alert = UIAlertController.init(title: "提示", message: "请检查SDKAppID或SECRETKEY", preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "确定", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }

    }
    
    func createRoomView() {
        
        nRoomView = RoomEnterView.init(frame: .init(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.size.height))
        self.view.addSubview(nRoomView)
      
        nRoomView.createRoomBtn.rx.tap.subscribe(onNext: { [weak self](btn) in
            self?.joinRoom()
        }).disposed(by: disposeBag)

    
    }
    
    func joinRoom(){
        
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
        
        navigationController?.pushViewController(RoomVC.init(rtcParam: param), animated: true)
 
    }
}

//MARK: -视图
class RoomEnterView: UIView {
    
    var roomIDLabel:UILabel!//房间ID标题
    var roomIDTextField:UITextField!//房间输入框
    
    var usrIDLabel:UILabel!//用户ID标题
    var usrIDTextField:UITextField!//用户ID输入框
    
    var createRoomBtn:UIButton!
    var roleInputView:QuickSeletedView!
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        createNewRoomView()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented")}
    
    func createNewRoomView() {
        
        self.backgroundColor = UIColor.init(white: 0.2, alpha: 1)
        
        //房间标题
        roomIDLabel = createLabel(font: .systemFont(ofSize: 15), color: .white, text: "请输入房间ID", alignment: .left)
        roomIDLabel.alpha = 0.8
        self.addSubview(roomIDLabel)
        //房间ID输入框
        roomIDTextField = createTextField(font: .systemFont(ofSize: 15), color: .white, placeHolder: "278688", boderStyle: .roundedRect)
        roomIDTextField.backgroundColor = .darkGray
        self.addSubview(roomIDTextField)
        //用户标题
        usrIDLabel = createLabel(font: .systemFont(ofSize: 15), color: .white, text: "请输入用户ID", alignment: .left)
        usrIDLabel.alpha = 0.8
        self.addSubview(usrIDLabel)
        //用户ID输入框
        usrIDTextField = createTextField(font: .systemFont(ofSize: 15), color: .white, placeHolder: "\(arc4random() % 10000)", boderStyle: .roundedRect)
        usrIDTextField.backgroundColor = .darkGray
        self.addSubview(usrIDTextField)
        
        //视频
        roleInputView = QuickSeletedView.init(frame: .zero, title: "成员角色", SegmentInfo: ["主播端","观众端"], height: 44)
        self.addSubview(roleInputView)
        
        //创建房间按钮
        let btnColor = UIColor.init(red: 137/255, green: 191/255, blue: 179/255, alpha: 1.0)
        createRoomBtn = createBtn(font: .systemFont(ofSize: 15), textcolor: .white, text: "创建房间并自动加入", bgColor: btnColor)
        createRoomBtn.layer.cornerRadius = 8
        self.addSubview(createRoomBtn)

        
        //约束
        let contraintArray = [roomIDLabel,roomIDTextField,usrIDLabel,usrIDTextField,roleInputView]
        contraintArray.snp.distributeViewsAlong(axisType: .vertical, fixedItemSpacing: 0, edgeInset: .init(top: 0, left: 16, bottom: 0, right: 0), fixedItemLength: 40, topConstrainView: nil)
        roomIDLabel.snp.updateConstraints { (make) in make.top.equalTo(self.snp.top).offset(NAV_HEIGHT + 16)}
        roleInputView.snp.updateConstraints { (make) in make.top.equalTo(usrIDTextField.snp.bottom).offset(16)}
        
        createRoomBtn.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(self.snp.bottom).offset(-TAB_HEIGHT)
            make.width.equalToSuperview().multipliedBy(0.6)
            make.height.equalTo(44)
        }
        
    }
    
}
