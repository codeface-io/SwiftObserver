public extension ObservationTransformer
{
    func from(_ selectedAuthor: AnyAuthor,
              receiveSelected: @escaping (Transformed, AnyAuthor) -> Void)
    {
        filterAuthor({ $0 === selectedAuthor }, receiveFiltered: receiveSelected)
    }
    
    func from(_ selectedAuthor: AnyAuthor,
              receiveSelected: @escaping (Transformed) -> Void)
    {
        filterAuthor({ $0 === selectedAuthor }, receiveFiltered: receiveSelected)
    }
    
    func from(_ selectedAuthor: AnyAuthor) -> ObservationTransformer<Transformed>
    {
        filterAuthor { $0 === selectedAuthor }
    }
}
