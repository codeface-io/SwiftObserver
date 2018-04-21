import UIKit

public let screenSize = UIScreen.main.bounds.size

public extension UIEdgeInsets
{
    init(inset: CGFloat)
    {
        left = inset
        top = inset
        right = inset
        bottom = inset
    }
}

public extension UIView
{
    func columnWidth(forNumberOfColumns columns: Int,
                     columnSpacing spacing: CGFloat) -> CGFloat
    {
        let width = frame.size.width
        
        return (width - (CGFloat(columns - 1) * spacing)) / CGFloat(columns)
    }
    
    func removeConstraints()
    {
        self.removeConstraints(self.constraints)
    }
    
    func endEditingInContainedTextFields()
    {
        endEditingInContainedTextFields(inView: self)
    }
    
    private func endEditingInContainedTextFields(inView view: UIView)
    {
        if let textField = view as? UITextField
        {
            textField.endEditing(true)
        }
        
        for subview in view.subviews
        {
            endEditingInContainedTextFields(inView: subview)
        }
    }
    
    // MARK: Rotation Animation
    
    func startRotating(withAnimationDelegate delegate: CAAnimationDelegate? = nil)
    {
        guard layer.animation(forKey: kRotationAnimationKey) == nil else
        {
            return
        }
        
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
        
        rotationAnimation.fromValue = Float.pi * 2
        rotationAnimation.toValue = 0.0
        rotationAnimation.repeatCount = 1
        rotationAnimation.duration = 1
        rotationAnimation.delegate = delegate
        
        layer.add(rotationAnimation, forKey: kRotationAnimationKey)
    }
    
    func stopRotating()
    {
        if layer.animation(forKey: kRotationAnimationKey) != nil
        {
            layer.removeAnimation(forKey: kRotationAnimationKey)
        }
    }
    
    private var kRotationAnimationKey: String
    {
        return "com.myapplication.rotationanimationkey"
    }
    
    // MARK: Animate as Button Press for Focus
    
    func moveDownAnimated()
    {
        if isFullscreen()
        {
            UIView.animate(withDuration: 0.24, animations:
            {
                self.setScaleLowered()
            })
            setShadowNormalAnimated(0.24)
        }
        else
        {
            UIView.animate(withDuration: 0.12, animations:
            {
                self.setScaleNormal()
            })
            setShadowNormalAnimated(0.12)
        }
    }
    
    func moveUpAnimated()
    {
        if isFullscreen()
        {
            UIView.animate(withDuration: 1.0, animations:
            {
                self.setScaleNormal()
            })
            setShadowElevatedAnimated(1.0)
        }
        else
        {
            UIView.animate(withDuration: 0.5, animations:
            {
                self.setScaleElevated()
            })
            setShadowElevatedAnimated(0.5)
        }
    }
    
    func isFullscreen() -> Bool
    {
        return bounds.size == UIScreen.main.bounds.size
    }
    
    // MARK: Set Scale Transformation for Focus
    
    func setScaleLowered()
    {
        transform = getZoomTransformation(-80)
    }
    
    func setScaleNormal()
    {
        transform = CGAffineTransform.identity
    }
    
    func setScaleElevated()
    {
        transform = getZoomTransformation()
    }

    func getZoomTransformation(_ sizeIncrease: Float = 40) -> CGAffineTransform
    {
        let width = frame.size.width
        let height = frame.size.height
        let scaleX = (width + CGFloat(sizeIncrease)) / width
        let scaleY = (height + CGFloat(sizeIncrease)) / height
        let finalScale = scaleX > scaleY ? scaleY : scaleX
        return CGAffineTransform(scaleX: finalScale, y: finalScale)
    }
    
    // MARK: Animate Shadow for Focus
    
    func setShadowElevatedAnimated(_ duration: TimeInterval)
    {
        animateShadowFrom(shadowCurrent(),
            to: UIView.shadowElevated,
            duration: duration)
    }
    
    func setShadowNormalAnimated(_ duration: TimeInterval)
    {
        animateShadowFrom(shadowCurrent(),
            to: UIView.shadowNormal,
            duration: duration)
    }
    
    func animateShadowFrom(_ fromShadow: ShadowSettings,
        to toShadow: ShadowSettings,
        duration: TimeInterval)
    {
        let opacityAnim = CABasicAnimation(keyPath: "shadowOpacity")
        opacityAnim.fromValue = fromShadow.opacity
        opacityAnim.toValue = toShadow.opacity
        
        let radiusAnim = CABasicAnimation(keyPath: "shadowRadius")
        radiusAnim.fromValue = fromShadow.radius
        radiusAnim.toValue = toShadow.radius
        
        let offsetAnim = CABasicAnimation(keyPath: "shadowOffset")
        offsetAnim.fromValue = NSValue(cgSize: fromShadow.offset)
        offsetAnim.toValue = NSValue(cgSize: toShadow.offset)
        
        let animationGroup = CAAnimationGroup()
        animationGroup.duration = duration
        animationGroup.animations = [opacityAnim, radiusAnim, offsetAnim]
        
        setShadow(toShadow)
        
        let animKey = "shadowAnimation"
        layer.removeAnimation(forKey: animKey)
        layer.add(animationGroup, forKey: animKey)
    }
    
    func setShadow(_ settings: ShadowSettings)
    {
        layer.shadowOpacity = settings.opacity
        layer.shadowRadius = settings.radius
        layer.shadowOffset = settings.offset
    }
    
    static var shadowNormal: ShadowSettings =
    {
        var settings = ShadowSettings()
        
        settings.opacity = 1
        
        return settings
    }()
    
    static var shadowElevated: ShadowSettings =
    {
        var settings = ShadowSettings()
        
        settings.opacity = 0.7
        settings.radius = 20
        settings.offset = CGSize(width: 0, height: 20)
        
        return settings
    }()
    
    func shadowCurrent() -> ShadowSettings
    {
        var settings = ShadowSettings()
        
        settings.opacity = layer.shadowOpacity
        settings.radius = layer.shadowRadius
        settings.offset = layer.shadowOffset
        
        return settings
    }
    
    struct ShadowSettings
    {
        var opacity: Float = 0
        var radius: CGFloat = 0
        var offset: CGSize = CGSize(width: 0, height: 0)
    }
    
    // MARK: - Subviews
    
    func removeAllSubviews()
    {
        for subview in subviews
        {
            subview.removeFromSuperview()
        }
    }
}
