public extension Observable
{
    func filterAuthor(_ keep: @escaping (AnyAuthor) -> Bool) -> AuthorFilter<Self>
    {
        AuthorFilter(self, keep)
    }
}
