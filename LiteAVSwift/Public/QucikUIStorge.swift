//
//  QucikUIStorge.swift
//  kaoji
//
//  Created by Kaoji on 2020/1/19.
//  Copyright © 2020 MMSay. All rights reserved.
//
import UIKit
import SwiftMessages

// MARK: - 视图
func createView(bgColor:UIColor) ->UIView{
    let view = UIView()
    view.backgroundColor = bgColor
    return view
}

// MARK: - 文本
func createLabel(font:UIFont,color:UIColor,text:String,alignment:NSTextAlignment) ->UILabel{
    let label = UILabel()
    label.text = text
    label.font = font
    label.textAlignment = alignment
    label.textColor = color
    return label
}
// MARK: - 按钮
func createBtn(font:UIFont,textcolor:UIColor,text:String,bgColor:UIColor) ->UIButton{
    let btn = UIButton()
    btn.setTitle(text, for: .normal)
    btn.titleLabel?.font = font
    btn.setTitleColor(textcolor, for: .normal)
    btn.backgroundColor = bgColor
    return btn
}

// MARK: - 按钮
func createIconBtn(icon:UIImage) ->UIButton{
    let btn = UIButton()
    btn.setImage(icon, for: .normal)
    return btn
}

// MARK: - 图片
func createImageView(image:UIImage,mode:UIView.ContentMode,interface:Bool) ->UIImageView{
    let imageView = UIImageView()
    imageView.image = image
    imageView.clipsToBounds = true
    imageView.isUserInteractionEnabled = interface
    imageView.contentMode = mode
    return imageView
}

// MARK: - tableView
func createTableView(tStyle:UITableView.Style) ->UITableView{
    let table  = UITableView.init(frame: .zero, style: tStyle)
    table.separatorStyle = .none
    table.tableHeaderView = UIView()//去除多余的分割线
    table.tableFooterView = UIView()//去除多余的分割线
    table.backgroundColor = .init(red: 240/255, green: 240/255, blue: 240/255, alpha:1)
    return table
}

// MARK: - tableView
func createTextField(font:UIFont,color:UIColor,placeHolder:String,boderStyle:UITextField.BorderStyle) ->UITextField{
    let tf  = UITextField()
    tf.borderStyle = boderStyle
    tf.placeholder = placeHolder
    tf.font = font
    tf.textColor = color
    tf.attributedPlaceholder = .init(string: placeHolder, attributes: [.foregroundColor : UIColor.init(white: 1.0, alpha: 0.3)])
    return tf
}

// MARK: - tableView
class QuickSeletedView:UIView {
    
    var titleLabel:UILabel!
    var segment:UISegmentedControl!
    
    init(frame:CGRect,title:String,SegmentInfo:[String],height:CGFloat) {
        super.init(frame: frame)
        self.frame = .init(x: 0, y: 0, width: SCREEN_WIDTH, height: 44)
        titleLabel = createLabel(font: .systemFont(ofSize: 15), color: .white, text: title, alignment: .left)
        titleLabel.frame = .init(x: 0, y: 0, width: SCREEN_WIDTH, height: 44)
        titleLabel.alpha = 0.8
        
        segment = UISegmentedControl.init(items: SegmentInfo)
        segment.tintColor = UIColor.init(white: 0.1, alpha: 0.8)
        segment.setTitleTextAttributes([.foregroundColor : UIColor.white], for: .normal)
        segment.setTitleTextAttributes([.foregroundColor : UIColor.black], for: .selected)
        segment.selectedSegmentIndex = 0
        let segmentWidth:CGFloat = segment.frame.width
        segment.frame =  CGRect.init(x: (SCREEN_WIDTH - segmentWidth - 26), y: 7, width: segmentWidth, height: 30)
        
        self.addSubview(titleLabel)
        self.addSubview(segment)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//toast
func statusToast(body:String,type:Theme){
    
    var bgColor:UIColor = .green
    switch type {
    case .success:
        bgColor = .green
    case .warning:
        bgColor = .yellow
    case .error:
        bgColor = .red
    case .info:
        bgColor = .purple
    }
    
    let status = MessageView.viewFromNib(layout: .statusLine)
    status.frame.size.height = isBangDevice ?STATUSBAR_HEIGHT-20:20
    status.backgroundView.backgroundColor = bgColor
    status.bodyLabel?.textColor = .white
    status.configureContent(body: body)
    var statusConfig = SwiftMessages.defaultConfig
    
    statusConfig.presentationContext = .window(windowLevel: UIWindow.Level.statusBar)
    
    SwiftMessages.show(config: statusConfig, view: status)
}
