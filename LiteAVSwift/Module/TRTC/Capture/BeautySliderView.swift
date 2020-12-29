//
//  BeautySliderView.swift
//  LiteAVSwift
//
//  Created by kaoji on 2020/11/10.
//  Copyright © 2020 kaoji. All rights reserved.
//

import UIKit

//提供一个容器 中间是进度条 两边是文本
class BeautySliderView: UIView{

   lazy var titleLabel:UILabel = {
        let label = createLabel(font: .systemFont(ofSize: 15), color: .white, text: "控件标题", alignment: .center)
        return label
    }()

    lazy var sliderView:UISlider = {
        let slider = UISlider()
        slider.maximumValue = 1.0
        slider.minimumValue = 0.0
        slider.value = 0.5
        return slider
    }()

    lazy var valueLabel:UILabel = {
        let label = createLabel(font: .systemFont(ofSize: 15), color: .white, text: "0.00", alignment: .center)
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        layoutSoundSliderView()
    }
    
    func layoutSoundSliderView(){
        
        self.addSubview(titleLabel)
        self.addSubview(sliderView)
        self.addSubview(valueLabel)
    
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(10)
            make.width.greaterThanOrEqualTo(50)
            make.top.height.equalToSuperview()
        }
        
        valueLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-10)
            make.width.greaterThanOrEqualTo(50)
            make.top.height.equalToSuperview()
        }
        
        sliderView.snp.makeConstraints { (make) in
            make.left.equalTo(titleLabel.snp.right).offset(8)
            make.right.equalTo(valueLabel.snp.left)
            make.top.bottom.height.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

