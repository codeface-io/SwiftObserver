func combineFilters<T>(_ f1: ((T) -> Bool)?,
                       _ f2: ((T) -> Bool)?) -> ((T) -> Bool)?
{
    guard let f1 = f1 else { return f2 }
    guard let f2 = f2 else { return f1 }
    
    return and(f1, f2)
}

func and<T>(_ f1: @escaping (T) -> Bool,
            _ f2: @escaping (T) -> Bool) -> (T) -> Bool
{
    return { f1($0) && f2($0) }
}

func compose<A, B, C>(_ f1: @escaping ((A) -> B),
                      _ f2: @escaping ((B) -> C)) -> ((A) -> C)
{
    return { f2(f1($0)) }
}
