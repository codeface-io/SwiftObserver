public extension ObservableObject
{
    func notFrom(_ excludedAuthor: AnyAuthor) -> AuthorFilter<Self>
    {
        filterAuthor { [weak excludedAuthor] in $0 !== excludedAuthor }
    }
}
