import UIKit

public extension UIColor
{
    func brighter(_ factor: Float) -> UIColor
    {
        var hue : CGFloat = 0
        var saturation : CGFloat = 0
        var brightness : CGFloat = 0
        var alpha : CGFloat = 0
        
        if self.getHue(&hue,
            saturation: &saturation,
            brightness: &brightness,
            alpha: &alpha)
        {
            return UIColor(hue: hue,
                saturation: saturation,
                brightness: brightness * CGFloat(factor),
                alpha: alpha)
        }
        else
        {
            return self;
        }
    }
    
    func withOpacity(_ opacity: Float) -> UIColor
    {
        var hue : CGFloat = 0
        var saturation : CGFloat = 0
        var brightness : CGFloat = 0
        var alpha : CGFloat = 0
        
        if self.getHue(&hue,
            saturation: &saturation,
            brightness: &brightness,
            alpha: &alpha)
        {
            return UIColor(hue: hue,
                saturation: saturation,
                brightness: brightness,
                alpha: CGFloat(opacity))
        }
        else
        {
            return self;
        }
    }
}

public func UIColorFromRGB(_ rgbValue: UInt) -> UIColor
{
    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
}
