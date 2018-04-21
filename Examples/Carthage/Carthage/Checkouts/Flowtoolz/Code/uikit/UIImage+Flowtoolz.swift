import UIKit

public extension UIImage
{
    convenience init?(withBase64String string: String, scale: CGFloat = 1)
    {
        guard let url = URL(string: string) else
        {
            print("Error: Could not create URL with base64 string.")
            return nil
        }
        
        do
        {
            let imageData = try Data(contentsOf: url, options: .mappedIfSafe)
            
            self.init(data: imageData, scale: scale)
        }
        catch
        {
            print("Error: Could not create Data with URL.")
            return nil
        }
    }
}
