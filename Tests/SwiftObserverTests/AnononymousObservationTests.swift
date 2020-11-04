import XCTest
@testable import SwiftObserver

class AnononymousObservationTests: XCTestCase
{
    func testAnonymousObserverIsAvailable()
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
    
    func testAnonymousObserverCanBeUsedImplicitly()
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
    
    func testAnonymousObservationCanBeTransformed()
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
    
    func testObserveOnce()
    {
        let messenger = Messenger<Void>()
        var receivedMessage = false
        
        var observer: FreeObserver?
        
        observer = observeOnce(messenger)
        {
            XCTAssertFalse(observer?.isObserving(messenger) ?? true)
            receivedMessage = true
        }
        
        XCTAssert(observer!.isObserving(messenger))
        XCTAssertFalse(receivedMessage)
        
        messenger.send(())
        XCTAssertFalse(observer!.isObserving(messenger))
        XCTAssert(receivedMessage)
        
        receivedMessage = false
        messenger.send(())
        XCTAssertFalse(receivedMessage)
    }
    
    func testObserveOnceObserverDies()
    {
        let messenger = Messenger<Void>()
        
        weak var observer = observeOnce(messenger) {}
        
        XCTAssertNotNil(observer)
        messenger.send(())
        XCTAssertNil(observer)
    }
}
