//
//  BeautyContainer.swift
//  LiteAVSwift
//
//  Created by kaoji on 2020/11/10.
//  Copyright © 2020 kaoji. All rights reserved.
//

import UIKit


class BeautyContainer: UIViewController {
    
    /// 滤镜默认值
    let defaultBeautyValue: Float = 0.5

    /// 滤镜调整滑块
    lazy var beautySlider:BeautySliderView = {
        return BeautyContainer.sliderGenerator("美颜", defaultBeautyValue)
    }()
    
    lazy var brightSlider:BeautySliderView = {
        return BeautyContainer.sliderGenerator("亮度", defaultBeautyValue)
    }()
    
    lazy var toneSlider:BeautySliderView = {
        return BeautyContainer.sliderGenerator("色调", defaultBeautyValue)
    }()

    
    private lazy var stackView: UIStackView = {
        let stackView  = UIStackView.init(arrangedSubviews: [beautySlider, brightSlider, toneSlider])
        /// item间距
        stackView.spacing = 0
        /// 垂直方向布局
        stackView.axis = .vertical
        /// 等分
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    lazy var beautyTitle: UILabel = {
        let label = UILabel()
        label.text = "滤镜设置"
        label.font = .boldSystemFont(ofSize: 18)
        label.textColor = .white
        label.textAlignment = .left
        return label
    }()
    
    lazy var beautySwitch: UISwitch = {
        let switchBtn = UISwitch()
        switchBtn.isOn = true
        return switchBtn
    }()
    
    lazy var beautyLine: UIView = {
        return UIView()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = rgba(0, 0, 0, 0.6)
        createBeautyView()
    }

    func createBeautyView(){
        
        beautyLine.backgroundColor = rgba(255, 255, 255, 0.3)
        beautyTitle.frame = .init(x: 15, y: 0, width: 100, height: 44)
        
        self.view.addSubview(beautyTitle)
        self.view.addSubview(beautySwitch)
        self.view.addSubview(beautyLine)
        self.view.addSubview(stackView)
        
        beautySwitch.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-15)
            make.width.equalTo(51)
            make.height.equalTo(37)
            make.centerY.equalTo(beautyTitle.snp.centerY).offset(2)
        }
        
        beautyLine.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalTo(beautyTitle.snp.bottom)
            make.height.equalTo(0.5)
        }
        
        stackView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.top.equalTo(beautyLine.snp.bottom).offset(15)
            make.height.equalTo(44 * 3)
        }
    }
    
    func showBeautyView(sender:UIViewController){
        
        let statusBarH = UIApplication.shared.statusBarFrame.size.height
        
        let selfW = self.view.frame.size.width
        let selfH = 250 + (statusBarH - 20)
        
        self.preferredContentSize = .init(width: selfW, height: selfH)
        let segue = SwiftMessagesSegue(identifier: nil, source: sender, destination: self)
        segue.duration = .forever
        segue.presentationStyle = .bottom
        segue.dimMode = .color(color: .clear, interactive: true)
        segue.perform()
    }
}

extension BeautyContainer{
    
    class func sliderGenerator(_ title: String, _ value: Float) -> BeautySliderView{
         let slider = BeautySliderView()
         slider.titleLabel.text = title
         slider.sliderView.value = value
         slider.valueLabel.text = "\(value)"
         return slider
     }
}
