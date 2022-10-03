import XCTest
import SwiftObserver

class FreeObservationTests: XCTestCase
{
    func testFreeObserverIsAvailable()
    {
        let messenger = Messenger<Void>()
        var messengerDidSend = false
        
        FreeObserver.shared.observe(messenger)
        {
            messengerDidSend = true
        }
        
        messenger.send(())
        
        XCTAssert(messengerDidSend)
    }
    
    func testFreeObserverCanBeUsedImplicitly()
    {
        let messenger = Messenger<Void>()
        var messengerDidSend = false
        
        XCTAssertFalse(FreeObserver.shared.isObserving(messenger))
        
        SwiftObserver.observe(messenger)
        {
            messengerDidSend = true
        }
        
        XCTAssert(FreeObserver.shared.isObserving(messenger))
        
        messenger.send(())
        
        XCTAssert(messengerDidSend)
    }
    
    func testFreeObservationCanBeTransformed()
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
