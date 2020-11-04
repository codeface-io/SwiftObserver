import XCTest
@testable import SwiftObserver

class PromiseTests: XCTestCase
{
    func testFulfillingPromiseAsynchronously()
    {
        let promise = Promise<Void>()
        
        let promiseFulfilled = expectation(description: "promise is fulfilled")
        
        let observer = AdhocObserver()
        
        observer.observe(promise)
        {
            promiseFulfilled.fulfill()
        }
        
        DispatchQueue.main.async { promise.fulfill(()) }
        
        waitForExpectations(timeout: 3)
    }
    
    func testCommonAnonymousAdhocObservationOfAsyncFunc()
    {
        let promiseFulfilled = expectation(description: "promise is fulfilled")
        
        SwiftObserver.observe(asyncFunc())
        {
            promiseFulfilled.fulfill()
        }

        waitForExpectations(timeout: 3)
    }
    
    func testPromiseProvidesValueAsynchronously()
    {
        let promise = Promise<Int>()
        
        let valueReceived = expectation(description: "did reveive value from promise")
        
        let observer = AdhocObserver()
        
        observer.observe(promise)
        {
            XCTAssertEqual($0, 42)
            valueReceived.fulfill()
        }
        
        DispatchQueue.main.async { promise.fulfill(42) }
        
        waitForExpectations(timeout: 3)
    }
    
    func testPromiseDiesAfterBeingFulfilledAsynchronously()
    {
        weak var weakPromise = asyncFunc()
        
        XCTAssertNotNil(weakPromise)

        let promiseFulfilled = expectation(description: "promise is fulfilled")

        let observer = AdhocObserver()

        observer.observe(weakPromise!)
        {
            promiseFulfilled.fulfill()
        }

        waitForExpectations(timeout: 3)
        
        XCTAssertNil(weakPromise)
    }
    
    func testPromiseStopsBeingObservedAfterBeingFulfilled()
    {
        let promise = Promise<Void>()
        
        var numberOfReceivedValues = 0
        
        let observer = AdhocObserver()
        
        observer.observe(promise)
        {
            numberOfReceivedValues += 1
        }
        
        XCTAssertEqual(numberOfReceivedValues, 0)
        XCTAssertTrue(observer.isObserving(promise))
        
        promise.fulfill(())
        
        XCTAssertEqual(numberOfReceivedValues, 1)
        XCTAssertFalse(observer.isObserving(promise))
        
        promise.fulfill(())
        
        XCTAssertEqual(numberOfReceivedValues, 1)
    }
    
    func testGettingValueMultipleTimesAsynchronouslyFromBufferedPromise()
    {
        let bufferedPromise = asyncFunc(returnValue: 42).buffer()
        
        let receivedValue = expectation(description: "received value")
        let receivedValue2 = expectation(description: "received value too")
        
        bufferedPromise.whenFulfilled { value in
            XCTAssertEqual(value, 42)
            XCTAssertEqual(value, bufferedPromise.latestMessage)
            receivedValue.fulfill()
        }
        
        bufferedPromise.whenFulfilled { value in
            XCTAssertEqual(value, 42)
            XCTAssertEqual(value, bufferedPromise.latestMessage)
            receivedValue2.fulfill()
        }
        
        XCTAssertNil(bufferedPromise.latestMessage)
        waitForExpectations(timeout: 3)
        XCTAssertEqual(bufferedPromise.latestMessage, 42)
    }
    
    func testGettingValueMultipleTimesSynchronouslyFromFulfilledBufferedPromise()
    {
        let bufferedPromise = Promise<Int>().buffer()
        bufferedPromise.fulfill(42)
        
        XCTAssertEqual(bufferedPromise.latestMessage, 42)
        
        var receivedValue: Int?
        var receivedValue2: Int?
        
        bufferedPromise.whenFulfilled { value in
            receivedValue = value
        }
        
        bufferedPromise.whenFulfilled { value in
            receivedValue2 = value
        }
        
        XCTAssertEqual(receivedValue, 42)
        XCTAssertEqual(receivedValue2, 42)
    }
    
    func testChainingFirstlyThenObserveAndObservationMapper()
    {
        let receivedValue = expectation(description: "received value")
        
        firstly
        {
            asyncFunc(returnValue: 42)
        }
        .then
        {
            self.asyncFunc(returnValue: "\($0)")
        }
        .observe()
        .map
        {
            $0.count
        }
        .receive
        {
            XCTAssertEqual($0, 2)
            receivedValue.fulfill()
        }
        
        waitForExpectations(timeout: 3)
    }
    
    func asyncFunc() -> Promise<Void>
    {
        Promise { promise in DispatchQueue.main.async { promise.fulfill(()) } }
    }
    
    func asyncFunc(returnValue: Int) -> Promise<Int>
    {
        Promise { promise in DispatchQueue.main.async { promise.fulfill(returnValue) } }
    }
    
    func asyncFunc(returnValue: String) -> Promise<String>
    {
        Promise { promise in DispatchQueue.main.async { promise.fulfill(returnValue) } }
    }
}
