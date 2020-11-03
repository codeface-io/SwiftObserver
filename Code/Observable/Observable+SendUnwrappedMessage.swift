public extension Observable
{
    func fulfill<Unwrapped>(_ unwrapped: Unwrapped, as author: AnyAuthor)
        where Message == Unwrapped?
    {
        send(unwrapped, from: author)
    }
    
    func fulfill<Unwrapped>(_ unwrapped: Unwrapped)
        where Message == Unwrapped?
    {
        send(unwrapped)
    }
}
