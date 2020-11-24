import XCTest
import SwiftObserver

class PromiseTests: XCTestCase
{
    func testFulfillingPromiseAsynchronously()
    {
        let promise: Promise<Void> = Promise { _ in }
        
        let promiseFulfilled = expectation(description: "promise is fulfilled")
        
        promise.whenFulfilled
        {
            promiseFulfilled.fulfill()
        }
        
        DispatchQueue.main.async { promise.fulfill(()) }
        
        waitForExpectations(timeout: 3)
    }
    
    func testCommonAdhocObservationOfAsyncFunc()
    {
        let promiseFulfilled = expectation(description: "promise is fulfilled")
        
        asyncFunc().whenFulfilled
        {
            promiseFulfilled.fulfill()
        }

        waitForExpectations(timeout: 3)
    }
    
    func testPromiseProvidesValueAsynchronously()
    {
        let promise = asyncFunc(returnValue: 42)
        
        let valueReceived = expectation(description: "did reveive value from promise")
        
        promise.whenFulfilled
        {
            XCTAssertEqual($0, 42)
            valueReceived.fulfill()
        }
        
        waitForExpectations(timeout: 3)
    }
    
    func testPromiseDiesAfterBeingFulfilledAsynchronously()
    {
        weak var weakPromise = asyncFunc()
        
        XCTAssertNotNil(weakPromise)

        let promiseFulfilled = expectation(description: "promise is fulfilled")

        weakPromise!.whenFulfilled
        {
            promiseFulfilled.fulfill()
        }

        waitForExpectations(timeout: 3)
        
        XCTAssertNil(weakPromise)
    }
    
    func testGettingValueMultipleTimesAsynchronouslyFromPromiseCache()
    {
        let promise = asyncFunc(returnValue: 42)
        
        let receivedValue = expectation(description: "received value")
        let receivedValue2 = expectation(description: "received value too")
        
        promise.whenFulfilled { value in
            XCTAssertEqual(value, 42)
            receivedValue.fulfill()
        }
        
        promise.whenFulfilled { value in
            XCTAssertEqual(value, 42)
            receivedValue2.fulfill()
        }
        
        waitForExpectations(timeout: 3)
    }
    
    func testGettingValueMultipleTimesSynchronouslyFromCacheOfFulfilledPromise()
    {
        let promise: Promise<Int> = .fulfilled(42)
        
        var receivedValue: Int?
        var receivedValue2: Int?
        
        promise.whenFulfilled { value in
            receivedValue = value
        }
        
        promise.whenFulfilled { value in
            receivedValue2 = value
        }
        
        XCTAssertEqual(receivedValue, 42)
        XCTAssertEqual(receivedValue2, 42)
    }
    
    func testSequentialPromises()
    {
        let receivedValue = expectation(description: "received value")

        promise
        {
            asyncFunc(returnValue: 42)
        }
        .then
        {
            self.asyncFunc(returnValue: "\($0)")
        }
        .whenFulfilled
        {
            XCTAssertEqual($0, "42")
            receivedValue.fulfill()
        }

        waitForExpectations(timeout: 3)
    }
    
    func testConcurrentPromises()
    {
        let receivedValues = expectation(description: "received values")
        
        promise
        {
            asyncFunc(returnValue: 42)
        }
        .and
        {
            asyncFunc(returnValue: "42")
        }
        .whenFulfilled
        {
            XCTAssertEqual($0.0, 42)
            XCTAssertEqual($0.1, "42")
            receivedValues.fulfill()
        }
        
        waitForExpectations(timeout: 3)
    }
    
    func testMapPromiseWithoutHoldingMapping()
    {
        let receivedValue = expectation(description: "received value")
        
        promise
        {
            asyncFunc(returnValue: 42)
        }
        .map
        {
            "\($0)"
        }
        .whenFulfilled
        {
            XCTAssertEqual($0, "42")
            receivedValue.fulfill()
        }
        
        waitForExpectations(timeout: 3)
    }
    
    func testUnwrapWithDefaultOnPromiseWithoutHoldingTransform()
    {
        let receivedValue = expectation(description: "received value")
        
        Promise<Int?>
        {
            promise in DispatchQueue.main.async { promise.fulfill(nil) }
        }
        .unwrap(42)
        .whenFulfilled
        {
            XCTAssertEqual($0, 42)
            receivedValue.fulfill()
        }
        
        waitForExpectations(timeout: 3)
    }
    
    func testNewOnPromiseWithoutHoldingTransform()
    {
        let receivedValue = expectation(description: "received value")
        
        Promise<Update<Int>>
        {
            promise in DispatchQueue.main.async { promise.fulfill(Update(23, 42)) }
        }
        .new()
        .whenFulfilled
        {
            XCTAssertEqual($0, 42)
            receivedValue.fulfill()
        }
        
        waitForExpectations(timeout: 3)
    }
    
    func testFulfillSynchronously()
    {
        func asyncFuncReturningEarly() -> Promise<Int> { .fulfilled(42) }
        
        let receivedValue = expectation(description: "received value")
        
        asyncFuncReturningEarly().whenFulfilled
        {
            XCTAssertEqual($0, 42)
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
