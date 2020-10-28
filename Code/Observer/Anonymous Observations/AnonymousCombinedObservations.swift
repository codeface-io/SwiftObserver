public func observe<O1: BufferedObservable, O2: BufferedObservable>(
    _ observable1: O1,
    _ observable2: O2,
    _ receive: @escaping (O1.Message, O2.Message) -> Void)
{
    AnonymousObserver.shared.observe(observable1, observable2, receive)
}

public func observe<O1: BufferedObservable, O2: BufferedObservable>(
    _ observable1: O1,
    _ observable2: O2,
    _ receive: @escaping (O1.Message, O2.Message, AnyAuthor) -> Void)
{
    AnonymousObserver.shared.observe(observable1, observable2, receive)
}

public func observe<O1: BufferedObservable, O2: BufferedObservable, O3: BufferedObservable>(
    _ observable1: O1,
    _ observable2: O2,
    _ observable3: O3,
    _ receive: @escaping (O1.Message, O2.Message, O3.Message) -> Void)
{
    AnonymousObserver.shared.observe(observable1, observable2, observable3, receive)
}

public func observe<O1: BufferedObservable, O2: BufferedObservable, O3: BufferedObservable>(
    _ observable1: O1,
    _ observable2: O2,
    _ observable3: O3,
    _ receive: @escaping (O1.Message, O2.Message, O3.Message, AnyAuthor) -> Void)
{
    AnonymousObserver.shared.observe(observable1, observable2, observable3, receive)
}
