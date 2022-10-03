import XCTest
import SwiftObserver

class CustomObservableTests: XCTestCase
{
    func testObservingACustomObservable()
    {
        let model = ObservableModel()
        
        var didUpdate = false
        
        let observer = FreeObserver()
        
        observer.observe(model)
        {
            XCTAssertEqual($0, .didUpdate)
            didUpdate = true
        }
        
        model.send(.didUpdate)
        
        XCTAssert(didUpdate)
    }
    
    func testMapObservationOfCustomObservable()
    {
        let model = ObservableModel()
        
        var didFire = false
        
        let observer = FreeObserver()
        
        observer.observe(model).map({ $0.rawValue })
        {
            XCTAssertEqual($0, "didUpdate")
            didFire = true
        }
        
        model.send(.didUpdate)
        
        XCTAssert(didFire)
    }
    
    func testMapSelectObservationOfCustomObservable()
    {
        let model = ObservableModel()
        
        let mappedModel = model.select(.didUpdate)
        
        var didFire = false
        
        let observer = FreeObserver()
        
        observer.observe(mappedModel)
        {
            didFire = true
        }
        
        model.send(.didUpdate)
        XCTAssert(didFire)
        
        didFire = false
        model.send(.didReset)
        XCTAssert(!didFire)
    }
    
    func testNewMappingOnCustomObservable()
    {
        let customObservable = ModelWithState()
        
        let newState = customObservable.new()
        
        customObservable.state = "state1"
        
        var didUpdate = false
        
        let observer = FreeObserver()
        
        observer.observe(newState)
        {
            XCTAssert($0 == "state1" || $0 == "state2")
            
            didUpdate = $0 == "state2"
        }
        
        customObservable.state = "state2"
        
        XCTAssert(didUpdate)
    }
    
    class ObservableModel: ObservableCache
    {
        var latestMessage: Event { .didNothing }

        let messenger = Messenger<Event>()

        enum Event: String { case didNothing, didUpdate, didReset }
    }

    class ModelWithState: ObservableCache
    {
        var latestMessage: Update<String>
        {
            Update(state, state)
        }

        var state = "initial state"
        {
            didSet
            {
                if oldValue != state
                {
                    send(Update(oldValue, state))
                }
            }
        }

        let messenger = Messenger<Update<String>>()
    }
}

