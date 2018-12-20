import XCTest
import SwiftObserver
import Foundation

class SwiftObserverTests: XCTestCase
{
    func testStringProperty()
    {
        let text = Var("")
        
        text.string += "append"
        
        XCTAssertEqual("append", text.value)
        
    }
    
    func testWeakMappingSource()
    {
        let toString = Weak(Var<Int?>()).new().unwrap(0).map { "\($0)" }
        
        let sourceIsDead = toString.source.observable == nil
        
        XCTAssert(sourceIsDead)
    }
    
    func testMessenger()
    {
        let textMessenger = Messenger<String?>()
        
        let message = "latest message"
        
        textMessenger.send(message)
        
        XCTAssertEqual(textMessenger.latestMessage, message)
        
        var observedMessage: String?
        
        controller.observe(textMessenger) { observedMessage = $0 }
        
        textMessenger.send()
        
        XCTAssertEqual(observedMessage, message)
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
    
    func testStringVariableStringAccess()
    {
        let text = Var("1234567")
        
        XCTAssertEqual(text.count, 7)
        XCTAssertEqual(text[text.startIndex], "1")
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
        let textMapping = Var<String?>("non optional string").new()
        
        var didFire = false
        var observedString: String?
        
        controller.observe(textMapping).unwrap("untitled")
        {
            observedString = $0
            didFire = true
        }
        
        textMapping.source <- nil
        
        XCTAssert(didFire)
        XCTAssertEqual("untitled", observedString)
    }
    
    func testObservationMappingChainAfterUnwrap()
    {
        let textMapping = Var<String?>("non optional string").new()
        
        var didFire = false
        var observedCount: Int?
        
        controller.observe(textMapping).unwrap("untitled").map({ $0.count })
        {
            observedCount = $0
            didFire = true
        }
        
        textMapping.source <- nil
        
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
        let textMapping = Var().new().unwrap("")
        
        var didFire = false
        
        controller.observe(textMapping).select("test")
        {
            didFire = true
        }
        
        textMapping.source <- "test"
        XCTAssert(didFire)
        
        didFire = false
        textMapping.source <- "test2"
        XCTAssert(!didFire)
    }
    
    func testMappingSelect()
    {
        let textMapping = Var().new().unwrap("").select("test")
        
        var didFire = false
        
        controller.observe(textMapping)
        {
            didFire = true
        }
        
        textMapping.source <- "test"
        XCTAssert(didFire)
        
        didFire = false
        textMapping.source <- "test2"
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
    
    func testMultiplication()
    {
        XCTAssertEqual(Var(2) * Var(7), 14)
        XCTAssertEqual(Var(2) * 7, 14)
        XCTAssertEqual(2 * Var(7), 14)
        
        var product = 2
        product.int *= Var(7).int
        XCTAssertEqual(product, 14)
        
        let var1 = Var(2)
        var1.int *= 7
        XCTAssertEqual(var1.int, 14)
        
        var1 <- 2
        XCTAssertEqual(var1.int, 2)
        var1.int *= Var(7).int
        XCTAssertEqual(var1.int, 14)
    }
    
    func testAddition()
    {
        XCTAssertEqual(Var(2) + Var(7), 9)
        XCTAssertEqual(Var(2) + 7, 9)
        XCTAssertEqual(2 + Var(7), 9)
        
        var sum = 2
        sum.int += Var(7).int
        XCTAssertEqual(sum, 9)
        
        let var1 = Var(2)
        var1.int += 7
        XCTAssertEqual(var1.int, 9)
        
        var1 <- 2
        XCTAssertEqual(var1.int, 2)
        var1.int += Var(7).int
        XCTAssertEqual(var1.int, 9)
    }
    
    func testAdditionOnOptionalInt()
    {
        XCTAssertEqual(Var<Int?>(2) + Var<Int?>(7), 9)
        XCTAssertEqual(Var<Int?>(2) + 7, 9)
        XCTAssertEqual(2 + Var<Int?>(7), 9)
        
        var sum = 2
        sum += Var<Int?>(7).int
        XCTAssertEqual(sum, 9)
        
        let var1 = Var<Int?>(2)
        var1.int += 7
        XCTAssertEqual(var1.int, 9)
        
        var1 <- 2
        XCTAssertEqual(var1.int, 2)
        var1.int += Var<Int?>(7).int
        XCTAssertEqual(var1.int, 9)
    }
    
    func testSubtraction()
    {
        XCTAssertEqual(Var(7) - Var(2), 5)
        XCTAssertEqual(Var(7) - 2, 5)
        XCTAssertEqual(7 - Var(2), 5)
        
        var num = 2
        num.int -= Var(7).int
        XCTAssertEqual(num, -5)
        
        let var1 = Var(2)
        var1.int -= 7
        XCTAssertEqual(var1.int, -5)
        
        var1 <- 2
        XCTAssertEqual(var1.int, 2)
        var1.int -= Var(7).int
        XCTAssertEqual(var1.int, -5)
    }
    
    func testWeakObservable()
    {
        var strongObservable: Var<Int>? = Var(10)
        
        let weakObservable = Weak(strongObservable!)
        
        XCTAssert(strongObservable === weakObservable.observable)
        
        strongObservable = nil
        
        XCTAssertNil(weakObservable.observable)
        XCTAssertEqual(weakObservable.latestMessage.new, 10)
    }
    
    func testSettingObservableOfMapping()
    {
        let mapping = Var("").new()
        
        var observedStrings = [String]()
        
        controller.observe(mapping)
        {
            newString in
            
            observedStrings.append(newString)
        }
        
        XCTAssertEqual(observedStrings, [])
        
        let initialText = "initial text"
        
        let text = Var(initialText)
        mapping.source = text
        
        XCTAssertEqual(mapping.latestMessage, initialText)
        XCTAssertEqual(observedStrings, [initialText])
        
        let newText = "new text"
        text <- newText
        
        XCTAssertEqual(mapping.latestMessage, newText)
        XCTAssertEqual(observedStrings, [initialText, newText])
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
    
    func testCombineMappingsByChainingThem()
    {
        let number = Var<Int?>()
        
        var strongNewNumber: Mapping<Var<Int?>, Int?>? = number.new()
        weak var weakNewNumber = strongNewNumber
        
        guard let strongUnwrappedNewNumber = weakNewNumber?.filter({ $0 != nil }).unwrap(-1) else
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

        XCTAssertEqual(strongUnwrappedNewNumber.latestMessage, -1)
        
        number <- 9
        XCTAssertEqual(strongUnwrappedNewNumber.latestMessage, 9)
        
        number <- nil
        XCTAssertEqual(strongUnwrappedNewNumber.latestMessage, -1)
        
        number <- 10
        XCTAssertEqual(strongUnwrappedNewNumber.latestMessage, 10)
        
        XCTAssertEqual(observedNumbers, [9, 10])
    }
    
    func testSimpleMessenger()
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
    
    func testSimpleMessengerWithSpecificMessage()
    {
        let textMessenger = Var<String?>().new()
        var receivedMessage: String?
        let expectedMessage = "message"
        
        controller.observe(textMessenger).select(expectedMessage)
        {
            receivedMessage = expectedMessage
        }
        
        textMessenger.send(expectedMessage)
        
        XCTAssertEqual(receivedMessage, expectedMessage)
    }
    
    func testMessengerBackedByVariable()
    {
        let textMessage = Var<String>("initial message")
        let textMessenger = textMessage.new()
        
        XCTAssertEqual(textMessenger.latestMessage, "initial message")
        
        var receivedMessage: String?
        
        controller.observe(textMessenger)
        {
            receivedMessage = $0
        }
        
        XCTAssertNil(receivedMessage)
        
        textMessage <- "user error"
        
        XCTAssertEqual(textMessenger.latestMessage, "user error")
        XCTAssertEqual(receivedMessage, "user error")
    }
    
    func testObservingWrongMessage()
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

    func testHowToUseOptionalVariables()
    {
        let text = Var<String?>("initial value")
        
        text <- nil
        
        XCTAssertNil(text.value)
        
        var didUpdate = false
        
        controller.observe(text)
        {
            XCTAssertEqual($0.new, "text")
            
            didUpdate = true
        }
        
        text <- "text"
        
        XCTAssertEqual(text.value, "text")
        XCTAssert(didUpdate)
    }
    
    func testHowToMapVariablesToNonOptionalValues()
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
    
    func testHowToUseUnwrapMapping()
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
    
    func testObservingVariableDoesNotTriggerUpdate()
    {
        let text = Var("initial text")
        
        var didTriggerUpdate = false
        
        controller.observe(text)
        {
            _ in
            
            didTriggerUpdate = true
        }
        
        XCTAssertFalse(didTriggerUpdate)
    }
    
    func testObservingVariableValueChange()
    {
        let text = Var<String?>()
        
        var observedNewValue: String?
        var observedOldValue: String?
        
        controller.observe(text)
        {
            observedOldValue = $0.old
            observedNewValue = $0.new
        }
        
        text <- "new text"
        
        XCTAssertEqual(observedOldValue, nil)
        XCTAssertEqual(observedNewValue, "new text")
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
    
    
    func testObservingTwoObservables()
    {
        let testModel = ObservableModel()
        let number = Var<Int?>()
        
        var didFire = false
        var lastObservedEvent: ObservableModel.Event?
        var lastObservedNumber: Int?
        
        controller.observe(testModel, number)
        {
            event, numberUpdate in
            
            didFire = true
            
            lastObservedEvent = event
            lastObservedNumber = numberUpdate.new
        }
        
        testModel.send(.didUpdate)
        
        XCTAssert(didFire)
        XCTAssertEqual(lastObservedEvent, .didUpdate)
        
        didFire = false
        number <- 7
        
        XCTAssert(didFire)
        XCTAssertEqual(lastObservedNumber, 7)
    }
    
    func testVariableIsCodable()
    {
        var didEncode = false
        var didDecode = false
        
        let variable = Var(123)
        
        if let variableData = try? JSONEncoder().encode(variable)
        {
            let actual = String(data: variableData, encoding: .utf8) ?? "fail"
            let expected = "{\"storedValue\":123}"
            XCTAssertEqual(actual, expected)
            
            didEncode = true
            
            if let decodedVariable = try? JSONDecoder().decode(Var<Int>.self,
                                                               from: variableData)
            {
                XCTAssertEqual(decodedVariable.value, 123)
                didDecode = true
            }
        }
        
        XCTAssert(didEncode)
        XCTAssert(didDecode)
    }
    
    func testCodingTheModel()
    {
        let model = CodableModel()
        
        var didEncode = false
        var didDecode = false
        
        model.text <- "123"
        model.number <- 123
        
        if let modelJson = try? JSONEncoder().encode(model)
        {
            let actual = String(data: modelJson, encoding: .utf8) ?? "fail"
            let expected = "{\"number\":{\"storedValue\":123},\"text\":{\"storedValue\":\"123\"}}"
            XCTAssertEqual(actual, expected)
            
            didEncode = true
            
            if let decodedModel = try? JSONDecoder().decode(CodableModel.self,
                                                            from: modelJson)
            {
                XCTAssertEqual(decodedModel.text.value, "123")
                XCTAssertEqual(decodedModel.number.value, 123)
                didDecode = true
            }
        }
        
        XCTAssert(didEncode)
        XCTAssert(didDecode)
    }
    
    func testObservingThreeVariables()
    {
        let var1 = Var<Bool?>()
        let var2 = Var<Int?>()
        let var3 = Var<String?>()
        
        let observer = Controller()
        
        var observedString: String?
        var didFire = false
        
        observer.observe(var1, var2, var3)
        {
            truth, number, string in
            
            didFire = true
            observedString = string.new
        }
        
        var3 <- "test"
        
        XCTAssert(didFire)
        XCTAssertEqual(observedString, "test")
    }
    
    class CodableModel: Codable
    {
        private(set) var text = Var<String?>()
        private(set) var number = Var<Int?>()
    }
    
    class MinimalModel: CustomObservable
    {
        let messenger = Messenger<Int?>()
        typealias Message = Int?
    }
    
    class ObservableModel: CustomObservable
    {
        typealias Message = Event
        
        let messenger = Messenger(Event.didNothing)
        
        enum Event: String { case didUpdate, didReset, didNothing }
    }
    
    let customObservable = ModelWithState()
    
    class ModelWithState: CustomObservable
    {
        var latestMessage: Change<String>
        {
            return Change(state, state)
        }
        
        var state = "initial state"
        {
            didSet
            {
                if oldValue != state
                {
                    send(Change(oldValue, state))
                }
            }
        }
        
        let messenger = Messenger(Change("", ""))
    }
    
    let controller = Controller()
 
    class Controller: Observer
    {
        deinit
        {
            stopObserving()
        }
    }
}

