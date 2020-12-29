//
//  UIView(shake).swift
//  LiteAVSwift
//
//  Created by kaoji on 2020/9/28.
//  Copyright © 2020 kaoji. All rights reserved.
//
import UIKit

public enum ShakeDirection: Int
{
    case horizontal
    case vertical
}

extension UIView
{
    // MARK: - 扩展UIView,增加抖动方法
    ///
    /// - Parameters:
    ///   - direction: 抖动方向（默认是水平方向）
    ///   - times: 抖动次数（默认5次）
    ///   - interval: 每次抖动时间（默认0.1秒）
    ///   - delta: 抖动偏移量（默认2）
    ///   - completion: 抖动动画结束后的回调
    public func shake(direction: ShakeDirection = .horizontal, times: Int = 5, interval: TimeInterval = 0.1, delta: CGFloat = 2, completion: (() -> Void)? = nil)
    {
        UIView.animate(withDuration: interval, animations: {
            
            switch direction
            {
            case .horizontal:
                self.layer.setAffineTransform(CGAffineTransform(translationX: delta, y: 0))
            case .vertical:
                self.layer.setAffineTransform(CGAffineTransform(translationX: 0, y: delta))
            }
        }) { (finish) in
            
            if times == 0
            {
                UIView.animate(withDuration: interval, animations: {
                    self.layer.setAffineTransform(CGAffineTransform.identity)
                }, completion: { (finish) in
                    completion?()
                })
            }
            else
            {
                self.shake(direction: direction, times: times - 1, interval: interval, delta: -delta, completion: completion)
            }
        }
    }
    
    public func bounceAnimation(){
        
        self.layer.setAffineTransform(CGAffineTransform.init(scaleX: 0.7, y: 0.7))
        
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: []) {
            
            self.layer.setAffineTransform(CGAffineTransform.init(scaleX: 1, y: 1))

        } completion: { (completed) in
            
        }
    }
}
