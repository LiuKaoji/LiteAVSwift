//
//  LUTCIFilter.swift
//  LiteAVSwift
//
//  Created by kaoji on 2020/12/07.
//  Copyright © 2020 kaoji. All rights reserved.
//  fork from https://github.com/sharar10/CoreImagePlay.git

import UIKit
import Foundation
import CoreImage

protocol Filter {
    func setInputImage(_ image: CIImage)
    var outputImage: CIImage? { get }
}

protocol SimpleFilter: Filter {
    var filter: CIFilter? { get }
}

extension SimpleFilter {
    func setInputImage(_ image: CIImage) {
        filter?.setValue(image, forKey: kCIInputImageKey)
    }

    var outputImage: CIImage? {
        return filter?.outputImage
    }
}


struct LUTCIFilter: SimpleFilter {
    let filter: CIFilter?

    init(imageName: String) {
        filter = LUTCIFilter.colorCubeFilterFromLUT(imageName: imageName)
    }
}

extension LUTCIFilter {
    private static func colorCubeFilterFromLUT(imageName: String) -> CIFilter? {

        let size = 64

        let lutImage    = UIImage.init(contentsOfFile: imageName)!.cgImage
        let lutWidth    = lutImage!.width
        let lutHeight   = lutImage!.height
        let rowCount    = lutHeight / size
        let columnCount = lutWidth / size

        if ((lutWidth % size != 0) || (lutHeight % size != 0) || (rowCount * columnCount != size)) {
            NSLog("Invalid colorLUT %@", imageName);
            return nil
        }

        let bitmap  = getBytesFromImage(image: UIImage(named: imageName))!
        let floatSize = MemoryLayout<Float>.size

        let cubeData = UnsafeMutablePointer<Float>.allocate(capacity: size * size * size * 4 * floatSize)
        var z = 0
        var bitmapOffset = 0

        for _ in 0 ..< rowCount {
            for y in 0 ..< size {
                let tmp = z
                for _ in 0 ..< columnCount {
                    for x in 0 ..< size {

                        let red   = Float(bitmap[bitmapOffset]) / 255.0
                        let green     = Float(bitmap[bitmapOffset+1]) / 255.0
                        let blue   = Float(bitmap[bitmapOffset+2]) / 255.0
                        let alpha    = Float(bitmap[bitmapOffset+3]) / 255.0

                        let dataOffset = (z * size * size + y * size + x) * 4

                        cubeData[dataOffset + 0] = red
                        cubeData[dataOffset + 1] = green
                        cubeData[dataOffset + 2] = blue
                        cubeData[dataOffset + 3] = alpha
                        bitmapOffset += 4
                    }
                    z += 1
                }
                z = tmp
            }
            z += columnCount
        }

        let colorCubeData = NSData(bytesNoCopy: cubeData, length: size * size * size * 4 * floatSize, freeWhenDone: true)

        // create CIColorCube Filter
        let filter = CIFilter(name: "CIColorCube")
        filter?.setValue(colorCubeData, forKey: "inputCubeData")
        filter?.setValue(size, forKey: "inputCubeDimension")
        return filter
    }


    private static func getBytesFromImage(image:UIImage?) -> [UInt8]?
    {
        var pixelValues: [UInt8]?
        if let imageRef = image?.cgImage {
            let width = Int(imageRef.width)
            let height = Int(imageRef.height)
            let bitsPerComponent = 8
            let bytesPerRow = width * 4
            let totalBytes = height * bytesPerRow

            let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            var intensities = [UInt8](repeating: 0, count: totalBytes)

            let contextRef = CGContext(data: &intensities, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo)
            contextRef?.draw(imageRef, in: CGRect(x: 0.0, y: 0.0, width: CGFloat(width), height: CGFloat(height)))

            pixelValues = intensities
        }
        return pixelValues!
    }

}

