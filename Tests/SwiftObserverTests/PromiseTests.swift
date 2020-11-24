import XCTest
import SwiftObserver

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
    
    func testCommonFreeAdhocObservationOfAsyncFunc()
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
    
    func testGettingValueMultipleTimesAsynchronouslyFromPromiseCache()
    {
        let promiseCache = asyncFunc(returnValue: 42).cache()
        
        let receivedValue = expectation(description: "received value")
        let receivedValue2 = expectation(description: "received value too")
        
        promiseCache.whenCached { value in
            XCTAssertEqual(value, 42)
            XCTAssertEqual(value, promiseCache.latestMessage)
            receivedValue.fulfill()
        }
        
        promiseCache.whenCached { value in
            XCTAssertEqual(value, 42)
            XCTAssertEqual(value, promiseCache.latestMessage)
            receivedValue2.fulfill()
        }
        
        XCTAssertNil(promiseCache.latestMessage)
        waitForExpectations(timeout: 3)
        XCTAssertEqual(promiseCache.latestMessage, 42)
    }
    
    func testGettingValueMultipleTimesSynchronouslyFromCacheOfFulfilledPromise()
    {
        let promiseCache = Promise<Int>().cache()
        promiseCache.send(42)
        
        XCTAssertEqual(promiseCache.latestMessage, 42)
        
        var receivedValue: Int?
        var receivedValue2: Int?
        
        promiseCache.whenCached { value in
            receivedValue = value
        }
        
        promiseCache.whenCached { value in
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
        .observed
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
        .observed
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
        .observed
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
        .observed
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
        .observed
        {
            XCTAssertEqual($0, 42)
            receivedValue.fulfill()
        }
        
        waitForExpectations(timeout: 3)
    }
    
    func testCreateSelfFulfillingPromise()
    {
        func asyncFuncReturningEarly() -> Promise<Int> { .fulfilling(42) }
        
        let receivedValue = expectation(description: "received value")
        
        asyncFuncReturningEarly().observed
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
