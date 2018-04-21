public extension String
{
    init?(withNonEmpty string: String?)
    {
        guard let string = string, string != "" else
        {
            return nil
        }
        
        self = string
    }
}
