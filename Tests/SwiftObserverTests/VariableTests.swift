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
    
    func testStringVariableStringAccess()
    {
        let text = Var("1234567")
        
        XCTAssertEqual(text.count, 7)
        XCTAssertEqual(text[text.startIndex], "1")
        XCTAssertEqual(text.string, text.value)
        XCTAssertEqual(text.description, text.value.description)
        XCTAssertEqual(text.debugDescription, text.value.debugDescription)
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
}
