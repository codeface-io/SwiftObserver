import XCTest
import SwiftObserver

class SwiftObserverTests: XCTestCase
{
    func testSingleObservationFilter()
    {
        let number = Var(99)
        let latestUnwrappedNumber = number.new().unwrap(0)
        
        var observedNumbers = [Int]()
        
        controller.observe(latestUnwrappedNumber, filter: { $0 > 9 })
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
        let number = Var(99)
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
    
    func testCombineMappingsByChainingThem()
    {
        let number = Var<Int>()
        
        var strongNewNumber: Mapping<Variable<Int>, Int?>? = number.new()
        weak var weakNewNumber = strongNewNumber
        
        guard let strongUnwrappedNewNumber = weakNewNumber?.unwrap(-1) else
        {
            XCTAssert(false)
            return
        }
        
        var observedNumbers = [Int]()
        
        controller.observe(strongUnwrappedNewNumber)
        {
            observedNumbers.append($0)
        }
        
        XCTAssertNotNil(strongNewNumber)
        XCTAssertNotNil(weakNewNumber)
        
        strongNewNumber = nil
        XCTAssertNil(weakNewNumber)

        XCTAssertEqual(strongUnwrappedNewNumber.latestUpdate, -1)
        
        number <- 9
        XCTAssertEqual(strongUnwrappedNewNumber.latestUpdate, 9)
        
        number <- nil
        XCTAssertEqual(strongUnwrappedNewNumber.latestUpdate, 9)
        
        number <- 10
        XCTAssertEqual(strongUnwrappedNewNumber.latestUpdate, 10)
        
        XCTAssertEqual(observedNumbers, [9, 10])
    }
    
    func testCustomMessenger()
    {
        enum Event { case none, userError, techError }
        
        let eventMessenger = Messenger<Event>(.none)
        
        XCTAssertEqual(eventMessenger.latestMessage, .none)
        
        var receivedEvent: Event?
        
        controller.observe(eventMessenger)
        {
            receivedEvent = $0
        }
        
        XCTAssertNil(receivedEvent)
        
        eventMessenger.send(.userError)
        
        XCTAssertEqual(eventMessenger.latestMessage, eventMessenger.latestUpdate)
        XCTAssertEqual(eventMessenger.latestMessage, .userError)
        XCTAssertEqual(receivedEvent, .userError)
    }
    
    func testObservingWrongMessage()
    {
        var receivedMessage: String?
        
        controller.observe("wrong message", from: textMessenger)
        {
            receivedMessage = "wrong message"
        }
        
        textMessenger.send("right message")
        
        XCTAssertNil(receivedMessage)
    }
    
    func testObservingMessenger()
    {
        var receivedMessage: String?
        let expectedMessage = "message"
        
        controller.observe(textMessenger)
        {
            receivedMessage = $0
        }
        
        textMessenger.send(expectedMessage)
        
        XCTAssertEqual(textMessenger.latestMessage, expectedMessage)
        XCTAssertEqual(receivedMessage, expectedMessage)
    }
    
    func testObservingMessage()
    {
        var receivedMessage: String?
        let expectedMessage = "message"
        
        controller.observe(expectedMessage, from: textMessenger)
        {
            receivedMessage = expectedMessage
        }
    
        textMessenger.send(expectedMessage)
        
        XCTAssertEqual(receivedMessage, expectedMessage)
    }
    
    /*
    func testPairRetainsItsVariables()
    {
        var v1: Var<Int>? = Var(1)
        var v2: Var<Int>? = Var(2)
        
        if let pair = v1 + v2
        {
            v1 = nil
            v2 = nil
            
            XCTAssertEqual(pair.value.left, 1)
            XCTAssertEqual(pair.value.right, 2)
        }
        else
        {
            XCTAssert(false)
        }
    }
     */

    func testHowToUseOptionalVariables()
    {
        let text = Var("initial value")
        
        text <- nil
        
        XCTAssertNil(text.value)
        
        text <- "text"
        
        XCTAssertEqual(text.value, "text")
        
        controller.observe(text)
        {
            XCTAssertEqual($0.new, "text")
        }
    }
    
    func testHowToMapVariablesToNonOptionalValues()
    {
        let text = Var<String>()
        
        let nonOptionalText = text.map { $0.new ?? "" }
        
        controller.observe(nonOptionalText)
        {
            XCTAssertEqual($0, "")
        }
    }
    
    func testHowToUseUnwrapMapping()
    {
        let text = Var<String>()
        
        controller.observe(text.new().unwrap(""))
        {
            XCTAssertEqual($0, "")
        }
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
        controller.observe(model)
        {
            XCTAssertEqual($0, .didUpdate)
        }
        
        model.send(.didUpdate)
    }
    
    func testObservingVariableTriggersUpdate()
    {
        let expectedValue = "expected value"
        
        model.text <- expectedValue
        
        controller.observe(model.text)
        {
            XCTAssertEqual($0.old, expectedValue)
            XCTAssertEqual($0.new, expectedValue)
        }
    }
    
    func testObservingVariableValueChange()
    {
        var observedNewValue: String?
        var observedOldValue: String?
        
        controller.observe(model.text)
        {
            observedOldValue = $0.old
            observedNewValue = $0.new
        }
        
        XCTAssertEqual(observedOldValue, model.text.value)
        XCTAssertEqual(observedNewValue, model.text.value)
        
        let expectedNewValue = "new value"
        
        model.text <- expectedNewValue
        
        XCTAssertEqual(observedNewValue, expectedNewValue)
    }
    
    /*
    func testObservingPairVariableTriggersUpdate()
    {
        let combinedVariable = Var("Text 1") + Var(7) + Var("Text 2")
        
        controller.observe(combinedVariable)
        {
            update in
            
            XCTAssertEqual(update.old.left.left, "Text 1")
            XCTAssertEqual(update.old.left.right, 7)
            XCTAssertEqual(update.old.right, "Text 2")
            
            XCTAssertEqual(update.new.left.left, "Text 1")
            XCTAssertEqual(update.new.left.right, 7)
            XCTAssertEqual(update.new.right, "Text 2")
        }
    }
    */
    
    func testObservableMapping()
    {
        controller.observe(model.map { $0.rawValue })
        {
            XCTAssertEqual($0, "didUpdate")
        }
        
        model.send(.didUpdate)
    }
    
    /*
    func testSettingValueOnPairVariableTriggersUpdate()
    {
        model.text <- "old"
        model.number <- 0
        
        let textAndNumber = model.text + model.number
        
        var didUpdateText = false
        var didUpdateNumber = false
        var numberOfObservations = 0
        
        controller.observe(textAndNumber)
        {
            numberOfObservations += 1
            
            if $0.new.left == "truth"
            {
                if !didUpdateText
                {
                    XCTAssertEqual($0.old.left, "old")
                }
                
                didUpdateText = true
            }
            else
            {
                XCTAssertEqual($0.new.left, "old")
            }
            
            if $0.new.right == 42
            {
                if !didUpdateNumber
                {
                    XCTAssertEqual($0.old.right, 0)
                }
                
                didUpdateNumber = true
            }
            else
            {
                XCTAssertEqual($0.new.right, 0)
            }
        }
        
        textAndNumber <- "truth" +++ 42
        
        XCTAssertTrue(didUpdateText)
        XCTAssertTrue(didUpdateNumber)
        XCTAssertEqual(numberOfObservations, 3)
    }
 
    func testSettingNestedValueOnPairVariable()
    {
        let combinedVariable = Var(0.75) + Var("text") + Var(10)
        
        combinedVariable <- 0.33 +++ "new" +++ 42
        
        XCTAssertEqual(combinedVariable.value.left.right, "new")
    }
    */
    
    func testObservingTwoObservablesTriggersUpdate()
    {
        let number = Var(7)
        
        controller.observe(model, number)
        {
            XCTAssertEqual($0, .didNothing)
            
            XCTAssertEqual($1.old, 7)
            XCTAssertEqual($1.new, 7)
        }
    }
    
    /*
    // this test would require FoundationToolz which we don't want to import here
    func testCodingTheModel()
    {
        var didEncode = false
        var didDecode = false
        
        if let modelData = try? JSONEncoder().encode(model)
        {
            didEncode = true
            
            if let _ = try? JSONDecoder().decode(Model.self,
                                                 from: modelData)
            {
                didDecode = true
            }
        }
        
        XCTAssert(didEncode)
        XCTAssert(didDecode)
    }
    */

    let model = Model()
    
    let controller = Controller()
    
    class Model: Observable, Codable
    {
        var latestUpdate: Event { return .didNothing }
        
        enum Event: String { case didUpdate, didReset, didNothing }
        
        let text = Var("")
        let number = Var(0)
    }
    
    let customObservable = ModelWithState()
    
    class ModelWithState: Observable
    {
        var latestUpdate: Update<String>
        {
            return Update(state, state)
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
    }
 
    class Controller: Observer
    {
        deinit
        {
            stopAllObserving()
        }
    }
}

