public extension Observable
{
    func from(_ selectedAuthor: AnyAuthor) -> AuthorFilter<Self>
    {
        filterAuthor { $0 === selectedAuthor }
    }
}
