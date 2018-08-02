//
//  KTRegion.swift
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

 class KTRegion:UIBezierPath{
    
    var _pointViewArray = [KTPointView]()
    var _shapeLayer = CAShapeLayer()
    var context:UIView!
    var primary = UIColor.gray.withAlphaComponent(0.7)
    
    convenience init(region:KTRegion) {
        self.init(anchors: region._pointViewArray.map {
            return KTAnchor(point: $0.center, type: $0.type)
        }, context: region.context);
    }
    
    init  (anchors: [KTAnchor],context:UIView){
        super.init()
        self.context = context
        for anchor in anchors{
            let point = KTPointView(pointType: anchor.type, pointColor: primary)
            let this = self
            point.center = anchor.point
            point.dragCallBack = { [unowned self] (pointView: KTPointView, touch:UITouch) -> Void in
                self.onDragCallChangeShape(point, touch: touch, pointView: pointView,region: this)
            }
            if anchor.type == KTPointType.minor{
                // Add new point only on drag of small points
                point.touchEndCallback = { [unowned self] (pointView: KTPointView) -> Void in
                        self.addDots(point, this: this)
                    this.changeshape()
                }
            }
            _pointViewArray.append(point);
        }
    }
    
    func getXWithinBound(dx deltaX:CGFloat, dy deltaY:CGFloat, center:CGPoint)-> CGPoint{
        var cx = center.x, cy = center.y
        if((cx + deltaX) < context.frame.width && (cx + deltaX) > 0){
            cx = center.x + deltaX
        }
        if((cy + deltaY) < context.frame.height && (cy + deltaY) > 0){
            cy = center.y + deltaY
        }
        return CGPoint(x: cx, y:cy);
    }
    
    func onDragCallChangeShape(_ point: KTPointView, touch: UITouch, pointView:KTPointView, region: KTRegion){
        if point.type == KTPointType.major {
            if let index = self._pointViewArray.index(of: point){
                var prevIndex = index - 1
                var nextIndex = index + 1
                if prevIndex < 0{
                    prevIndex = self._pointViewArray.count - 1
                }
                if nextIndex >= self._pointViewArray.count{
                    nextIndex = 0
                }
                let dx = (touch.location(in: pointView.superview).x - touch.previousLocation(in: pointView.superview).x)
                let dy = (touch.location(in: pointView.superview).y - touch.previousLocation(in: pointView.superview).y)
                
                self._pointViewArray[prevIndex].center = getXWithinBound(dx: dx/2, dy: dy/2, center: self._pointViewArray[prevIndex].center)
                self._pointViewArray[nextIndex].center = getXWithinBound(dx: dx/2, dy: dy/2, center: self._pointViewArray[nextIndex].center)
            }
        }
        region.changeshape()
    }
    
    func addDots(_ point:KTPointView, this:KTRegion){
        if var index = self._pointViewArray.index(of: point){
            let currentPointUpdate = KTPointView(pointType : KTPointType.major, pointColor: primary)
            currentPointUpdate.center = point.center
            self._pointViewArray.remove(at: index)
            point.removeFromSuperview()
            self._pointViewArray.insert(currentPointUpdate, at: index)
            currentPointUpdate.dragCallBack = { [unowned self] (pointView: KTPointView, touch:UITouch) -> Void in
                self.onDragCallChangeShape(currentPointUpdate, touch: touch, pointView: pointView, region: this)
            }
            index = self._pointViewArray.index(of: currentPointUpdate)!
            let prevIndex = index == 0 ? self._pointViewArray.count - 1 : index - 1
            print(index, prevIndex)
            let newPreviousPoint = KTPointView(pointType : KTPointType.minor, pointColor: primary)
            newPreviousPoint.center = self.getMidPoint(self._pointViewArray[prevIndex].center, point2: point.center)
            self._pointViewArray.insert(newPreviousPoint, at: index)
            index = self._pointViewArray.index(of: currentPointUpdate)!
            let nextIndex = (index+1) % (self._pointViewArray.count)
            print(index, nextIndex)
            let newNextPoint = KTPointView(pointType : KTPointType.minor, pointColor: primary)
            newNextPoint.center = self.getMidPoint(currentPointUpdate.center, point2: self._pointViewArray[nextIndex].center)
            self._pointViewArray.insert(newNextPoint, at: nextIndex)
            newNextPoint.dragCallBack = { [unowned self] (pointView: KTPointView, touch:UITouch) -> Void in
                self.onDragCallChangeShape(newNextPoint, touch: touch, pointView: pointView, region: this)
            }
            newPreviousPoint.dragCallBack = { [unowned self] (pointView: KTPointView, touch:UITouch) -> Void in
                self.onDragCallChangeShape(newPreviousPoint, touch: touch, pointView: pointView, region: this)
            }
            newNextPoint.touchEndCallback = { [unowned self] (pointView: KTPointView) -> Void in
                this.changeshape()
                    self.addDots(point, this: this)
                print("n")
            }
            newPreviousPoint.touchEndCallback = { [unowned self] (pointView: KTPointView) -> Void in
                this.changeshape()
                    self.addDots(point, this: this)
                print("p")
            }
        }else{
            return;
        }
        this.changeshape()
        self.remove()
        self.draw()
    }
    
    func getMidPoint(_ point1:CGPoint, point2:CGPoint) -> CGPoint{
        return CGPoint(x: (point1.x + point2.x) / 2, y: (point1.y + point2.y) / 2)
    }
    
    
    public func draw(){
        for pointView in _pointViewArray{
            context.addSubview(pointView)
            print(pointView.center)
        }
        self.move(to: _pointViewArray.first!.center)
        addline()
        _shapeLayer = CAShapeLayer()
        _shapeLayer.strokeColor = primary.cgColor
        _shapeLayer.fillColor = primary.cgColor
        _shapeLayer.lineWidth = 1
        _shapeLayer.path = self.cgPath
        _shapeLayer.lineCap = convertToCAShapeLayerLineCap("round")
        _shapeLayer.sublayers?.removeAll()
        context.layer.addSublayer(_shapeLayer)
    }
    
    func remove(){
        for pointView in _pointViewArray{
            pointView.removeFromSuperview()
        }
        self.removeAllPoints()
        _shapeLayer.removeFromSuperlayer()
    }
    
    func changeshape(){
        self.removeAllPoints()
        self.move(to: _pointViewArray.first!.center)
        addline()
        _shapeLayer.path = self.cgPath
    }
    
    func addline(){
        for point in _pointViewArray{
            self.addLine(to: point.center)
        }
        self.close()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToCAShapeLayerLineCap(_ input: String) -> CAShapeLayerLineCap {
	return CAShapeLayerLineCap(rawValue: input)
}
