import XCTest
@testable import SwiftObserver

class MessengerTests: XCTestCase
{
    func testThatMessengerCanSendMessage()
    {
        let messenger = Messenger<Int>()
        let observer = TestObserver()
        var receivedNumber: Int?
        
        observer.observe(messenger) { receivedNumber = $0 }
        
        XCTAssertEqual(receivedNumber, nil)
        
        messenger.send(42)
        
        XCTAssertEqual(receivedNumber, 42)
    }
    
    func testThatMessengerMaintainsMessageOrder()
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
    }
    
    func testThatMessengerCanSendAuthor()
    {
        let messenger = Messenger<Int>()
        let observer = TestObserver()
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
}
