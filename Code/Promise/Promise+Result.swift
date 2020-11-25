public extension Promise
{
    func onSuccess<Success, NextSuccess>(
        _ nextPromise: @escaping (Success) throws -> ResultPromise<NextSuccess>
    )
        -> ResultPromise<NextSuccess>
        where Value == Result<Success, Error>
    {
        then
        {
            switch $0
            {
            case .success(let successValue):
                do { return try nextPromise(successValue) }
                catch { return .fulfilled(error) }
            case .failure(let error):
                return .fulfilled(error)
            }
        }
    }
    
    func mapSuccess<Success, NextSuccess>(
        _ handleSuccess: @escaping (Success) throws -> NextSuccess
    )
        -> ResultPromise<NextSuccess>
        where Value == Result<Success, Error>
    {
        map
        {
            switch $0
            {
            case .success(let successValue):
                do { return .success(try handleSuccess(successValue)) }
                catch { return .failure(error) }
            case .failure(let error):
                return .failure(error)
            }
        }
    }
    
    @discardableResult
    func whenSucceeded<Success>(
        _ handleSuccess: @escaping (Success) throws -> Void,
        failed handleFailure: @escaping (Error) -> Void
    )
        -> Self
        where Value == Result<Success, Error>
    {
        whenFulfilled
        {
            switch $0
            {
            case .success(let successValue):
                do { try handleSuccess(successValue) }
                catch { handleFailure(error) }
            case .failure(let error):
                handleFailure(error)
            }
        }
        
        return self
    }
    
    @discardableResult
    func whenFailed<Success>(
        _ handleFailure: @escaping (Error) -> Void
    )
        -> Self
        where Value == Result<Success, Error>
    {
        whenFulfilled
        {
            if case .failure(let error) = $0
            {
                handleFailure(error)
            }
        }
        
        return self
    }
    
    func fulfill<Success>(_ error: Error)
        where Value == Result<Success, Error>
    {
        fulfill(.failure(error))
    }
    
    func fulfill<Success>(_ resultValue: Success)
        where Value == Result<Success, Error>
    {
        fulfill(.success(resultValue))
    }
    
    static func fulfilled<Success>(_ error: Error) -> Promise
        where Value == Result<Success, Error>
    {
        fulfilled(.failure(error))
    }
    
    static func fulfilled<Success>(_ resultValue: Success) -> Promise
        where Value == Result<Success, Error>
    {
        fulfilled(.success(resultValue))
    }
}

public typealias ResultPromise<Value> = Promise<Result<Value, Error>>
