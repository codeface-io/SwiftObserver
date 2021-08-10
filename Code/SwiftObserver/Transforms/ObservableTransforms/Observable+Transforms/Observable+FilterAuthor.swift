public extension ObservableObject
{
    func filterAuthor(_ keep: @escaping (AnyAuthor) -> Bool) -> AuthorFilter<Self>
    {
        AuthorFilter(self, keep)
    }
}
