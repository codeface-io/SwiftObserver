public extension ObservationTransformer
{
    func notFrom(_ excludedAuthor: AnyAuthor,
                 receiveExcluded: @escaping (Transformed, AnyAuthor) -> Void)
    {
        filterAuthor({ [weak excludedAuthor] in $0 !== excludedAuthor },
                     receiveFiltered: receiveExcluded)
    }
    
    func notFrom(_ excludedAuthor: AnyAuthor,
                 receiveExcluded: @escaping (Transformed) -> Void)
    {
        filterAuthor({ [weak excludedAuthor] in $0 !== excludedAuthor },
                     receiveFiltered: receiveExcluded)
    }
    
    func notFrom(_ excludedAuthor: AnyAuthor) -> ObservationTransformer<Transformed>
    {
        filterAuthor { [weak excludedAuthor] in $0 !== excludedAuthor }
    }
}
