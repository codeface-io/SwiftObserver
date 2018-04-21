import UIKit

public func printRect(_ rect:CGRect)
{
    NSLog("x %.0f   y %.0f   w %.0f   h %.0f",
          rect.origin.x,
          rect.origin.y,
          rect.size.width,
          rect.size.height)
}
