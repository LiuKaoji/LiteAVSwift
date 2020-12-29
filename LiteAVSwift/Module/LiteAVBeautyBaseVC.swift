//
//  LiteAVBeautyBaseVC.swift
//  LiteAVSwift
//
//  Created by kaoji on 2020/11/30.
//  Copyright © 2020 kaoji. All rights reserved.
//

import UIKit

enum BeautyBufferType: Int {
    case sample = 0
    case pixel = 1
}

class LiteAVBeautyBaseVC: UIViewController,GPUImageVideoCameraDelegate {
    
    /// 返回按钮
    lazy var backBtn = self.setupBackBtn()
    
    ///标题
    lazy var titleLabel = self.setupTitleLabel()
    
    /// 初始化TRT
    lazy var trtc = self.setupTRTC()

    /// 创建视频源
     lazy var camera : GPUImageVideoCamera? = GPUImageVideoCamera(sessionPreset: AVCaptureSession.Preset.hd1280x720.rawValue, cameraPosition: .front)
    
    /// 创建预览图层
     lazy var preview : GPUImageView = GPUImageView(frame: self.view.bounds)
    
    /// 美颜弹窗
    let beautyContainer = BeautyContainer()
    
    /// 初始化滤镜
    let beautyFilter = DotGPUImageBeautyFilter()
    
    /// 输出分辨率
    let captureResize = CGSize.init(width: 720, height: 1280)
    
    /// 输出buffer类型
    var outputType = BeautyBufferType.pixel
    
    /// 裸数据
    lazy var bufferOutput: LiteAVBufferOutput = LiteAVBufferOutput.init(imageSize: captureResize, resultsInBGRAFormat: true)
    
    /// 水印
    lazy var waterMarkIn: GPUImageUIElement = {
       
        let contentView = UIView(frame: CGRect(x: 0, y: 0, width: 720, height: 1280))
        let beardImageView = UIImageView(image: UIImage(named: "watermark")!)
        contentView.addSubview(beardImageView)
        beardImageView.frame = .init(origin: .zero, size: CGSize.init(width: 242, height: 70))
        beardImageView.center = contentView.center
        beardImageView.contentMode = .scaleAspectFit
        let uiElementInput = GPUImageUIElement(view: contentView)
        
        return uiElementInput!
        
    }()
    
    /// blend filter
    lazy var blendFilter: GPUImageAlphaBlendFilter = {
        let blend =  GPUImageAlphaBlendFilter()
        blend.mix = 1.0
        return blend
    }()
    
    convenience init(_ outputType: BeautyBufferType) {
        self.init()
        self.outputType = outputType
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.barStyle = .black
        self.view.backgroundColor = .black
        
        self.backBtn.addTarget(self, action: #selector(onClickBack), for: .touchUpInside)
        beautyContainer.beautySwitch.addTarget(self, action: #selector(switchBeautyEffect(switchBtn:)), for: .valueChanged)
        beautyContainer.beautySlider.sliderView.addTarget(self, action: #selector(beautyChange(sender:)), for: .valueChanged)
        beautyContainer.brightSlider.sliderView.addTarget(self, action: #selector(brightnessChange(sender:)), for: .valueChanged)
        beautyContainer.toneSlider.sliderView.addTarget(self, action: #selector(toneChange(sender:)), for: .valueChanged)
        
        setupCaptureEnv()
    }
    
    func setupCaptureEnv() {
        
        /// 相机配置
        camera?.delegate = self
        camera?.outputImageOrientation = .portrait
        camera?.horizontallyMirrorFrontFacingCamera = true
        camera?.frameRate = 15
        
        /// 创建预览的View
        preview.fillMode = kGPUImageFillModePreserveAspectRatioAndFill
        view.insertSubview(preview, at: 0)
        
        /// 默认开启滤镜
        setupbufferOutput()
        
        /// 设置GPUImage的响应链
        camera?.addTarget(beautyFilter)
        beautyFilter.addTarget(blendFilter)
        waterMarkIn.addTarget(blendFilter)
        blendFilter.addTarget(preview)
        blendFilter.addTarget(bufferOutput)
        
        beautyFilter.frameProcessingCompletionBlock = { filter, time in
            self.waterMarkIn.update()
        }

        camera?.startCapture()

    }
    
    func setupbufferOutput(){
        
        switch outputType {
        case .sample:
            bufferOutput.samplebufferCallback = { [weak self] sampleBuffer in
                self?.beautyOutputSampleBuffer(sampleBuffer)
            }

        case .pixel:
            bufferOutput.pixelBufferCallback = { [weak self] pixelBuffer in
                self?.beautyOutputPixelBuffer(pixelBuffer)
            }
        }
    }
    
    func willOutputSampleBuffer(_ sampleBuffer: CMSampleBuffer!) {
        /// 人脸识别
    }
    
    
    func beautyOutputSampleBuffer(_ sampleBuffer: CMSampleBuffer!) {
        /// 子类重写
    }
    
    
    func beautyOutputPixelBuffer(_ pixelBuffer: CVPixelBuffer!) {
       /// 子类重写
    }

    @objc func switchBeautyEffect(switchBtn : UISwitch) {
        
        camera?.removeAllTargets()

        if switchBtn.isOn {
            camera?.addTarget(beautyFilter)
            beautyFilter.addTarget(bufferOutput)

        } else {
            camera?.addTarget(preview)
            camera?.addTarget(bufferOutput)
        }
        
        
    }
    
    ///美颜
    @objc func beautyChange(sender: UISlider) {
     
        beautyContainer.beautySlider.valueLabel.text = String(format:"%.1f",sender.value)
        beautyFilter.beautyLevel = CGFloat(sender.value)
    }

    
    ///亮度
    @objc func brightnessChange(sender: UISlider) {
        // - 1 --> 1
        beautyContainer.brightSlider.valueLabel.text = String(format:"%.1f",sender.value)
        beautyFilter.brightLevel = CGFloat(sender.value)
    }
    
    ///色调
    @objc func toneChange(sender: UISlider) {
        beautyContainer.toneSlider.valueLabel.text = String(format:"%.1f",sender.value)
        beautyFilter.toneLevel = CGFloat(sender.value)
    }

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        beautyContainer.showBeautyView(sender: self)
    }

    deinit {
        GPUImageContext.sharedImageProcessing().framebufferCache.purgeAllUnassignedFramebuffers()
    }
    
    @objc func onClickBack(){
     
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
