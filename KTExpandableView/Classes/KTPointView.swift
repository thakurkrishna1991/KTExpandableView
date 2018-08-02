//
//  KTPointView.swift
//  KTExpandableView
//
//  Created by Krishna  Thakur on 25/06/18.
//
/*
 Copyright (c) 2018 Krishna Kumar <thakurkrishna1991@gmail.com>
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

import Foundation
import UIKit

class KTPointView:UIControl{
    
    let MAJOR_POINT_SIZE:CGFloat = 17.0
    let MINOR_POINT_SIZE:CGFloat = 17.0
    var touchStart:CGPoint?
    var type :KTPointType!
    var touchEndCallback = { (pointView: KTPointView) -> Void in }
    var touchBeganCallback = { (pointView: KTPointView) -> Void in }
    var dragCallBack = { (pointView: KTPointView, touch:UITouch) -> Void in }
    
    init(pointType : KTPointType, pointColor: UIColor){
        self.type = pointType
        if type == KTPointType.major{
            super.init(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: MAJOR_POINT_SIZE * 2, height: MAJOR_POINT_SIZE * 2)))
            self.layer.cornerRadius = MAJOR_POINT_SIZE
            self.layer.masksToBounds = true
            self.backgroundColor = pointColor
            self.addTarget(self, action: #selector(self.touchDragInside(_:withEvent:)), for: .touchDragInside)
        }else{
            super.init(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: MINOR_POINT_SIZE * 2, height: MINOR_POINT_SIZE * 2)))
            self.layer.cornerRadius = MINOR_POINT_SIZE
            self.layer.masksToBounds = true
            self.backgroundColor = pointColor
            self.addTarget(self, action: #selector(self.touchDragInside(_:withEvent:)), for: .touchDragInside)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func touchDragInside(_ pointView: KTPointView, withEvent event: UIEvent) {
        for touch in event.allTouches! {
            pointView.center = (touch).location(in: superview)
            dragCallBack(self,touch)
            return
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event);
        for touch: AnyObject in touches {
            touchBeganCallback(self)
            let location:CGPoint = (touch as! UITouch).location(in: self.superview)
            self.touchStart = location
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.touchStart = nil
        let touch = touches.first
        let location : CGPoint = (touch?.location(in: self))!
        if self.point(inside: self.convert(location, to: self.forLastBaselineLayout), with: nil) {
            touchEndCallback(self)
        }
        super.touchesEnded(touches, with: event)
    }
}
