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
    
    func testObserveOnceObserverDiesWhenObservableSendsMessage()
    {
        let messenger = Messenger<Void>()
        
        weak var observer = observeOnce(messenger) {}
        
        XCTAssertNotNil(observer)
        messenger.send(())
        XCTAssertNil(observer)
    }
    
    func testObserveOnceObserverDiesWhenObservableDies()
    {
        var messenger: Messenger<Void>? = Messenger<Void>()
        
        weak var observer = observeOnce(messenger!) {}
        
        XCTAssertNotNil(observer)
        messenger = nil
        XCTAssertNil(observer)
    }
}
