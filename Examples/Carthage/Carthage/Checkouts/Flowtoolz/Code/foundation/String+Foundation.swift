import Foundation

extension String
{
    init?(with filePath: String)
    {
        do
        {
            self = try String(contentsOfFile: filePath)
        }
        catch
        {
            return nil
        }
    }
    
    var fileName: String
    {
        return URL(fileURLWithPath: self).lastPathComponent
    }
    
    func dateString(fromFormat: String, toFormat: String) -> String
    {
        guard let date = Date(fromString: self, withFormat: fromFormat) else
        {
            return self
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = toFormat
        return formatter.string(from: date)
    }
}
