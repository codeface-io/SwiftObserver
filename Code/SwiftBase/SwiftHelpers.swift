public func typeName(of anything: Any?) -> String
{
    return String(describing: anything.self)
}

public typealias JSON = [String : Any]

public typealias Action = () -> Void

public func hash(_ object: AnyObject) -> HashValue
{
    return ObjectIdentifier(object).hashValue
}

public typealias HashValue = Int
