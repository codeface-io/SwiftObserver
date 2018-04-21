import AppKit

public extension NSView
{
    func bringToFront(_ subview: NSView)
    {
        guard subviews.contains(subview) else
        {
            return
        }
        
        subview.removeFromSuperview()
        
        addSubview(subview, positioned: .above, relativeTo: nil)
    }
}

public extension NSImageView
{
    convenience init(withAspectFillImage image: NSImage)
    {
        self.init(frame: NSRect.zero)
        
        layer = CALayer()
        layer?.contentsGravity = kCAGravityResizeAspectFill
        layer?.contents = image
        wantsLayer = true
        
        imageAlignment = .alignCenter
        
        let priority = NSLayoutConstraint.Priority(rawValue: 0.1)
        setContentCompressionResistancePriority(priority, for: .horizontal)
        setContentCompressionResistancePriority(priority, for: .vertical)
    }
}
