//
//  ViewController.swift
//  KTExpandableView
//
//  Created by Krishna  Thakur on 02/08/18.
//

import UIKit

open class KTExpandableViewController: UIViewController {

    let _curve = UIBezierPath()
    let _shapeLayer = CAShapeLayer()
    var _pointViewArray = [KTPointView]()
    var isTouchingRegion:KTRegion?
    var isTouchingRegionCopy:KTRegion?
    var tempx:CGFloat!
    var tempy:CGFloat!
    var z = [KTRegion]()
    var motionData = [Region]()
    var regions = [KTRegion]()
    var resionSave:Region?
    
    override open func viewDidLoad() {
        super.viewDidLoad()
                var anchorArray = [KTAnchor]()
                anchorArray.append(KTAnchor(point: CGPoint(x: 150 , y: 150), type: KTPointType.major))
                anchorArray.append(KTAnchor(point: self.getMidPoint(CGPoint(x: 200 , y: 200),point2: CGPoint(x: 250 , y: 200)) , type: KTPointType.minor))
                anchorArray.append(KTAnchor(point: CGPoint(x: 300 , y: 150), type: KTPointType.major))
                anchorArray.append(KTAnchor(point: self.getMidPoint(CGPoint(x: 300 , y: 300),point2: CGPoint(x: 300 , y: 250)) , type: KTPointType.minor))
                anchorArray.append(KTAnchor(point: CGPoint(x: 300 , y: 300), type: KTPointType.major))
                anchorArray.append(KTAnchor(point: self.getMidPoint(CGPoint(x: 200 , y: 350),point2: CGPoint(x: 250 , y: 350)) , type: KTPointType.minor))
                anchorArray.append(KTAnchor(point: CGPoint(x: 150 , y: 300), type: KTPointType.major))
                anchorArray.append(KTAnchor(point: self.getMidPoint(CGPoint(x: 150 , y: 350),point2: CGPoint(x: 150 , y: 200)) , type: KTPointType.minor))
                let newRegion = KTRegion(anchors: anchorArray, context: self.view)
                regions.append(newRegion)
                newRegion.draw()
    }
    
    func getMidPoint(_ point1:CGPoint, point2:CGPoint) -> CGPoint{
        return CGPoint(x: (point1.x + point2.x) / 2, y: (point1.y + point2.y) / 2)
    }
    
    
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch: AnyObject in touches {
            if touch.view != self.view {
                return
            }
            let position :CGPoint = touch.location(in: self.view)
            let location:CGPoint = (touch as! UITouch).location(in: self.view)
            for j in 0  ..< regions.count {
                if (regions[j]._shapeLayer.path?.contains(location))!{
                    isTouchingRegion = regions[j]
                    z = (regions.map { return KTRegion( region: $0 ) })
                    isTouchingRegionCopy = z[j]
                    tempx = position.x
                    tempy = position.y
                }
            }
        }
    }
    
    override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches {
            let position :CGPoint = touch.location(in: self.view)
            let location:CGPoint = (touch as! UITouch).location(in: self.view)
            if isTouchingRegion != nil && isTouchingRegionCopy != nil{
                if position.x <= 0{
                    print(position.x,position.y)
                }
                if isTouchingRegion!._shapeLayer.path!.contains(location) //shape 1
                {
                    let dx = position.x - self.tempx
                    let dy = position.y - self.tempy
                    switch (getDirectionForOutOfBounds(dx, dy: dy)) {
                    case 0:
                        for i in 0  ..< isTouchingRegion!._pointViewArray.count  {
                            isTouchingRegion!._pointViewArray[i].center.x = isTouchingRegionCopy!._pointViewArray[i].center.x + dx
                            isTouchingRegion!._pointViewArray[i].center.y = isTouchingRegionCopy!._pointViewArray[i].center.y + dy
                        }
                        break;
                    case 2:
                        for i in 0  ..< isTouchingRegion!._pointViewArray.count  {
                            isTouchingRegion!._pointViewArray[i].center.y = isTouchingRegionCopy!._pointViewArray[i].center.y + dy
                        }
                        break;
                    case 3:
                        for i in 0  ..< isTouchingRegion!._pointViewArray.count  {
                            isTouchingRegion!._pointViewArray[i].center.x = isTouchingRegionCopy!._pointViewArray[i].center.x + dx
                        }
                        break;
                    default: break
                    }
                }
                isTouchingRegion!.changeshape()
            }
        }
    }
    
    func getDirectionForOutOfBounds(_ dx:CGFloat, dy:CGFloat) -> Int{
        var isX = false
        var isY = false
        for i in 0  ..< isTouchingRegion!._pointViewArray.count  {
            let isOutOfBoundInX = (isTouchingRegionCopy!._pointViewArray[i].center.x + dx) > self.view.frame.width || (isTouchingRegionCopy!._pointViewArray[i].center.x + dx) < 0;
            let isOutOfBoundInY = (isTouchingRegionCopy!._pointViewArray[i].center.y + dy) > self.view.frame.height || (isTouchingRegionCopy!._pointViewArray[i].center.y + dy) < 0;
            if (isOutOfBoundInX && isOutOfBoundInY) {
                return 1;
            }
            if (isOutOfBoundInX) {
                isX = true;
            } else if (isOutOfBoundInY) {
                isY = true;
            }
        }
        if (isX && isY){
            return 1;
        }else if(isX){
            return 2;
        }else if(isY){
            return 3;
        }
        return 0;
    }
    
    func isOutOfBound(_ x:CGFloat, y:CGFloat) -> Bool{
        return x <= 0 || y <= 0 || x >= self.view.frame.width || y >= self.view.frame.height
    }
    
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isTouchingRegion = nil
        isTouchingRegionCopy = nil
    }
  

}
