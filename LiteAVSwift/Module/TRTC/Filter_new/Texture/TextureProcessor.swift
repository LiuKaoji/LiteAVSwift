//
//  TextureProcessor.swift
//  LiteAVSwift
//
//  Created by kaoji on 2020/12/18.
//  Copyright © 2020 kaoji. All rights reserved.
//

import UIKit
import GPUImage

fileprivate var imageVertices: [GLfloat] = [
    -1, -1,
    1, -1,
    -1, 1,
    1, 1
]

fileprivate var noRotationTextureCoordinates: [GLfloat] = [
    0, 0,
    1, 0,
    0, 1,
    1, 1
]

class TextureProcessor: NSObject {
    
    /// 输入
    var size: CGSize!
    var texture: GLuint = GLuint()
    var textureOptions: GPUTextureOptions!
    
    //渲染
    var framebuffer: GLuint = GLuint()
    var renderTarget: CVPixelBuffer!
    var renderTexture:CVOpenGLESTexture!
    var filterProgram:GLProgram!
    var filterTextureCoordinateAttribute: GLint!
    var filterPositionAttribute : GLint!
    var filterInputTextureUniform: GLint!

    public func renderToTextureWithSize(_ size: CGSize, _ sourceTexture:GLuint) -> GLuint {
        
        filterProgram.use()
        setFilterFBO(size: size)
        
        glClearColor(0, 0, 0, 0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        
        glActiveTexture(GLenum(GL_TEXTURE2))
        glBindTexture(GLenum(GL_TEXTURE_2D), sourceTexture)
        
        glUniform1i(filterInputTextureUniform, 2)
        
        glVertexAttribPointer(GLuint(filterPositionAttribute), 2, GLenum(GL_FLOAT), 0, 0, imageVertices)
        glVertexAttribPointer(GLuint(filterTextureCoordinateAttribute), 2, GLenum(GL_FLOAT), 0, 0, noRotationTextureCoordinates)
        
        glDrawArrays(GLenum(GL_TRIANGLE_STRIP), 0, 4)
        
        return texture
    }

    
    override init() {
        super.init()
        setup()
    }
    
    private func setup(){
        
        filterProgram = .init(vertexShaderString: Shaders.processVertex, fragmentShaderString: Shaders.processFragement)
        
        if !filterProgram.initialized {
            
            initializeAttributes()
            
            if !filterProgram.link() {
                
                let progLog = filterProgram.programLog
                debugPrint("Program link log: \(progLog!)");
                
                let fragLog = filterProgram.fragmentShaderLog
                debugPrint("Program link log: \(fragLog!)");
                
                let vertLog = filterProgram.vertexShaderLog
                debugPrint("Program link log: \(vertLog!)");
                
                filterProgram = nil
                
                assert(filterProgram == nil, "Filter shader link failed")
            }
            
        }
        
        filterPositionAttribute = GLint(filterProgram.attributeIndex("position"))
        filterTextureCoordinateAttribute = GLint(filterProgram.attributeIndex("inputTextureCoordinate"))
        filterInputTextureUniform = GLint(filterProgram.uniformIndex("inputImageTexture"))
        
        filterProgram.use()
        
        glEnableVertexAttribArray(GLuint(filterPositionAttribute))
        glEnableVertexAttribArray(GLuint(filterTextureCoordinateAttribute))
        
        var defaultTextureOptions = GPUTextureOptions()
        defaultTextureOptions.minFilter = GLenum(GL_LINEAR)
        defaultTextureOptions.magFilter = GLenum(GL_LINEAR)
        defaultTextureOptions.wrapS = GLenum(GL_CLAMP_TO_EDGE)
        defaultTextureOptions.wrapT = GLenum(GL_CLAMP_TO_EDGE)
        defaultTextureOptions.internalFormat = GLenum(GL_RGBA)
        defaultTextureOptions.format = GLenum(GL_BGRA);
        defaultTextureOptions.type = GLenum(GL_UNSIGNED_BYTE)
        self.textureOptions = defaultTextureOptions
    }
    
    private func initializeAttributes() {
        
        filterProgram.addAttribute("position")
        filterProgram.addAttribute("inputTextureCoordinate")
    }
    
    private func generateTexture(){
        
        glActiveTexture(GLenum(GL_TEXTURE1))
        glGenTextures(1, &texture)
        glBindTexture(GLenum(GL_TEXTURE_2D), texture)
        
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GLint(textureOptions.minFilter))
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MAG_FILTER), GLint(textureOptions.magFilter))
        // This is necessary for non-power-of-two textures
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_S), GLint(textureOptions.wrapS))
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_T), GLint(textureOptions.wrapT))
        
        // TODO: Handle mipmaps
    }
    
    private func createDataFBO(){
        
        glGenFramebuffers(1, &framebuffer)
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), framebuffer)
        
        generateTexture()
        
        glBindTexture(GLenum(GL_TEXTURE_2D), texture);
        
        glTexImage2D(GLenum(GL_TEXTURE_2D), 0, GLint(textureOptions.internalFormat), GLsizei(size.width), GLsizei(size.height), 0, textureOptions.format, textureOptions.type, nil)
        glFramebufferTexture2D(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT0), GLenum(GL_TEXTURE_2D), texture, GLint(0))
        
        let status = glCheckFramebufferStatus(GLenum(GL_FRAMEBUFFER))
        assert(status == GL_FRAMEBUFFER_COMPLETE, "Incomplete filter FBO: \(status)")
        
        glBindTexture(GLenum(GL_TEXTURE_2D), 0)
        
    }
    
    private func setFilterFBO(size: CGSize){
        
        self.size = size
        if (framebuffer == 0)
        {
            createDataFBO()
        }
        
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), framebuffer)
        
        glViewport(0, 0, GLsizei(size.width), GLsizei(size.height))
    }
    
    private func destroyFramebuffer(){
        
        if ((framebuffer) != 0)
        {
            glDeleteFramebuffers(1, &framebuffer)
            framebuffer = 0;
        }
        
        glDeleteTextures(1, &texture)
        
    }
}
