//
//  MainView.swift
//  LiteAVSwift
//
//  Created by kaoji on 2020/9/20.
//  Copyright © 2020 kaoji. All rights reserved.
//

import UIKit

class MainView: UIView,UITableViewDelegate,UITableViewDataSource {
    
    typealias MainItemHandler = (String) ->()
    var itemClickCallback:MainItemHandler!
    
    let staticHeadearH:CGFloat = 70
    var dataSource:Array<String>!
    
    lazy var titleLabel:UILabel = {
        let label = createLabel(font: .boldSystemFont(ofSize: 18), color: .white, text: "直播播放器", alignment: .center)
        return label
    }()
    
    lazy var mainTableView:UITableView = {
        let table = UITableView.init(frame: .zero, style: .plain)
        return table
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupMainUI()
    }
    
    func setupMainUI(){

        let layer = CAGradientLayer()
        layer.frame = self.frame
        layer.colors = [
            
            rgb(36, 67, 89).cgColor,
            rgb(22, 41, 71).cgColor,
            rgb(15, 29, 53).cgColor,
            rgb(255, 255, 255).cgColor,
        ]
        layer.startPoint = .init(x: 1, y: 0)
        layer.endPoint = .init(x: 0, y: 1)
        layer.locations = [0.0, 0.8, 1.0]
        self.layer.addSublayer(layer)
        self.addSubview(mainTableView)
        
        let statusBarH = UIApplication.shared.statusBarFrame.size.height
        let screenW = UIScreen.main.bounds.size.width
        let screenH = UIScreen.main.bounds.size.height
        
        mainTableView.frame = .init(x: 30, y: statusBarH, width: screenW - 60 , height: screenH - statusBarH)
        mainTableView.delegate = self
        mainTableView.dataSource = self
        mainTableView.tableHeaderView = titleHeader()
        mainTableView.tableFooterView = UIView()
        mainTableView.backgroundColor = .clear
        mainTableView.separatorColor = rgba(0, 0, 0, 0.5)
        mainTableView.separatorInset = .zero
        mainTableView.register(MainTableCell.classForCoder(), forCellReuseIdentifier: "MainTableCell")
        mainTableView.register(MainHeaderView.classForCoder(), forHeaderFooterViewReuseIdentifier: "MainHeader")
    }
    
    func titleHeader() -> UIView {
        
        let header = UILabel.init(frame: .init(x: 0, y: 0, width: self.frame.size.width, height: 60))
        header.text = "LiteAVSDK"
        header.textColor = rgba(255, 255, 255, 0.8)
        header.font = .boldSystemFont(ofSize: 28)
        return header
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: -TableView delegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return groupData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let group = groupData[section]
        return (group.status == true) ?groupData[section].data!.count:0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MainTableCell", for: indexPath) as! MainTableCell
        let item:groupItem = groupData[indexPath.section].data![indexPath.row]
        cell.itemTitleLabel.text =  item.title
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let classRef = groupData[indexPath.section].data![indexPath.row].classRef
        
        if(itemClickCallback != nil){
            itemClickCallback(classRef!)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        var header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "MainHeader") as? MainHeaderView
        if (header == nil) {
            header = MainHeaderView.init(reuseIdentifier: "MainHeader")
        }
        header!.configHeaderTitle(text: groupData[section].title!)
        header!.headerCallback = { [weak self] in
            let status = groupData[section].status
            groupData[section].status = !status
            self?.mainTableView.reloadSections([section], animationStyle: .automatic)
        }
        
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return staticHeadearH
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 20
    }
    
    @objc func onClickHeader(sender: UITapGestureRecognizer) {
        
        let status = groupData[sender.view!.tag - 1000].status
        groupData[sender.view!.tag - 1000].status = !status
        
        mainTableView.reloadSections([sender.view!.tag - 1000], animationStyle: .automatic)
    }
}


//MARK: -TableViewCell
class MainTableCell: UITableViewCell {
    
    let containView = UIView()
    lazy var itemTitleLabel :UILabel = {
        let label = UILabel()
        label.text = "标题"
        label.textColor = rgba(255, 255, 255, 0.8)
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 17)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCellUI()
        self.selectionStyle = .none
        self.addSubview(containView)
        self.backgroundColor = rgba(21, 45, 89, 0.5)
        self.addSubview(itemTitleLabel)
        
        itemTitleLabel.snp.makeConstraints { (make) in
            make.right.bottom.top.equalToSuperview()
            make.left.equalTo(15)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupCellUI(){
        self.backgroundColor = .clear
    }
    
}

//MARK: -TableView Header
class MainHeaderView: UITableViewHeaderFooterView {
    
    typealias MainHeaderHandle = () ->()
    var headerCallback:MainHeaderHandle!
    var titleLabel: UILabel!
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        createHeader()
    }
    
    func createHeader() {
     
        self.contentView.isUserInteractionEnabled = true
        self.contentView.backgroundColor = rgba(14, 45, 89, 1.0)
        
        let line = createView(bgColor: rgba(0, 0, 0, 0.5))
        self.contentView.addSubview(line)
        line.snp.makeConstraints { (make) in
            make.left.width.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
        
        titleLabel = UILabel()
        titleLabel.textColor = rgba(255, 255, 255, 0.8)
        titleLabel.font = .systemFont(ofSize: 18)
        self.contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.right.top.equalToSuperview()
            make.left.equalTo(15)
            make.bottom.equalTo(-0.5)
        }
        
        let tapG = UITapGestureRecognizer.init(target: self, action: #selector(onClickHeader(sender:)))
        self.contentView.addGestureRecognizer(tapG)
    }
    
    func configHeaderTitle(text: String){
        titleLabel.text = text
    }
    
    @objc func onClickHeader(sender: UITapGestureRecognizer) {
        
        if (headerCallback != nil) {
           headerCallback!()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
