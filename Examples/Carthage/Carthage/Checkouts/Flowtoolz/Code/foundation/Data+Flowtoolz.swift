import Foundation

public extension Data
{
    init?(from filePath: String)
    {
        self.init(from: URL(fileURLWithPath: filePath))
    }
    
    init?(from fileUrl: URL?)
    {
        guard let url = fileUrl else { return nil }
        
        do
        {
            self = try Data(contentsOf: url)
        }
        catch
        {
            return nil
        }
    }
    
    @discardableResult func save(to filePath: String) -> URL?
    {
        return save(to: URL(fileURLWithPath: filePath))
    }
    
    @discardableResult func save(to fileUrl: URL) -> URL?
    {
        do
        {
            try write(to: fileUrl)
            return fileUrl
        }
        catch
        {
            print(error)
            return nil
        }
    }
    
    var utf8String: String?
    {
        return String(data: self, encoding: .utf8)
    }
}
