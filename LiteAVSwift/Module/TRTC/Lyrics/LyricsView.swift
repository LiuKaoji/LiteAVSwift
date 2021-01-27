//
//  LyricsView.swift
//  LiteAVSwift
//
//  Created by kaoji on 2021/1/27.
//  Copyright © 2021 kaoji. All rights reserved.
//

import UIKit

class LyricsView: UIView {
    
    let disposeBag = DisposeBag()
    
    var role: TRTCRoleType = .anchor
    
    /// UI
    lazy var miniLrcView: UILabel! = {
        let miniView = UILabel()
        miniView.textColor = .white
        miniView.textAlignment = .center
        self.addSubview(miniView)
        return miniView
    }()

    
    lazy var playBtn: UIButton = {
       let btn = UIButton()
       btn.setImage(UIImage.init(named: "play_yellow"), for: .normal)
       self.addSubview(btn)
       return btn
    }()

    lazy var tableView: UITableView = {
        let table = UITableView.init(frame: self.frame, style: .grouped)
        table.estimatedRowHeight = 0
        table.estimatedSectionFooterHeight = 0
        table.estimatedSectionHeaderHeight = 0
        table.separatorStyle = .none
        table.backgroundColor = .clear
        table.layer.shadowOffset = .init(width: 0, height: 0)//往x方向偏移0，y方向偏移0
        table.layer.shadowOpacity=0.3;//设置阴影透明度
        table.layer.shadowColor = rgba(255, 255, 255, 0.5).cgColor//设置阴影颜色
        table.layer.shadowRadius=5;//设置阴影半径
        table.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "lyricsCellId")
        self.addSubview(table)
        return table
    }()

    required convenience init(role: TRTCRoleType){
        self.init()
        self.role = role
        setupView()
    }
    
    func setupView(){
  
        
        /// 观众歌词
        miniLrcView.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.snp.bottom).offset(isBangDevice ? -34:0)
            make.left.width.equalToSuperview()
        }
        
        guard role == .anchor else{
           return
        }
    
        /// 主播歌词
        tableView.snp.makeConstraints { (make) in
            make.width.centerX.centerY.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.5)
        }
    
        /// 播放按钮
        playBtn.snp.makeConstraints { (make) in
            make.size.equalTo(60)
            make.centerX.centerY.equalToSuperview()
        }

    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
