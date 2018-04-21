public extension Dictionary
{
    mutating func remove(where shouldRemove: (Value) -> Bool )
    {
        self = self.filter { !shouldRemove($0.value) }
    }
    
    // MARK: - Merge Dictionaries
    
    static func + <KeyType, ValueType> (left: [KeyType : ValueType],
                                        right: [KeyType : ValueType]) -> [KeyType : ValueType]
    {
        var result = [KeyType : ValueType]()
        
        for (key, value) in left
        {
            result[key] = value
        }
        
        for (key, value) in right
        {
            result[key] = value
        }
        
        return result
    }
    
    static func += <KeyType, ValueType> (left: inout [KeyType : ValueType],
                                         right: [KeyType : ValueType])
    {
        for (key, value) in right
        {
            left[key] = value
        }
    }
}
