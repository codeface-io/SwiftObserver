import XCTest
@testable import SwiftObserver

class AnononymousObservationTests: XCTestCase
{
    func testThatAnonymousObserverIsAvailable()
    {
        let messenger = Messenger<Void>()
        var messengerDidSend = false
        
        AnonymousObserver.shared.observe(messenger)
        {
            messengerDidSend = true
        }
        
        messenger.send(())
        
        XCTAssert(messengerDidSend)
    }
    
    func testThatAnonymousObserverCanBeUsedImplicitly()
    {
        let messenger = Messenger<Void>()
        var messengerDidSend = false
        
        XCTAssertFalse(AnonymousObserver.shared.isObserving(messenger))
        
        SwiftObserver.observe(messenger)
        {
            messengerDidSend = true
        }
        
        XCTAssert(AnonymousObserver.shared.isObserving(messenger))
        
        messenger.send(())
        
        XCTAssert(messengerDidSend)
    }
    
    func testThatAnonymousObservationCanBeTransformed()
    {
        let messenger = Messenger<Void>()
        var messengerDidSend = false
        
        SwiftObserver.observe(messenger).map
        {
            "true"
        }
        .receive
        {
            messengerDidSend = $0 == "true"
        }
        
        messenger.send(())
        
        XCTAssert(messengerDidSend)
    }
}
