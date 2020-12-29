//
//  MainModel.swift
//  LiteAVSwift
//
//  Created by kaoji on 2020/11/22.
//  Copyright © 2020 kaoji. All rights reserved.
//

import Foundation

//
// MARK: - 组数据
//

public struct groupItem {
    var title: String?
    var classRef: String?
    
    init(_ titleStr: String, _ classStr:String) {
        title    = titleStr
        classRef = classStr
    }
}

public struct groupStruct{
    
    var  title : String?
    var  data  : Array<groupItem>?
    var  status = false
    
    init(_ groupTitle: String, _ groupData:Array<groupItem>) {
        title    = groupTitle
        data     = groupData
    }
}

public var groupData = [groupStruct("移动直播", [groupItem("自定义采集", "LiveCaptureVC"),
                                                groupItem("纹理预处理", "LiveTextureVC")]),
                       
                        groupStruct("实时音视频", [groupItem("自定采集", "CaptureVC"),
                                                 groupItem("美颜老接口", "RenderVC"),
                                                 groupItem("美颜新接口", "VideoProcessVC")]),
                        
                        groupStruct("播放器测试",  [groupItem("直播播放器", "LivePlayerVC")])
]
