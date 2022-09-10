import XCTest
import SwiftObserver

class VariableTests: XCTestCase
{
    func testObservingVariableValueChange()
    {
        let text = Var<String?>("old text")
        
        var observedNewValue: String?
        var observedOldValue: String?
        
        let observer = FreeObserver()
        
        observer.observe(text)
        {
            observedOldValue = $0.old
            observedNewValue = $0.new
        }
        
        text <- "new text"
        
        XCTAssertEqual(observedOldValue, "old text")
        XCTAssertEqual(observedNewValue, "new text")
    }
    
    func testOptionalValue()
    {
        let text = Var<String?>("initial value")
        
        text <- nil
        
        XCTAssertNil(text.value)
        
        var didUpdate = false
        
        let observer = FreeObserver()
        
        observer.observe(text)
        {
            XCTAssertEqual($0.new, "text")
            
            didUpdate = true
        }
        
        text <- "text"
        
        XCTAssertEqual(text.value, "text")
        XCTAssert(didUpdate)
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
    
    func testCustomObservableWithVariablePropertiesIsCodable()
    {
        class CodableModel: Codable
        {
            private(set) var text = Var<String?>()
            private(set) var number = Var<Int?>()
        }
        
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
    
    func testPropertyWrapper()
    {
        @Observable var text: String? = "old text"
        
        var observedNewValue: String?
        var observedOldValue: String?
        
        let observer = FreeObserver()
        
        observer.observe($text)
        {
            observedOldValue = $0.old
            observedNewValue = $0.new
        }
        
        text = "new text"
        
        XCTAssertEqual(observedOldValue, "old text")
        XCTAssertEqual(observedNewValue, "new text")
    }
}
