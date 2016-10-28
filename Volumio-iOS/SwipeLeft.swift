//
//  SwipeLeft.swift
//
//  Code generated using QuartzCode 1.51.0 on 27/10/16.
//  www.quartzcodeapp.com
//

import UIKit

@IBDesignable
class SwipeLeft: UIView, CAAnimationDelegate {
    
    var layers : Dictionary<String, AnyObject> = [:]
    var completionBlocks : Dictionary<CAAnimation, (Bool) -> Void> = [:]
    var updateLayerValueForCompletedAnimation : Bool = false
    
    
    
    //MARK: - Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupProperties()
        setupLayers()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        setupProperties()
        setupLayers()
    }
    
    
    
    func setupProperties(){
        
    }
    
    func setupLayers(){
        self.backgroundColor = UIColor.black.withAlphaComponent(0)
        
        let slide = CALayer()
        slide.frame = CGRect(x: 49, y: 24, width: 51, height: 56)
        self.layer.addSublayer(slide)
        layers["slide"] = slide
        
        resetLayerProperties(forLayerIdentifiers: nil)
    }
    
    func resetLayerProperties(forLayerIdentifiers layerIds: [String]!){
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        if layerIds == nil || layerIds.contains("slide"){
            let slide = layers["slide"] as! CALayer
            slide.contents = UIImage(named:"slide")?.cgImage
        }
        
        CATransaction.commit()
    }
    
    //MARK: - Animation Setup
    
    func addToLeftAnimation(reverseAnimation: Bool = false, completionBlock: ((_ finished: Bool) -> Void)? = nil){
        if completionBlock != nil{
            let completionAnim = CABasicAnimation(keyPath:"completionAnim")
            completionAnim.duration = 1
            completionAnim.delegate = self
            completionAnim.setValue("toLeft", forKey:"animId")
            completionAnim.setValue(false, forKey:"needEndAnim")
            layer.add(completionAnim, forKey:"toLeft")
            if let anim = layer.animation(forKey: "toLeft"){
                completionBlocks[anim] = completionBlock
            }
        }
        
        let fillMode : String = reverseAnimation ? kCAFillModeBoth : kCAFillModeForwards
        
        let totalDuration : CFTimeInterval = 1
        
        ////Slide animation
        let slidePositionAnim      = CAKeyframeAnimation(keyPath:"position")
        slidePositionAnim.values   = [NSValue(cgPoint: CGPoint(x: 74.5, y: 52)), NSValue(cgPoint: CGPoint(x: 25, y: 52))]
        slidePositionAnim.keyTimes = [0, 1]
        slidePositionAnim.duration = 1
        
        var slideToLeftAnim : CAAnimationGroup = QCMethod.group(animations: [slidePositionAnim], fillMode:fillMode)
        if (reverseAnimation){ slideToLeftAnim = QCMethod.reverseAnimation(anim: slideToLeftAnim, totalDuration:totalDuration) as! CAAnimationGroup}
        layers["slide"]?.add(slideToLeftAnim, forKey:"slideToLeftAnim")
    }
    
    //MARK: - Animation Cleanup
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool){
        if let completionBlock = completionBlocks[anim]{
            completionBlocks.removeValue(forKey: anim)
            if (flag && updateLayerValueForCompletedAnimation) || anim.value(forKey: "needEndAnim") as! Bool{
                updateLayerValues(forAnimationId: anim.value(forKey: "animId") as! String)
                removeAnimations(forAnimationId: anim.value(forKey: "animId") as! String)
            }
            completionBlock(flag)
        }
    }
    
    func updateLayerValues(forAnimationId identifier: String){
        if identifier == "toLeft"{
            QCMethod.updateValueFromPresentationLayer(forAnimation: (layers["slide"] as! CALayer).animation(forKey: "slideToLeftAnim"), theLayer:(layers["slide"] as! CALayer))
        }
    }
    
    func removeAnimations(forAnimationId identifier: String){
        if identifier == "toLeft"{
            (layers["slide"] as! CALayer).removeAnimation(forKey: "slideToLeftAnim")
        }
    }
    
    func removeAllAnimations(){
        for layer in layers.values{
            (layer as! CALayer).removeAllAnimations()
        }
    }
    
}
