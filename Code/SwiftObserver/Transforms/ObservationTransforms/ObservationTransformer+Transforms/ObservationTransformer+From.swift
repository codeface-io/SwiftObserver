public extension ObservationTransformer
{
    func from(_ selectedAuthor: AnyAuthor?,
              receiveSelected: @escaping (Transformed, AnyAuthor) -> Void)
    {
        filterAuthor({ [weak selectedAuthor] in $0 === selectedAuthor},
                     receiveFiltered: receiveSelected)
    }
    
    func from(_ selectedAuthor: AnyAuthor?,
              receiveSelected: @escaping (Transformed) -> Void)
    {
        filterAuthor({ [weak selectedAuthor] in $0 === selectedAuthor },
                     receiveFiltered: receiveSelected)
    }
    
    func from(_ selectedAuthor: AnyAuthor?) -> ObservationTransformer<Transformed>
    {
        filterAuthor { [weak selectedAuthor] in $0 === selectedAuthor }
    }
}
