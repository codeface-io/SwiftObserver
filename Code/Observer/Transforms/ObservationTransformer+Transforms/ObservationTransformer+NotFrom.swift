public extension ObservationTransformer
{
    func notFrom(_ excludedAuthor: AnyAuthor,
                 receiveExcluded: @escaping (Transformed, AnyAuthor) -> Void)
    {
        filterAuthor({ $0 !== excludedAuthor }, receiveFiltered: receiveExcluded)
    }
    
    func notFrom(_ excludedAuthor: AnyAuthor,
                 receiveExcluded: @escaping (Transformed) -> Void)
    {
        filterAuthor({ $0 !== excludedAuthor }, receiveFiltered: receiveExcluded)
    }
    
    func notFrom(_ excludedAuthor: AnyAuthor) -> ObservationTransformer<Transformed>
    {
        filterAuthor { $0 !== excludedAuthor }
    }
}
