public extension Promise
{
    func onSuccess<Success, Failure: Error, NextSuccess>(
        _ nextPromise: @escaping (Success) throws -> ResultPromise<NextSuccess>
    )
        -> ResultPromise<NextSuccess>
        where Value == Result<Success, Failure>
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
    
    func mapSuccess<Success, Failure: Error, NextSuccess>(
        _ handleSuccess: @escaping (Success) throws -> NextSuccess
    )
        -> ResultPromise<NextSuccess>
        where Value == Result<Success, Failure>
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
    func whenSucceeded<Success, Failure: Error>(
        _ handleSuccess: @escaping (Success) throws -> Void,
        failed handleFailure: @escaping (Error) -> Void
    )
        -> Self
        where Value == Result<Success, Failure>
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
    func whenFailed<Success, Failure: Error>(
        _ handleFailure: @escaping (Failure) -> Void
    )
        -> Self
        where Value == Result<Success, Failure>
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
    
    func fulfill<Success, Failure: Error>(_ error: Failure)
        where Value == Result<Success, Failure>
    {
        fulfill(.failure(error))
    }
    
    func fulfill<Success, Failure: Error>(_ resultValue: Success)
        where Value == Result<Success, Failure>
    {
        fulfill(.success(resultValue))
    }
    
    static func fulfilled<Success, Failure: Error>(_ error: Failure) -> Promise
        where Value == Result<Success, Failure>
    {
        fulfilled(.failure(error))
    }
    
    static func fulfilled<Success, Failure: Error>(_ resultValue: Success) -> Promise
        where Value == Result<Success, Failure>
    {
        fulfilled(.success(resultValue))
    }
}

public typealias ResultPromise<Value> = Promise<Result<Value, Error>>
