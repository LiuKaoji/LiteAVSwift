//
//  LiveFloatWindow.swift
//  TRTCSwift
//
//  Created by kaoji on 2020/9/23.
//  Copyright © 2020 kaoji. All rights reserved.
//

import UIKit

class LiveFloatWindow: NSObject {
    
    //事件回调->通知原始处理器做相应处理
    typealias LiveFloatWindowHandler = () ->()
    var backHandler:LiveFloatWindowHandler?//返回播放页面
    var closeHandler:LiveFloatWindowHandler?//关闭播放浮窗
    
    //单例对象
    private static var _sharedInstance: LiveFloatWindow?
    
    //播放器
    var debugPlayer:LiveDebugPlayer!
    
    //原始控制器
    var backController:LivePlayerVC!
    
    //画面承载
    var floatView:UIView!
    
    //小窗是否正在显示
    var isFloating:Bool!
    
    //关闭按钮
    var closeBtn:UIButton!
    
    //原始渲染
    var renderMode:TX_Enum_Type_RenderMode!
    
    lazy var appWindow:UIWindow = {
        return UIApplication.shared.delegate?.window!
    }()!
    
    //获取单例对象
    class func getShared() -> LiveFloatWindow {
        guard let instance = _sharedInstance else {
            _sharedInstance = LiveFloatWindow()
            return _sharedInstance!
        }
        return instance
    }
    
    //销毁单例对象
    class func destroy() {
        _sharedInstance = nil
    }
    
    class func isFloating() -> Bool {
        return (_sharedInstance == nil ?false:true)
    }
    
    // 私有化init方法
    override init() {
        super.init()
    }
    
    required init?(coder: NSCoder) {fatalError("init(coder:) has not been implemented")}
    
    //UI创建
    func setupFloatWindow(_ player:LiveDebugPlayer){
        
        debugPlayer = player
        
        floatView = UIView.init(frame: LiveFloatWindow.getFlowSourceRect(souceRect: appWindow.frame))
        appWindow.addSubview(floatView)
        
        let path = UIBezierPath.init(rect: floatView.frame)
        path.stroke()
        
        closeBtn = .init(frame: .init(x: floatView.frame.size.width - 34, y: 4, width: 30, height: 30))
        closeBtn.setImage(UIImage.init(named: "view_close"), for: .normal)
        closeBtn.addTarget(self, action: #selector(onClickClose), for: .touchUpInside)
        floatView.addSubview(closeBtn)
        
        //点击返回
        let tapGesture = UITapGestureRecognizer()
        tapGesture.addTarget(self, action: #selector(onClickBack))
        floatView.addGestureRecognizer(tapGesture)
        
        //拖拽画面
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panAction(_ :)))
        floatView.addGestureRecognizer(panGesture)
        
        configFloatWindow()
        
    }
    
    func configFloatWindow(){
        
        let mode =  debugPlayer.isRenderScreen ?.RENDER_MODE_FILL_SCREEN:TX_Enum_Type_RenderMode.RENDER_MODE_FILL_EDGE
        self.renderMode = mode
        debugPlayer.livePlayer.setRenderMode(.RENDER_MODE_FILL_SCREEN)
        debugPlayer.livePlayer.removeVideoWidget()
        debugPlayer.livePlayer.setupVideoWidget(.zero, contain: floatView, insert: 0)
    }
    
    @objc func panAction(_ pan:UIPanGestureRecognizer){
        
        let translation = pan.translation(in: self.appWindow)
        
        //确保重叠时始终在最前面 划到别人底部 不太好看
        if pan.state == .began {
            
        } else if pan.state == .changed{
            
            //防止左右滑出边界
            let maxX  = (appWindow.frame.size.width) - self.floatView.frame.size.width/2
            let moveX = CGFloat.maximum(self.floatView.frame.size.width/2, CGFloat.minimum(maxX, floatView.center.x + translation.x))
            
            //防止上下滑出边界
            let maxY  = (appWindow.frame.size.height) - self.floatView.frame.size.height/2
            let moveY = CGFloat.maximum(self.floatView.frame.size.height/2, CGFloat.minimum(maxY, floatView.center.y + translation.y))
            
            floatView.center = CGPoint(x: moveX, y: moveY)
            pan.setTranslation(CGPoint.zero, in: self.appWindow)
        }
        //结束时弹一弹
        else if pan.state == .ended {
            
            UIView.animate(withDuration: 0.1) { [self] in
                
                if floatView.center.x < self.appWindow.frame.width / 2 {
                    floatView.center = CGPoint(x: floatView.frame.size.width / 2 + 10, y: floatView.center.y)
                }else{
                    floatView.center = CGPoint(x: self.appWindow.frame.width - floatView.frame.size.width / 2 - 10, y: floatView.center.y)
                }
                
            }completion: { _ in
                self.floatView.bounceAnimation()
            }
        }
    }
    
    @objc func onClickBack(){
        if (self.backHandler != nil){
            self.backHandler!()
        }
        
        debugPlayer.livePlayer.removeVideoWidget()
        debugPlayer.livePlayer.setupVideoWidget(.zero, contain: backController.playerView.videoView, insert: 0)
        debugPlayer.livePlayer.setRenderMode(self.renderMode)
        floatView.removeFromSuperview()
        
        let controller = getCurrentViewController()
        controller?.navigationController?.pushViewController(backController, animated: true)
    }
    
    @objc func onClickClose(){
        debugPlayer.stopPlay()
        floatView.removeFromSuperview()
        LiveFloatWindow.destroy()
    }
    
    func getCurrentViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
         if let nav = base as? UINavigationController {
             return getCurrentViewController(base: nav.visibleViewController)
         }
         if let tab = base as? UITabBarController {
             return getCurrentViewController(base: tab.selectedViewController)
         }
         if let presented = base?.presentedViewController {
             return getCurrentViewController(base: presented)
         }
         return base
     }

}


extension LiveFloatWindow{
    
    // 获取窗口位置
    class func getFlowSourceRect(souceRect:CGRect) ->CGRect{
        
        let VSPACE:CGFloat = 10.0
        let HSPACE:CGFloat = 20.0
        let MARGIN:CGFloat = 10.0
        
        var atRect:CGRect = .zero
        let H:CGFloat = souceRect.size.height
        let W:CGFloat = souceRect.size.width
        
        atRect.size.width = (W - 2 * HSPACE - 2 * MARGIN) / 3
        atRect.size.height = FitH(rect: atRect)
        atRect.origin.y = H/2 + atRect.size.height/2 + VSPACE
        
        atRect.origin.x = W - atRect.size.width - MARGIN
        
        return atRect
    }
    
    class func FitH(rect:CGRect) -> CGFloat{
        return (rect.size.width / 9.0) * 16
    }
    
}
