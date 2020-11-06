import XCTest
@testable import SwiftObserver

class BasicTests: XCTestCase
{
    func testObserverving()
    {
        let messenger = Messenger<Int>()
        let observer = FreeObserver()
        var receivedNumber: Int?
        
        observer.observe(messenger) { receivedNumber = $0 }
        
        XCTAssertEqual(receivedNumber, nil)
        
        messenger.send(42)
        
        XCTAssertEqual(receivedNumber, 42)
    }
    
    func testObservingAloneDoesNotSendAMessage()
    {
        let messenger = Messenger<Void>()
        
        var didTriggerUpdate = false
        
        let observer = FreeObserver()
        
        observer.observe(messenger)
        {
            didTriggerUpdate = true
        }
        
        XCTAssertFalse(didTriggerUpdate)
    }
    
    func testMaintainingMessageOrder()
    {
        let messenger = Messenger<Int>()
        let observer1 = FreeObserver()
        let observer2 = FreeObserver()
        var receivedNumbers = [Int]()
        
        observer1.observe(messenger)
        {
            receivedNumbers.append($0)
            if $0 == 0 { messenger.send(1) }
        }
        
        observer2.observe(messenger)
        {
            receivedNumbers.append($0)
            if $0 == 0 { messenger.send(2) }
        }
        
        messenger.send(0)
        
        XCTAssertEqual(receivedNumbers.count, 6)
        XCTAssertEqual(receivedNumbers[0], 0)
        XCTAssertEqual(receivedNumbers[1], 0)
        XCTAssertEqual(receivedNumbers[2], receivedNumbers[3])
    }
    
    func testObservingAndReceivingAuthor()
    {
        let messenger = Messenger<Int>()
        let observer = FreeObserver()
        var receivedNumber: Int?
        var receivedAuthor: AnyAuthor?
        
        observer.observe(messenger)
        {
            number, author in
            receivedNumber = number
            receivedAuthor = author
        }
        
        messenger.send(42, from: observer)
        
        XCTAssertEqual(receivedNumber, 42)
        XCTAssert(receivedAuthor === observer)
    }
    
    func testObservingSameObservableWithMultipleMessageHandlers()
    {
        let messenger = Messenger<Void>()
        let observer = FreeObserver()
        var sum = 0
        
        observer.observe(messenger) { sum += 1 }
        observer.observe(messenger) { sum += 2 }
        
        XCTAssertEqual(sum, 0)
        
        messenger.send(())
        
        XCTAssertEqual(sum, 3)
    }
    
    func testCombinedObservation()
    {
        let text = Var<String?>()
        var receivedText: String?
        
        let number = Var<Int?>()
        var receivedNumber: Int?
        
        let observer = FreeObserver()
        
        observer.observe(text, number)
        {
            textUpdate, numberUpdate in
            
            receivedText = textUpdate.new
            receivedNumber = numberUpdate.new
        }
        
        XCTAssertEqual(receivedText, nil)
        XCTAssertEqual(receivedNumber, nil)
        
        text <- "new text"
        
        XCTAssertEqual(receivedText, "new text")
        XCTAssertEqual(receivedNumber, nil)
        
        number <- 7
        
        XCTAssertEqual(receivedText, "new text")
        XCTAssertEqual(receivedNumber, 7)
        
        text <- "newer text"
        
        XCTAssertEqual(receivedText, "newer text")
        XCTAssertEqual(receivedNumber, 7)
    }
    
    func testWhenFilledObservesUntilNonOptionalMessage()
    {
        let messengerCache = Messenger<Int>().cache()
        
        var receivedNonOptionalValue = false
        
        messengerCache.whenCached
        {
            _ in receivedNonOptionalValue = true
        }
        
        messengerCache.send(nil)
        messengerCache.send(1)
        
        XCTAssert(receivedNonOptionalValue)
    }
}
