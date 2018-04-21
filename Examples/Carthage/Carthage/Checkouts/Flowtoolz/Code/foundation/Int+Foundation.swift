public extension Int
{
    var stringWithThousandsSeparator: String
    {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = "'"
        formatter.numberStyle = .decimal
        
        return formatter.string(from: NSNumber(value: self)) ?? String(self)
    }
    
    // MARK: - Get month name from month number
    
    var monthString: String
    {
        return monthString(withDateFormat: "MMMM")
    }
    
    var monthStringShort: String
    {
        return monthString(withDateFormat: "MMM")
    }
    
    func monthString(withDateFormat format: String) -> String
    {
        let formatter = DateFormatter()
        
        formatter.dateFormat = "MM"
        
        let monthNumber = self % 12 == 0 ? 12 : self % 12
        
        if let date = formatter.date(from: "\(monthNumber)")
        {
            formatter.dateFormat = format
            return formatter.string(from: date)
        }
        
        return String(self)
    }
}

