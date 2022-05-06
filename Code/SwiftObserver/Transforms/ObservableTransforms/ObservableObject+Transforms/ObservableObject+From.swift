public extension ObservableObject
{
    func from(_ selectedAuthor: AnyAuthor) -> AuthorFilter<Self>
    {
        filterAuthor { [weak selectedAuthor] in $0 === selectedAuthor }
    }
}
