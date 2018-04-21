import Foundation

extension Dictionary
{
    // MARK: - Dictionary representing URL query parameters
    
    func stringFromParameters() -> String
    {
        let parameterArray = self.map
        {
            (key, value) -> String in
            
            let key = String(describing: key).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            let value = String(describing: value).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            
            guard let definiteKey = key, let definiteValue = value else {
                print("Couldn't parse to string")
                return ""
            }
            
            return "\(definiteKey)=\(definiteValue)"
        }
        
        return parameterArray.joined(separator: "&")
    }
}
