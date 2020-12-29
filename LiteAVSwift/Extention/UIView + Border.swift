//
//  UIView(Border).swift
//  LiteAVSwift
//
//  Created by kaoji on 2020/9/6.
//  Copyright © 2020 kaoji. All rights reserved.
//

import UIKit

//MARK:-UIView添加线
public enum BorderPosition:Int {
    case all = 0
    case top = 1
    case bottom = 2
    case left = 3
    case right = 4
}
extension UIView{
    
    func addBorder(color:UIColor, lineWidth:CGFloat, position:BorderPosition){
       
        if(position == BorderPosition.all){
            self.layer.borderColor = color.cgColor
            self.layer.borderWidth = lineWidth
            return
        }
        
        var layer:CAShapeLayer?
        switch position {
        case .top:
            layer = addLine(originPoint: CGPoint.init(x: 0, y: 0), toPoint: CGPoint.init(x: self.frame.width, y: 0), color: color, lineWidth: lineWidth)
        case .left:
            layer = addLine(originPoint: CGPoint.init(x: 0, y: 0), toPoint: CGPoint.init(x: 0, y: self.frame.height), color: color, lineWidth: lineWidth)
        case .bottom:
            layer = addLine(originPoint: CGPoint.init(x: 0, y: self.frame.height), toPoint: CGPoint.init(x: self.frame.width, y: self.frame.height), color: color, lineWidth: lineWidth)
        case .right:
            layer = addLine(originPoint: CGPoint.init(x: self.frame.width, y: 0), toPoint: CGPoint.init(x: self.frame.width, y: self.frame.height), color: color, lineWidth: lineWidth)
        case .all:
            break
        }
        self.layer.addSublayer(layer ?? CAShapeLayer())
    }
    
    func addLine(originPoint:CGPoint, toPoint:CGPoint, color:UIColor, lineWidth:CGFloat) -> CAShapeLayer{
        let bezierPath = UIBezierPath()//线的路径
        bezierPath.move(to: originPoint)
        bezierPath.addLine(to: toPoint)
        
        let shapeLayer = CAShapeLayer()//塞贝尔曲线
        shapeLayer.strokeColor = color.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.path = bezierPath.cgPath
        shapeLayer.lineWidth = lineWidth
        return shapeLayer
    }
}

