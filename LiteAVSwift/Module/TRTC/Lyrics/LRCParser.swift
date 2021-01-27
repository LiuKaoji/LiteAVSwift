//
//  LRCParser.swift
//  LiteAVSwift
//
//  Created by kaoji on 2021/1/25.
//  Copyright © 2021 kaoji. All rights reserved.
//

import UIKit

struct LRCItem {
    var lrc: String = ""
    var lrcTime: UInt = 0
    
    init(_ item: String, _ time: UInt) {
        lrc = item
        lrcTime = time
    }
}

class LRCParser: NSObject {
    
    lazy var lRCArray = Array<LRCItem>()
    
    lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "[mm:ss.SS"
        return formatter
    }()

    func processLRC(path: String)->Array<LRCItem>{
        
        var parseArray = Array<String>()
        
        /// 读取
        guard let lrcStr =  try? String.init(contentsOfFile: path) else {
            debugPrint("[Fatal error]")
            return lRCArray
        }
        
        /// 分割
        parseArray = lrcStr.components(separatedBy: "\n")
        
        /// 移除空白
        for (index, element) in parseArray.enumerated().reversed() {
            if element.count == 0 {
                parseArray.remove(at: index)
            }
        }
        
        /// 解释每一行的时间 和歌词
        for (_, element) in parseArray.enumerated(){
            
            let itemArray = element.components(separatedBy: "]")
            let lrc:String = itemArray.last!
            
            let dateFirst = dateFormatter.date(from: itemArray[0])
            let dateSecond = dateFormatter.date(from: "[00:00.00")
            
            var intervalFirst = dateFirst?.timeIntervalSince1970
            let intervalSecond = dateSecond?.timeIntervalSince1970
            
            intervalFirst = intervalFirst! - intervalSecond!

            if (intervalFirst! < 0) {
                intervalFirst = intervalFirst! * -1
            }
            
            let item = LRCItem.init(lrc, UInt(intervalFirst! * 1000))
            
            lRCArray.append(item)
        }
        

        return lRCArray
    }
}
