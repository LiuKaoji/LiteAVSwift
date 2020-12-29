//
//  LUTCIFilterContainer.swift
//  LiteAVSwift
//
//  Created by kaoji on 2020/12/07.
//  Copyright © 2020 kaoji. All rights reserved.
//

import UIKit

class LUTCIFilterContainer: UIViewController {
   
    //MARK: Filter
    let LUTFilterName = ["bailan.png": "白兰",
                      "baixi.png": "白皙",
                      "chaotuo.png" : "超脱",
                      "chunzhen.png" : "纯真",
                      "fennen.png" : "粉嫩",
                      "huaijiu.png" : "怀旧",
                      "landiao.png" : "蓝调",
                      "langman.png" : "浪漫",
                      "qingliang.png" : "清凉",
                      "qingxin.png" : "清新",
                      "rixi.png" : "日系",
                      "weimei.png" : "唯美",
                      "xiangfen.png" : "香氛",
                      "yinghong.png" : "樱红",
                      "yuanqi.png" : "元气",
                      "yunshang.png" : "云裳",
                      "ziran.png" : "自然",
                      
    ]

    let lutPath = Bundle.main.path(forResource: "LUT", ofType: "bundle")
    let lutPreViewPath = Bundle.main.path(forResource: "LUTPreview", ofType: "bundle")
    
    var lutFilter: LUTCIFilter!
    var lutFilterData = [LUTEffectStruct]()
    var lutIndex: Int = 0
    
    // contex
    lazy var ciContext:CIContext = {
        let ciContext = CIContext.init(options: nil)
        return ciContext
    }()
    
    /// 需要通过此方法初始化
    required convenience init(lutName: String) {
        self.init()
        readLutDataSource()
        lutFilterData[0].selected = true
        let _ = self.setFilter(effectStruct: lutFilterData[0])
    }

    
    /// 修改Filter
    public func setFilter(effectStruct: LUTEffectStruct) -> LUTCIFilter{
        
        lutFilter = LUTCIFilter.init(imageName: effectStruct.lutImageName)
        return lutFilter
        
    }
    
    /// 处理buffer 数据
    public func processFrameBuffer(src :TRTCVideoFrame, dst: TRTCVideoFrame){
        
        /// 01. buffer to CIImage
        let sourceImage  = CIImage.init(cvPixelBuffer: src.pixelBuffer!)

        /// 02. bind to filter
        lutFilter.setInputImage(sourceImage)
  
        /// 03. process Image
        let outputImage = lutFilter.outputImage!
        
        /// 04. render to destination-buffer
        ciContext.render(outputImage, to: dst.pixelBuffer!)
    }
    
    /// 读取LUT图和预览图 备用
    private func readLutDataSource(){
        
        let fileManager = FileManager.default
        let contents = try? fileManager.contentsOfDirectory(atPath: lutPath!)
        
        contents!.forEach{ item in
            
            var effectStruct = LUTEffectStruct()
            effectStruct.lutImageName = lutPath! + "/" + item
            effectStruct.previewImage = UIImage.init(contentsOfFile: lutPreViewPath! + "/" + item)
            effectStruct.previewImage_s = UIImage.init(contentsOfFile: lutPreViewPath! + "/" + item) 
            effectStruct.lutItemName = LUTFilterName[item]!
            
            lutFilterData.append(effectStruct)
        }
    }
    
    //MARK: Pop UI
    var effectView: LUTSelectView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        self.view.backgroundColor = rgba(0, 0, 0, 0.9)
    }
    
    func setupUI(){
        
        let label = createLabel(font: .boldSystemFont(ofSize: 18), color: .white, text: "请选择滤镜效果", alignment: .center)
        label.frame = .init(x: 0, y: 0, width: SCREEN_WIDTH, height: 48)
        label.addBorder(color: .red, lineWidth: 0.5, position: .bottom)
        self.view.addSubview(label)
        
        effectView = LUTSelectView.init(frame: .init(x: 0, y: label.frame.maxY, width: SCREEN_WIDTH, height: 88))
        effectView.effectDataSource = lutFilterData
        self.view.addSubview(effectView)
        
        effectView.effectAction = { [weak self] effectStruct in
           let _ = self?.setFilter(effectStruct: effectStruct)
        }
    
    }
    
    /// 弹出滤镜容器
    func showLUTSelectView(sender:UIViewController){
        self.preferredContentSize = .init(width: SCREEN_WIDTH, height: isBangDevice ?280:240)
        
        let segue = SwiftMessagesSegue(identifier: nil, source: sender, destination: self)
        segue.duration = .forever
        segue.presentationStyle = .bottom
        segue.dimMode = .color(color: .clear, interactive: true)
        segue.perform()
    }
}
