//
//  QRSCanBorder.swift
//  LiteAVSwift
//
//  Created by kaoji on 2020/9/19.
//  Copyright © 2020 kaoji. All rights reserved.
//

import UIKit

class QRSCanBorder: UIImageView {
    
    //实现在二维码内上下扫动的动画
    var isAnimationing = false
    lazy var animationRect :CGRect = {
        return .init(origin: .zero, size: self.frame.size)
    }()
    
    var isDown = true
    
    lazy var lineView :UIImageView = {
        let line = UIImage.init(contentsOfFile: Bundle.main.path(forResource:"ScanLine", ofType: "png")!)
        let lineContainer = UIImageView.init(image: line)
        lineContainer.frame = .init(x: 0, y: 0, width: animationRect.width, height: 18)
        lineContainer.contentMode = .scaleAspectFit
        return lineContainer
    }()
    
    func startQRAnimating() {
        self.addSubview(lineView)
        isAnimationing = true
        if image != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                self.stepAnimation()
            }
        }
    }
    
    @objc func stepAnimation() {
        guard isAnimationing else {
            return
        }
        var frame = animationRect
        
        frame.origin.y -= self.frame.origin.y
        
        UIView.animate(withDuration: 1.0, animations: {
            var frame = self.animationRect
            frame.origin.y += (frame.size.height)
            self.lineView.frame.origin.y = (self.isDown ?(self.animationRect.height - self.lineView.frame.height):0)
        }, completion: { _ in
            self.isDown = !self.isDown
            self.perform(#selector(QRSCanBorder.stepAnimation), with: nil, afterDelay: 0.0)
        })
    }
    
    func stopStepAnimating() {
        isAnimationing = false
    }
    
    deinit {
        stopStepAnimating()
    }
}
