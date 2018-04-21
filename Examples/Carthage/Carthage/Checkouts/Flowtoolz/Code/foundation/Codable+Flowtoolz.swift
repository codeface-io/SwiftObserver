import Foundation

public extension Decodable
{
    init?(from filePath: String)
    {
        let fileUrl = URL(fileURLWithPath: filePath)
        
        self.init(from: fileUrl)
    }
    
    init?(from fileUrl: URL?)
    {
        if let decodedSelf = Self(with: Data(from: fileUrl))
        {
            self = decodedSelf
        }
        else
        {
            return nil
        }
    }
    
    init?(with json: Data?)
    {
        guard let json = json else { return nil }
        
        do
        {
            self = try JSONDecoder().decode(Self.self, from: json)
        }
        catch
        {
            return nil
        }
    }
}

public extension Encodable
{
    @discardableResult func save(to filePath: String) -> URL?
    {
        return self.encode()?.save(to: filePath)
    }
    
    @discardableResult func save(to fileUrl: URL) -> URL?
    {
        return self.encode()?.save(to: fileUrl)
    }
    
    func encode() -> Data?
    {
        let jsonEncoder = JSONEncoder()
        
        jsonEncoder.outputFormatting = .prettyPrinted
        
        return try? jsonEncoder.encode(self)
    }
}
