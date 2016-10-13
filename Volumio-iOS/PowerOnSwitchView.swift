//
//  PowerOnSwitchView.swift
//
//  Code generated using QuartzCode 1.50.0 on 11/10/16.
//  www.quartzcodeapp.com
//

import UIKit

@IBDesignable
class PowerOnSwitchView: UIView, CAAnimationDelegate {
	
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
        let roundedRect = CAShapeLayer()
        roundedRect.frame = CGRect(x: 2, y: 2, width: 87.99, height: 40)
        roundedRect.path = roundedRectPath().cgPath
        self.layer.addSublayer(roundedRect)
        layers["roundedRect"] = roundedRect
        
        let powerOff = CALayer()
        powerOff.frame = CGRect(x: 5.91, y: 5.57, width: 32, height: 33)
        self.layer.addSublayer(powerOff)
        layers["powerOff"] = powerOff
        
        let Volumio = CALayer()
        Volumio.frame = CGRect(x: 54, y: 6, width: 32, height: 32)
        self.layer.addSublayer(Volumio)
        layers["Volumio"] = Volumio
        
        resetLayerProperties(forLayerIdentifiers: nil)
    }
    
    func resetLayerProperties(forLayerIdentifiers layerIds: [String]!){
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        if layerIds == nil || layerIds.contains("roundedRect"){
            let roundedRect = layers["roundedRect"] as! CAShapeLayer
            roundedRect.fillColor = UIColor(red:0.298, green: 0.278, blue:0.275, alpha:1).cgColor
            roundedRect.lineWidth = 0
            roundedRect.strokeColor = UIColor(red: 194.0/255.0, green: 190/255, blue: 189/255, alpha:1).cgColor
        }
        if layerIds == nil || layerIds.contains("powerOff"){
            let powerOff = layers["powerOff"] as! CALayer
            powerOff.contents = UIImage(named:"powerOff")?.cgImage
        }
        if layerIds == nil || layerIds.contains("Volumio"){
            let Volumio = layers["Volumio"] as! CALayer
            Volumio.isHidden    = true
            Volumio.anchorPoint = CGPoint(x: 0.2, y: 0.5)
            Volumio.frame       = CGRect(x: 54, y: 6, width: 32, height: 32)
            Volumio.contents    = UIImage(named:"Volumio")?.cgImage
        }
        
        CATransaction.commit()
    }
    
    //MARK: - Animation Setup
    
    func addSwitchOnAnimation(reverseAnimation: Bool = false, completionBlock: ((_ finished: Bool) -> Void)? = nil){
        if completionBlock != nil{
            let completionAnim = CABasicAnimation(keyPath:"completionAnim")
            completionAnim.duration = 2
            completionAnim.delegate = self
            completionAnim.setValue("SwitchOn", forKey:"animId")
            completionAnim.setValue(false, forKey:"needEndAnim")
            layer.add(completionAnim, forKey:"SwitchOn")
            if let anim = layer.animation(forKey: "SwitchOn"){
                completionBlocks[anim] = completionBlock
            }
        }
        
        let fillMode : String = reverseAnimation ? kCAFillModeBoth : kCAFillModeForwards
        
        let totalDuration : CFTimeInterval = 2
        
        ////RoundedRect animation
        let roundedRectFillColorAnim      = CAKeyframeAnimation(keyPath:"fillColor")
        roundedRectFillColorAnim.values   = [UIColor(red:0.298, green: 0.278, blue:0.275, alpha:1).cgColor,
                                             UIColor.white.cgColor]
        roundedRectFillColorAnim.keyTimes = [0, 1]
        roundedRectFillColorAnim.duration = 1.19
        roundedRectFillColorAnim.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseIn)
        
        let roundedRectLineWidthAnim      = CAKeyframeAnimation(keyPath:"lineWidth")
        roundedRectLineWidthAnim.values   = [0, 2]
        roundedRectLineWidthAnim.keyTimes = [0, 1]
        roundedRectLineWidthAnim.duration = 2
        roundedRectLineWidthAnim.timingFunction = CAMediaTimingFunction(controlPoints: 0, 0, 0.58, 1)
        
        var roundedRectSwitchOnAnim : CAAnimationGroup = QCMethod.group(animations: [roundedRectFillColorAnim, roundedRectLineWidthAnim], fillMode:fillMode)
        if (reverseAnimation){ roundedRectSwitchOnAnim = QCMethod.reverseAnimation(anim: roundedRectSwitchOnAnim, totalDuration:totalDuration) as! CAAnimationGroup}
        layers["roundedRect"]?.add(roundedRectSwitchOnAnim, forKey:"roundedRectSwitchOnAnim")
        
        ////PowerOff animation
        let powerOffPositionAnim            = CAKeyframeAnimation(keyPath:"position")
        powerOffPositionAnim.values         = [NSValue(cgPoint: CGPoint(x: 21.907, y: 22.074)), NSValue(cgPoint: CGPoint(x: 68, y: 23))]
        powerOffPositionAnim.keyTimes       = [0, 1]
        powerOffPositionAnim.duration       = 1
        powerOffPositionAnim.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseOut)
        
        let powerOffTransformAnim      = CAKeyframeAnimation(keyPath:"transform.rotation.z")
        powerOffTransformAnim.values   = [0,
                                          328 * CGFloat(M_PI/180)]
        powerOffTransformAnim.keyTimes = [0, 1]
        powerOffTransformAnim.duration = 1
        
        let powerOffHiddenAnim       = CAKeyframeAnimation(keyPath:"hidden")
        powerOffHiddenAnim.values    = [true, true]
        powerOffHiddenAnim.keyTimes  = [0, 1]
        powerOffHiddenAnim.duration  = 1
        powerOffHiddenAnim.beginTime = 1
        
        var powerOffSwitchOnAnim : CAAnimationGroup = QCMethod.group(animations: [powerOffPositionAnim, powerOffTransformAnim, powerOffHiddenAnim], fillMode:fillMode)
        if (reverseAnimation){ powerOffSwitchOnAnim = QCMethod.reverseAnimation(anim: powerOffSwitchOnAnim, totalDuration:totalDuration) as! CAAnimationGroup}
        layers["powerOff"]?.add(powerOffSwitchOnAnim, forKey:"powerOffSwitchOnAnim")
        
        ////Volumio animation
        let VolumioHiddenAnim            = CAKeyframeAnimation(keyPath:"hidden")
        VolumioHiddenAnim.values         = [true, false]
        VolumioHiddenAnim.keyTimes       = [0, 1]
        VolumioHiddenAnim.duration       = 1.51
        VolumioHiddenAnim.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseIn)
        
        var VolumioSwitchOnAnim : CAAnimationGroup = QCMethod.group(animations: [VolumioHiddenAnim], fillMode:fillMode)
        if (reverseAnimation){ VolumioSwitchOnAnim = QCMethod.reverseAnimation(anim: VolumioSwitchOnAnim, totalDuration:totalDuration) as! CAAnimationGroup}
        layers["Volumio"]?.add(VolumioSwitchOnAnim, forKey:"VolumioSwitchOnAnim")
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
        if identifier == "SwitchOn"{
            QCMethod.updateValueFromPresentationLayer(forAnimation: (layers["roundedRect"] as! CALayer).animation(forKey: "roundedRectSwitchOnAnim"), theLayer:(layers["roundedRect"] as! CALayer))
            QCMethod.updateValueFromPresentationLayer(forAnimation: (layers["powerOff"] as! CALayer).animation(forKey: "powerOffSwitchOnAnim"), theLayer:(layers["powerOff"] as! CALayer))
            QCMethod.updateValueFromPresentationLayer(forAnimation: (layers["Volumio"] as! CALayer).animation(forKey: "VolumioSwitchOnAnim"), theLayer:(layers["Volumio"] as! CALayer))
        }
    }
    
    func removeAnimations(forAnimationId identifier: String){
        if identifier == "SwitchOn"{
            (layers["roundedRect"] as! CALayer).removeAnimation(forKey: "roundedRectSwitchOnAnim")
            (layers["powerOff"] as! CALayer).removeAnimation(forKey: "powerOffSwitchOnAnim")
            (layers["Volumio"] as! CALayer).removeAnimation(forKey: "VolumioSwitchOnAnim")
        }
    }
    
    func removeAllAnimations(){
        for layer in layers.values{
            (layer as! CALayer).removeAllAnimations()
        }
    }
    
    //MARK: - Bezier Path
    
    func roundedRectPath() -> UIBezierPath{
        let roundedRectPath = UIBezierPath(roundedRect:CGRect(x: 0, y: 0, width: 88, height: 40), cornerRadius:20)
        return roundedRectPath
    }
    
    
}
