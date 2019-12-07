public extension Observable
{
    func notFrom(_ excludedAuthor: AnyAuthor) -> AuthorFilter<Self>
    {
        filterAuthor { $0 !== excludedAuthor }
    }
}
