//
//  LiteAVBufferOutput.swift
//  LiteAVSwift
//
//  Created by kaoji on 2020/12/7.
//  Copyright © 2020 kaoji. All rights reserved.
//

import UIKit

class LiteAVBufferOutput: GPUImageRawDataOutput {

    /// 输出samplebuffer
    typealias SampleBufferOutput = ((CMSampleBuffer) -> (Void))
    /// 输出pixelbuffer
    typealias PixelBufferOutput  = ((CVPixelBuffer) -> (Void))
    
    var samplebufferCallback: SampleBufferOutput?
    var pixelBufferCallback: PixelBufferOutput?
    
    override init!(imageSize newImageSize: CGSize, resultsInBGRAFormat: Bool) {
        super.init(imageSize: newImageSize, resultsInBGRAFormat: resultsInBGRAFormat)
    }
    
    override func newFrameReady(at frameTime: CMTime, at textureIndex: Int) {
        
        super.newFrameReady(at: frameTime, at: textureIndex)
        
        ///lock
        self.lockFramebufferForReading()
        
        
        /// 处理数据
        outputData(at: frameTime, at: textureIndex)
        
        
        /// unlock
        self.unlockFramebufferAfterReading()
    }
    
    func outputData(at frameTime: CMTime, at textureIndex: Int){
        
        /// 将数据转换成CVPixelBuffer
        let width = Int(self.maximumOutputSize().width)
        let height = Int(self.maximumOutputSize().height)
        
        let pointer = self.rawBytesForImage
        let data = CFDataCreate(nil, self.rawBytesForImage, width*height*4)
        let unmanagedData = Unmanaged<CFData>.passRetained(data!)
        
        var pixelBuffer: CVPixelBuffer?
        var status = CVPixelBufferCreateWithBytes(kCFAllocatorDefault,
                                                  width,
                                                  height,
                                                  kCVPixelFormatType_32BGRA,
                                                  pointer!,
                                                  width*4,
                                                  { releaseContext, baseAddress in
                                                    let contextData = Unmanaged<CFData>.fromOpaque(releaseContext!)
                                                    contextData.release()
                                                  },
                                                  unmanagedData.toOpaque(),
                                                  nil,
                                                  &pixelBuffer)
        
        if (status != kCVReturnSuccess) {
            return;
        }
        
        if (pixelBufferCallback != nil) {
            pixelBufferCallback!(pixelBuffer!)
        }
        
        
        /// 需要输出数据再往下走
        guard samplebufferCallback != nil else {
            return
        }


        var description:CMVideoFormatDescription?
        status = CMVideoFormatDescriptionCreateForImageBuffer(allocator: kCFAllocatorDefault, imageBuffer: pixelBuffer!, formatDescriptionOut: &description)

        guard let _description:CMVideoFormatDescription = description else {
            return
        }

        var sampleBuffer:CMSampleBuffer?
        var timing:CMSampleTimingInfo = CMSampleTimingInfo()
        timing.presentationTimeStamp = frameTime
        status = CMSampleBufferCreateForImageBuffer(
            allocator: kCFAllocatorDefault,
            imageBuffer: pixelBuffer!,
            dataReady: true,
            makeDataReadyCallback: nil,
            refcon: nil,
            formatDescription: _description,
            sampleTiming: &timing,
            sampleBufferOut: &sampleBuffer
        )

        samplebufferCallback!(sampleBuffer!)
    }
}
