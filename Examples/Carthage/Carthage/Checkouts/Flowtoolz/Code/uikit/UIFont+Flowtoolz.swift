import UIKit

public extension UIFont
{
    static func printNames()
    {
        for fontFamily in familyNames
        {
            let fontNames = self.fontNames(forFamilyName: fontFamily)

            print("\(fontFamily): \(fontNames)")
        }
    }
    
    static func printAvailableFonts()
    {
        for family in UIFont.familyNames
        {
            print(family + ":")
            
            for name in UIFont.fontNames(forFamilyName: family)
            {
                print("- " + name)
            }
        }
    }
}
