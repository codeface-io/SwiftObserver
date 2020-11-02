import XCTest
@testable import SwiftObserver

class PromiseTests: XCTestCase
{
    func testThatPromiseCanBeFulfilledAsynchronously()
    {
        let promise = Promise<Void>()
        
        let promiseFulfilled = expectation(description: "promise is fulfilled")
        
        let observer = TestObserver()
        
        observer.observe(promise)
        {
            promiseFulfilled.fulfill()
        }
        
        DispatchQueue.main.async { promise.fulfill(()) }
        
        waitForExpectations(timeout: 3)
    }
    
    func testThatPromiseProvidesValueAsynchronously()
    {
        let promise = Promise<Int>()
        
        let valueReceived = expectation(description: "did reveive value from promise")
        
        let observer = TestObserver()
        
        observer.observe(promise)
        {
            XCTAssertEqual($0, 42)
            XCTAssertEqual($0, promise.value)
            valueReceived.fulfill()
        }
        
        DispatchQueue.main.async { promise.fulfill(42) }
        
        waitForExpectations(timeout: 3)
    }
    
    func testThatFulfilledPromiseProvidesValueSynchronously()
    {
        let promise = Promise<Int>()
        
        XCTAssertEqual(promise.value, nil)
        
        promise.fulfill(42)
        
        XCTAssertEqual(promise.value, 42)
    }
    
    func testThatPromiseDiesAfterBeingFulfilledAsynchronously()
    {
        func asyncFunc() -> Promise<Void>
        {
            Promise { promise in DispatchQueue.main.async { promise.fulfill(()) } }
        }
        
        weak var weakPromise = asyncFunc()
        
        XCTAssertNotNil(weakPromise)

        let promiseFulfilled = expectation(description: "promise is fulfilled")

        let observer = TestObserver()

        observer.observe(weakPromise!)
        {
            promiseFulfilled.fulfill()
        }

        waitForExpectations(timeout: 3)
        
        XCTAssertNil(weakPromise)
    }
    
    func testThatPromiseStopsBeingObservedAfterBeingFulfilled()
    {
        let promise = Promise<Void>()
        
        var numberOfReceivedValues = 0
        
        let observer = TestObserver()
        
        observer.observe(promise)
        {
            numberOfReceivedValues += 1
        }
        
        promise.fulfill(())
        
        XCTAssertEqual(numberOfReceivedValues, 1)
        
        promise.fulfill(())
        
        XCTAssertEqual(numberOfReceivedValues, 1)
    }
    
    class TestObserver: Observer
    {
        let receiver = Receiver()
    }
}
