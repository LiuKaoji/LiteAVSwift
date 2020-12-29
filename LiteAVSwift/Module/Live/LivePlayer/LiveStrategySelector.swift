//
//  LiveStrategySelector.swift
//  LiteAVSwift
//
//  Created by kaoji on 2020/9/21.
//  Copyright © 2020 kaoji. All rights reserved.
//

import UIKit

class  LiveStrategySelector: UIViewController {
    
    //数据源
    let dataSource = ["极速","流畅","自动"]
    //选项容器
    var strategyContainer:UIView!
    //抛出缓冲策略类型
    typealias StrategyHandler = (CACHE_STRATEGY) ->()
    var strategyCallback:StrategyHandler?
    
    //缓冲策略选择按钮
    var layoutViews = Array<UIButton>()
    
    override func viewDidLoad() {
        setupStrategySelector()
    }
    
    func setupStrategySelector(){
        
        //标题
        let titleLabel = createLabel(font: .boldSystemFont(ofSize: 18), color: .darkGray, text: "延迟调整", alignment: .center)
        titleLabel.frame = .init(x: 0, y: 10, width: self.view.frame.width, height: 40)
        self.view.addSubview(titleLabel)
        
        //背景色
        self.view.backgroundColor = .white
        
        //容器
        strategyContainer = UIView()
        strategyContainer.frame = .init(x: 10, y: titleLabel.frame.maxY + 30, width: self.view.frame.width-20, height: 40)
        self.view.addSubview(strategyContainer)
    
       //按钮布局约束
        for item in dataSource{
            let button = UIButton()
            button.setTitle(item, for: .normal)
            button.setTitle(item, for: .selected)
            button.setTitleColor(.black, for: .normal)
            button.setTitleColor(.white, for: .selected)
            button.setBackgroundImage(UIImage.init(named: "white"), for: .normal)
            button.setBackgroundImage(UIImage.init(named: "black"), for: .selected)
            button.addTarget(self, action: #selector(onClickStrategy), for: .touchUpInside)
            strategyContainer.addSubview(button)
            layoutViews.append(button)
        }
        layoutViews[dataSource.count-1].isSelected = true//默认选中自动
        layoutViews.snp.distributeSudokuViews(verticalSpacing: 0, horizontalSpacing: 20, warpCount: dataSource.count)
        layoutViews.snp.makeConstraints { (make) in
            make.height.equalTo(40)
        }
    }
    
    class func instance(currentType:CACHE_STRATEGY,strategyCallback:@escaping StrategyHandler)->LiveStrategySelector {
        
        let strategyVC = LiveStrategySelector()
        strategyVC.preferredContentSize = .init(width: SCREEN_WIDTH, height: 220)
        strategyVC.strategyCallback = strategyCallback
        return strategyVC
    }
    
    //使用SwiftMessage框架弹出控制器
    func show(_ sender: UIViewController){
        
        let segue = SwiftMessagesSegue(identifier: nil, source: sender, destination: self)
        segue.duration = .forever
        segue.presentationStyle = .bottom
        segue.dimMode = .gray(interactive: true)
        segue.perform()
    }
    
    //选中某个策略
    @objc func onClickStrategy(_ sender:UIButton){
        
        for item in self.layoutViews{
            let index = layoutViews.firstIndex(of: item)
            layoutViews[index!].isSelected = (item == sender) ?true:false
        }
        
        if self.strategyCallback != nil {
            self.strategyCallback!(CACHE_STRATEGY.init(rawValue: (sender.titleLabel?.text)!)!)
        }
    
        dismiss(animated: true, completion: nil)
    }
}
