import XCTest
import SwiftObserver

class OldTestsToRework: XCTestCase
{
    func testWeakObservableWrapper()
    {
        let weakNumber1 = Var(1).weak()
        XCTAssertNil(weakNumber1.origin)
        
        let strongNumber = Var(2)
        let weakNumber2 = strongNumber.weak()
        XCTAssertEqual(weakNumber2.origin?.value, 2)
    }
    
    func testSendOnVariable()
    {
        let initialText = "initial text"
        
        let text = Var(initialText)
        
        var observedText: String?
        
        controller.observe(text) { observedText = $0.new }
        
        text.send()
        
        XCTAssertEqual(observedText, initialText)
    }
    
    func testThatMappersOfCachesAreCaches()
    {
        XCTAssertEqual(Var(1).new().latestMessage, 1)
        XCTAssertEqual(Var<Int?>().new().unwrap(23).latestMessage, 23)
        XCTAssertEqual(Var(5).map({ $0.new == 5 }).latestMessage, true)
    }
    
    func testChainingObservationMappers()
    {
        var didFire = false
        
        let number = Var(42)
        
        controller.observe(number).new().map {
            "\($0)"               // Int -> String
        }.filter {
            $0.count > 1          // filter out single digit integers
        }.map {
            Int.init($0)          // String -> Int?
        }.filter {
            $0 != nil             // filter out nil values
        }.unwrap(-1) { _ in       // Int? -> Int
            didFire = true        // process Int
        }
        
        number <- 10
        
        XCTAssert(didFire)
    }
    
    func testChainingObservationMappersWithReceive()
    {
        var didFire = false
        
        let number = Var(42)
        
        controller.observe(number).map {
            $0.new           // Update<Int> -> Int
        }.receive { _ in
            didFire = true   // process Int
        }
        
        number <- 10
        
        XCTAssert(didFire)
    }
    
    func testObservationMapping()
    {
        let testText = Var<String?>()
        
        var didFire = false
        var observedString: String?
        
        controller.observe(testText).map({ $0.new })
        {
            observedString = $0
            didFire = true
        }
        
        testText <- "test"
        
        XCTAssert(didFire)
        XCTAssertEqual("test", observedString)
    }
    
    func testObservationMappingChained()
    {
        let testText = Var<String?>("non optional string")
        
        var didFire = false
        var observedString: String?
        
        controller.observe(testText).map {
            $0.new
        }.map {
            $0 ?? "untitled"
        }.receive {
            observedString = $0
            didFire = true
        }
        
        testText <- nil
        
        XCTAssert(didFire)
        XCTAssertEqual("untitled", observedString)
    }
    
    func testObservationMappingNew()
    {
        let testText = Var<String?>()
        
        var didFire = false
        var observedString: String?
        
        controller.observe(testText).new
            {
                observedString = $0
                didFire = true
        }
        
        testText <- "test"
        
        XCTAssert(didFire)
        XCTAssertEqual("test", observedString)
    }
    
    func testObservationMappingChainAfterNew()
    {
        let testText = Var<String?>()
        
        var didFire = false
        var observedString: String?
        
        controller.observe(testText).new().map({ $0 ?? ""})
        {
            observedString = $0
            
            didFire = true
        }
        
        testText <- "test"
        
        XCTAssert(didFire)
        XCTAssertEqual("test", observedString)
    }
    
    func testObservationMappingUnwrap()
    {
        let text = Var<String?>("non optional string")
        
        var didFire = false
        var observedString: String?
        
        controller.observe(text).new().unwrap("untitled")
        {
            observedString = $0
            didFire = true
        }
        
        text <- nil
        
        XCTAssert(didFire)
        XCTAssertEqual("untitled", observedString)
    }
    
    func testObservationMappingChainAfterUnwrap()
    {
        let text = Var<String?>("non optional string")
        
        var didFire = false
        var observedCount: Int?
        
        controller.observe(text).new().unwrap("untitled").map({ $0.count })
        {
            observedCount = $0
            didFire = true
        }
        
        text <- nil
        
        XCTAssert(didFire)
        XCTAssertEqual("untitled".count, observedCount)
    }
    
    func testObservationMappingFilter()
    {
        let testText = Var<String?>()
        
        var didFire = false
        var observedString: String?
        
        controller.observe(testText).filter({ $0.old != nil })
        {
            observedString = $0.new
            didFire = true
        }
        
        testText <- "test"
        XCTAssert(!didFire)
        XCTAssertNil(observedString)
        
        testText <- "test2"
        XCTAssert(didFire)
        XCTAssertEqual("test2", observedString)
    }
    
    func testObservationMappingSelect()
    {
        let text = Var<String?>()
        let textMapping = text.new().unwrap("")
        
        var didFire = false
        
        controller.observe(textMapping).select("test")
        {
            didFire = true
        }
        
        text <- "test"
        XCTAssert(didFire)
        
        didFire = false
        text <- "test2"
        XCTAssert(!didFire)
    }
    
    func testMappingSelect()
    {
        let text = Var<String?>()
        let textMapping = text.new().unwrap("").select("test")
        
        var didFire = false
        
        controller.observe(textMapping)
        {
            didFire = true
        }
        
        text <- "test"
        XCTAssert(didFire)
        
        didFire = false
        text <- "test2"
        XCTAssert(!didFire)
    }
    
    func testMappingSelectOnCustomObservable()
    {
        let model = ObservableModel()
        
        let mappedModel = model.select(.didUpdate)
        
        var didFire = false
        
        controller.observe(mappedModel)
        {
            didFire = true
        }
        
        model.send(.didUpdate)
        XCTAssert(didFire)
        
        didFire = false
        model.send(.didReset)
        XCTAssert(!didFire)
    }
    
    func testWeakObservable()
    {
        var strongObservable: Var<Int>? = Var(10)
        
        let weakObservable = strongObservable!.weak()
        
        XCTAssert(strongObservable === weakObservable.origin)
        
        strongObservable = nil
        
        XCTAssertNil(weakObservable.origin)
    }
    
    func testSingleObservationFilter()
    {
        let number = Var<Int?>(99)
        let latestUnwrappedNumber = number.new().unwrap(0)
        
        var observedNumbers = [Int]()
        
        controller.observe(latestUnwrappedNumber).filter({ $0 > 9 })
        {
            observedNumbers.append($0)
        }
        
        number <- 10
        number <- nil
        number <- 11
        number <- 1
        number <- 12
        number <- 2
        
        XCTAssertEqual(observedNumbers, [10, 11, 12])
    }
    
    func testMappingsIncludingFilter()
    {
        let number = Var<Int?>(99)
        let doubleDigits = number.new().unwrap(0).filter { $0 > 9 }
        
        var observedNumbers = [Int]()
        
        controller.observe(doubleDigits)
        {
            observedNumbers.append($0)
        }
        
        number <- 10
        number <- nil
        number <- 11
        number <- 1
        number <- 12
        number <- 2
        
        XCTAssertEqual(observedNumbers, [10, 11, 12])
    }
    
    func testFilterSupressesMessage()
    {
        let messenger = Messenger<Int?>()
        let transform = Filter(messenger) { $0 != nil }
        
        var observedNumber: Int? = nil
        
        controller.observe(transform)
        {
            observedNumber = $0
            XCTAssertNotNil($0)
        }
        
        messenger.send(3)
        XCTAssertEqual(observedNumber, 3)

        messenger.send(nil)
        XCTAssertEqual(observedNumber, 3)
    }
    
    func testObservableTransformObject()
    {
        let textMessenger = Var<String?>().new()
        var receivedMessage: String?
        let expectedMessage = "message"
        
        controller.observe(textMessenger)
        {
            receivedMessage = $0
        }
        
        textMessenger.send(expectedMessage)
        
        XCTAssertEqual(receivedMessage, expectedMessage)
    }
    
    func testSelect()
    {
        let textMessenger = Var<String?>().new()
        var didFire = false
        
        controller.observe(textMessenger).select("right message")
        {
            didFire = true
        }
        
        textMessenger.send("right message")
        XCTAssert(didFire)
        
        didFire = false
        textMessenger.send("wrong message")
        XCTAssert(!didFire)
    }
    
    func testObservableMapObject()
    {
        let text = Var<String?>()
        
        let nonOptionalText = text.map { $0.new ?? "" }
        
        var didUpdate = false
        
        controller.observe(nonOptionalText)
        {
            XCTAssertEqual($0, "")
            
            didUpdate = true
        }
        
        text.send()
        
        XCTAssert(didUpdate)
    }
    
    func testObservableNewAndUnwrapObject()
    {
        let text = Var<String?>()
        let unwrappedText = text.new().unwrap("")
        
        var didUpdate = false
        
        controller.observe(unwrappedText)
        {
            XCTAssertEqual($0, "")
            didUpdate = true
        }
        
        text.send()
        
        XCTAssert(didUpdate)
    }
    
    func testHowToUseNewMappingOnObservablesThatAreNotVariables()
    {
        let newState = customObservable.new()
        
        customObservable.state = "state1"
        
        var didUpdate = false
        
        controller.observe(newState)
        {
            XCTAssert($0 == "state1" || $0 == "state2")
            
            didUpdate = $0 == "state2"
        }
        
        customObservable.state = "state2"
        
        XCTAssert(didUpdate)
    }
    
    func testObservingTheModel()
    {
        let model = ObservableModel()
        
        var didUpdate = false
        
        controller.observe(model)
        {
            XCTAssertEqual($0, .didUpdate)
            didUpdate = true
        }
        
        model.send(.didUpdate)
        
        XCTAssert(didUpdate)
    }
    
    func testObservableMapping()
    {
        let model = ObservableModel()
        
        var didFire = false
        
        controller.observe(model).map({ $0.rawValue })
        {
            XCTAssertEqual($0, "didUpdate")
            didFire = true
        }
        
        model.send(.didUpdate)
        
        XCTAssert(didFire)
    }
    
    class ObservableModel: ObservableCache
    {
        var latestMessage: Event { .didNothing }

        let messenger = Messenger<Event>()

        enum Event: String { case didNothing, didUpdate, didReset }
    }
    
    let customObservable = ModelWithState()

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
    
    let controller = FreeObserver()
}
