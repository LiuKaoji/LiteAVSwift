//
//  GLView.swift
//  LiteAVSwift
//
//  Created by kaoji on 2020/9/23.
//  Copyright © 2020 kaoji. All rights reserved.
//

import UIKit
import GLKit
import OpenGLES

class GLView: UIView {
    
    //上下文
    private lazy var eaglContext:EAGLContext = {
        let context = EAGLContext.init(api: .openGLES2)
        return context!
    }()

    //画面承载
    private lazy var previewView: GLKView = {
        let preview = GLKView.init(frame: self.frame, context: eaglContext)
        return preview
    }()
    
    private lazy var ciContext:CIContext = {
        let context = CIContext.init(eaglContext: eaglContext, options: [CIContextOption.workingColorSpace: NSNull()])
        return context
    }()
    
    //画面绘制宽高
    private var previewBounds: CGRect!

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGLView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupGLView(){
        
        self.addSubview(previewView)
        self.sendSubviewToBack(previewView)
        
        previewView.bindDrawable()
        previewView.enableSetNeedsDisplay = true
        previewBounds = .init(x: 0, y: 0, width: previewView.drawableWidth, height: previewView.drawableHeight)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        previewView.deleteDrawable()
        previewView.bindDrawable()
        previewBounds = .init(x: 0, y: 0, width: previewView.drawableWidth, height: previewView.drawableHeight)
    }
    
     //MARK:- 渲染 TRTCVideoFrame
    public func render(_ frame:TRTCVideoFrame){
        
        renderPixel(pixelBuffer: frame.pixelBuffer!)
    }
    
    //MARK:- 渲染 CVPixelBuffer
    public func renderPixel(pixelBuffer:CVPixelBuffer){
        
        let sourceImage  = CIImage.init(cvPixelBuffer: pixelBuffer)
        renderCIImageForDisplay(sourceImage)
    }
    
    //MARK:- 渲染 CIImage
    public func renderCIImage(_ sourceImage :CIImage){
        
        renderCIImageForDisplay(sourceImage)
    }
    
    private func renderCIImageForDisplay(_ sourceImage: CIImage){
        
        let sourceExtent = sourceImage.extent
        let sourceAspect = sourceExtent.size.width / sourceExtent.size.height;
        let previewAspect = previewBounds.size.width  / previewBounds.size.height;
        
        //我们想保持屏幕大小的纵横比，所以我们剪辑视频图像
        var drawRect = sourceExtent;
        if sourceAspect > previewAspect {
            
            // 使用视频图像的全高，并将宽度居中裁剪
            drawRect.origin.x += (drawRect.size.width - drawRect.size.height * previewAspect) / 2.0
            drawRect.size.width = drawRect.size.height * previewAspect
            
        }else{
            
            //使用视频图像的全宽，并将高度居中裁剪
            drawRect.origin.y += (drawRect.size.height - drawRect.size.width / previewAspect) / 2.0
            drawRect.size.height = drawRect.size.width / previewAspect
        }
        
        previewView.bindDrawable()
        
        if eaglContext != EAGLContext.current(){
            EAGLContext.setCurrent(eaglContext)
        }
        
        // 将 eagl view 清除变为灰色
        glClearColor(0.5, 0.5, 0.5, 1.0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT));
        
        // 将混合模式设置为“源结束”，以便CI使用该模式
        glEnable(GLenum(GL_BLEND))
        glBlendFunc(GLenum(GL_ONE), GLenum(GL_ONE_MINUS_SRC_ALPHA))
        
        //将图像渲染在视图以展示
        ciContext.draw(sourceImage, in: previewBounds, from: drawRect)
        previewView.display()
    }
}
