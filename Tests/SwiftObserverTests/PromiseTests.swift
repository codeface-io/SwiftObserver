import XCTest
@testable import SwiftObserver

class PromiseTests: XCTestCase
{
    func testFulfillingPromiseAsynchronously()
    {
        let promise = Promise<Void>()
        
        let promiseFulfilled = expectation(description: "promise is fulfilled")
        
        let observer = FreeObserver()
        
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
        
        let observer = FreeObserver()
        
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

        let observer = FreeObserver()

        observer.observe(weakPromise!)
        {
            promiseFulfilled.fulfill()
        }

        waitForExpectations(timeout: 3)
        
        XCTAssertNil(weakPromise)
    }
    
    func testGettingValueMultipleTimesAsynchronouslyFromBufferedPromise()
    {
        let promiseBuffer = asyncFunc(returnValue: 42).buffer()
        
        let receivedValue = expectation(description: "received value")
        let receivedValue2 = expectation(description: "received value too")
        
        promiseBuffer.whenFilled { value in
            XCTAssertEqual(value, 42)
            XCTAssertEqual(value, promiseBuffer.latestMessage)
            receivedValue.fulfill()
        }
        
        promiseBuffer.whenFilled { value in
            XCTAssertEqual(value, 42)
            XCTAssertEqual(value, promiseBuffer.latestMessage)
            receivedValue2.fulfill()
        }
        
        XCTAssertNil(promiseBuffer.latestMessage)
        waitForExpectations(timeout: 3)
        XCTAssertEqual(promiseBuffer.latestMessage, 42)
    }
    
    func testGettingValueMultipleTimesSynchronouslyFromFulfilledBufferedPromise()
    {
        let promiseBuffer = Promise<Int>().buffer()
        promiseBuffer.fill(42)
        
        XCTAssertEqual(promiseBuffer.latestMessage, 42)
        
        var receivedValue: Int?
        var receivedValue2: Int?
        
        promiseBuffer.whenFilled { value in
            receivedValue = value
        }
        
        promiseBuffer.whenFilled { value in
            receivedValue2 = value
        }
        
        XCTAssertEqual(receivedValue, 42)
        XCTAssertEqual(receivedValue2, 42)
    }
    
    func testChainingFirstlyThenObserveAndObservationMapper()
    {
        let receivedValue = expectation(description: "received value")
        
        first
        {
            asyncFunc(returnValue: 42)
        }
        .then
        {
            self.asyncFunc(returnValue: "\($0)")
        }
        .observed()
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
