//
//  LUTSelectView.swift
//  LiteAVSwift
//
//  Created by kaoji on 2020/9/6.
//  Copyright © 2020 kaoji. All rights reserved.
//

import UIKit

struct LUTEffectStruct {
    /// lut图文件名
    var lutImageName: String = ""
    /// lut图预览效果
    var previewImage: UIImage!
    var previewImage_s: UIImage!
    /// lut类型名
    var lutItemName: String = ""
    /// 选中状态
    var selected: Bool = false
}

typealias LUTEffectAction = ((LUTEffectStruct) -> (Void))

class LUTSelectView: UIView,UICollectionViewDataSource,UICollectionViewDelegate {

    var effectDataSource:Array<LUTEffectStruct>?{
        
        didSet{
            self.collectionView.reloadData()
        }
        
    }
    var effectAction:LUTEffectAction?
  

    lazy var flowLayout:UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = .init(width: 44, height: 66)
        layout.minimumLineSpacing = 15.0
        layout.sectionInset = .init(top: 0, left: 20, bottom: 0, right: 20)
        return layout
    }()
    
    lazy var collectionView:UICollectionView = {
        let scrollMenu = UICollectionView.init(frame: .zero, collectionViewLayout: self.flowLayout)
        scrollMenu.delegate = self;
        scrollMenu.dataSource = self;
        scrollMenu.showsHorizontalScrollIndicator = false
        scrollMenu.backgroundColor = .clear
        scrollMenu.allowsMultipleSelection = false
        scrollMenu.register(LUTEffectItem.classForCoder(), forCellWithReuseIdentifier: "LUTEffectItem")
        return scrollMenu
    }()
    
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
        setupCollectionView()
    }
    
    func setupCollectionView(){
        
        self.collectionView.frame = self.frame
        self.addSubview(self.collectionView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
       return self.effectDataSource?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = collectionView.dequeueReusableCell(withReuseIdentifier: "LUTEffectItem", for: indexPath) as! LUTEffectItem
        item.configItem(model: self.effectDataSource![indexPath.row])
        return item
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        /// 重设
        resetSelected()
        
        /// 选中当前
        self.effectDataSource![indexPath.row].selected = true
        
        /// 传值
        if effectAction != nil {
            effectAction!(self.effectDataSource![indexPath.row])
        }
        
        /// 刷新UI
        self.collectionView.reloadData()
        
    }
    
    func resetSelected(){
        for i in 0...self.effectDataSource!.count - 1 {
            self.effectDataSource![i].selected = false
        }
    }
}


class LUTEffectItem: UICollectionViewCell {
    
    //数据
    var dataModel:LUTEffectStruct?
    
    //标题
    lazy var titleLabel:UILabel = {
        let label = createLabel(font: .systemFont(ofSize: 10.0), color: .white, text: "LUT图", alignment: .center)
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    lazy var iconImgView:UIImageView = {
        
        let imageView = UIImageView()
        return imageView
        
    }()
    
    lazy var selectedImgView:UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage.init(named: "process_select")
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupItem()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupItem() {
        
        self.addSubview(self.iconImgView)
        self.addSubview(self.selectedImgView)
        self.addSubview(self.titleLabel)
        
        self.iconImgView.snp.makeConstraints { (make) in
            make.top.right.left.equalToSuperview()
            make.height.equalTo(44)
        }
        
        self.selectedImgView.snp.makeConstraints { (make) in
            make.top.right.left.bottom.equalTo(iconImgView)
        }
        
        self.titleLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.snp.centerX)
            make.top.equalTo(self.iconImgView.snp.bottom).offset(8.0)
            make.width.lessThanOrEqualTo(44)
        }
        
    }
    
    func configItem(model:LUTEffectStruct) {
        self.dataModel = model
        self.titleLabel.text = model.lutItemName
        self.iconImgView.image = model.previewImage
        self.selectedImgView.isHidden = !model.selected
        self.titleLabel.alpha = model.selected ? 1.0 : 0.5
    }
    
    
}
