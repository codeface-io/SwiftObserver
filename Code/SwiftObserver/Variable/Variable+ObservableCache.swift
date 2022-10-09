extension Variable: ObservableCache
{
    /**
     An ``Update`` in which ``Update/old`` and ``Update/new`` both hold the ``Variable``'s current ``Variable/value``
     */
    public var latestMessage: Update<Value>
    {
        Update(value, value)
    }
}
