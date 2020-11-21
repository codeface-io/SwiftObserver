public extension SOPromise
{
    func onSuccess<Success, Failure, NextSuccess>(
        _ nextPromise: @escaping (Success) -> SOPromise<Result<NextSuccess, Failure>>
    )
        -> SOPromise<Result<NextSuccess, Failure>>
        where Value == Result<Success, Failure>
    {
        then
        {
            switch $0
            {
            case .success(let successValue):
                return nextPromise(successValue)
            case .failure(let error):
                return .fulfilled(.failure(error))
            }
        }
    }
    
    func mapSuccess<Success, Failure, NextSuccess>(
        _ handleSuccess: @escaping (Success) -> Result<NextSuccess, Failure>
    )
        -> SOPromise<Result<NextSuccess, Failure>>
        where Value == Result<Success, Failure>
    {
        map { $0.flatMap(handleSuccess) }
    }
    
    @discardableResult
    func observedSuccess<Success, Failure>(
        _ handleSuccess: @escaping (Success) -> Void,
        failure handleFailure: @escaping (Failure) -> Void
    )
        -> FreeObserver
        where Value == Result<Success, Failure>
    {
        observedOnce
        {
            switch $0
            {
            case .success(let successValue):
                handleSuccess(successValue)
            case .failure(let error):
                handleFailure(error)
            }
        }
    }
    
    func fulfill<Success, Failure>(_ error: Failure)
        where Value == Result<Success, Failure>
    {
        fulfill(.failure(error))
    }
    
    func fulfill<Success, Failure>(_ resultValue: Success)
        where Value == Result<Success, Failure>
    {
        fulfill(.success(resultValue))
    }
    
    static func fulfilled<Success, Failure>(_ error: Failure) -> SOPromise
        where Value == Result<Success, Failure>
    {
        fulfilled(.failure(error))
    }
    
    static func fulfilled<Success, Failure>(_ resultValue: Success) -> SOPromise
        where Value == Result<Success, Failure>
    {
        fulfilled(.success(resultValue))
    }
}
