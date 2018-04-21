public extension Array
{
    mutating func remove(where shouldRemove: (Element) -> Bool)
    {
        self = self.filter { !shouldRemove($0) }
    }
    
    mutating func limit(toCount limit: Int)
    {
        guard limit > -1 else
        {
            return
        }
        
        let currentCount = count
        
        let toRemove = currentCount - limit
        
        if toRemove > 0
        {
            removeFirst(toRemove)
        }
    }
    
    mutating func moveElement(from: Int, to: Int) -> Bool
    {
        guard from >= 0, from < count, to >= 0, to < count else
        {
            return false
        }

        insert(remove(at: from), at: to)
        
        return true
    }
}
