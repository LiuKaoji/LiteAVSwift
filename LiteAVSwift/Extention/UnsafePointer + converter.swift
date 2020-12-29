//
//  UnsafePointer.swift
//  LiteAVSwift
//
//  Created by kaoji on 2020/9/26.
//  Copyright © 2020 kaoji. All rights reserved.
//

extension String {
    var unsafePointer: UnsafePointer<Int8> {
        return self.withCString { $0 }
    }
    
    var unsafeBufferPointer: UnsafeBufferPointer<UInt8> {
        var tmpStr = self
        return tmpStr.withUTF8 { $0 }
    }
}

extension Data {
    var unsafeRawBufferPointer: UnsafeRawBufferPointer {
        return self.withUnsafeBytes { $0 }
    }
    
    var unsafeMutableRawBufferPointer: UnsafeMutableRawBufferPointer {
        var data = self
        return data.withUnsafeMutableBytes { $0 }
    }
    
    var unsafeBufferPointer_UInt8: UnsafeBufferPointer<UInt8>? {
        return self.withContiguousStorageIfAvailable { $0 }
    }
    
    var UnsafeMutableBufferPointer_UInt8: UnsafeMutableBufferPointer<UInt8>? {
        var data = self
        return data.withContiguousMutableStorageIfAvailable { $0 }
    }
}
