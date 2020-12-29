//
//  MainViewController.swift
//  LiteAVSwift
//
//  Created by kaoji on 2020/9/20.
//  Copyright © 2020 kaoji. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    var mainView:MainView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMainView()
    }
    
    func setupMainView(){
        
        mainView = MainView.init(frame: self.view.frame)
        self.view.addSubview(mainView)
        
        mainView.itemClickCallback = { [weak self] classRef in
            
            if(classRef == "LivePlayerVC" && LiveFloatWindow.isFloating() == true){
                LiveFloatWindow.getShared().onClickClose()
            }
            /// 根据类名跳转
            let ns = Bundle.main.infoDictionary!["CFBundleExecutable"] as! String
            let anyObjectType :AnyClass? = NSClassFromString(ns + "." + classRef)!
            let JumpVC = anyObjectType as! UIViewController.Type
            self?.navigationController?.pushViewController(JumpVC.init(), animated: true)
        }
    }
}
