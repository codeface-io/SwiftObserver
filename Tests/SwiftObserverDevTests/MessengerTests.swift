import XCTest
@testable import SwiftObserverDev
import SwiftObserver

class MessengerTests: XCTestCase
{
    func testMessengerCanSendMessage()
    {
        let messenger = Messenger<Int>()
        let observer = TestObserver()
        var receivedNumbers = [Int]()
        
        observer.observe(messenger) { receivedNumbers.append($0) }
        XCTAssertEqual(receivedNumbers.last, nil)
        
        messenger.send(42)
        XCTAssertEqual(receivedNumbers.last, 42)
        XCTAssertEqual(receivedNumbers.count, 1)
    }
    
    func testMessengerMaintainsMessageOrder()
    {
        let messenger = Messenger<Int>()
        let observer1 = TestObserver()
        let observer2 = TestObserver()
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
        XCTAssertEqual(receivedNumbers[4], receivedNumbers[5])
    }
    
    func testMessengerCanDeactivateMessageOrder()
    {
        let messenger = Messenger<Int>()
        messenger.maintainsMessageOrder = false
        let observer1 = TestObserver()
        let observer2 = TestObserver()
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
        XCTAssertNotEqual(receivedNumbers[0], receivedNumbers[1])
    }
    
    func testMessengerCanSendAuthor()
    {
        let messenger = Messenger<Int>()
        let observer = TestObserver()
        var receivedNumbers = [Int]()
        var receivedAuthors = [AnyAuthor]()
        
        observer.observe(messenger)
        {
            number, author in
            receivedNumbers.append(number)
            receivedAuthors.append(author)
        }
        
        messenger.send(42, from: observer)
        XCTAssertEqual(receivedNumbers, [42])
        XCTAssert(receivedAuthors.last === observer)
        XCTAssertEqual(receivedNumbers.count, 1)
    }
    
    class TestObserver: Observer
    {
        let receiver = Receiver()
    }
}
