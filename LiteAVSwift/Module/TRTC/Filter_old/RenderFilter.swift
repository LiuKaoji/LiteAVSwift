//
//  RenderFilter.swift
//  LiteAVSwift
//
//  Created by kaoji on 2020/9/23.
//  Copyright © 2020 kaoji. All rights reserved.
//

import UIKit

class RenderFilter: NSObject {

   private lazy var vignetteFilter:CIFilter = {
        let filter = CIFilter.init(name: "CIVignetteEffect")
        return filter!
    }()
    
    private lazy var effectFilter:CIFilter = {
        let filter = CIFilter.init(name: "CIPhotoEffectInstant")
        return filter!
    }()
    
    lazy var ciContext:CIContext = {
        let ciContext = CIContext.init(options: nil)
        return ciContext
    }()
    
    func filterFrame(_ frame:TRTCVideoFrame) -> CIImage {
        
        //原图
        let sourceImage  = CIImage.init(cvPixelBuffer: frame.pixelBuffer!)
        let sourceExtent = sourceImage.extent
    
        //圆圈
        vignetteFilter.setValue(sourceImage, forKey: kCIInputImageKey)
        vignetteFilter.setValue(CIVector.init(x: sourceExtent.width/2, y: sourceExtent.height/2), forKey: kCIInputCenterKey)
        vignetteFilter.setValue(sourceExtent.size.width/2, forKey: kCIInputRadiusKey)

        //效果
        var filteredImage = vignetteFilter.outputImage
        effectFilter.setValue(filteredImage, forKey: kCIInputImageKey)
        filteredImage = effectFilter.outputImage
        
        return filteredImage!
    }
}
