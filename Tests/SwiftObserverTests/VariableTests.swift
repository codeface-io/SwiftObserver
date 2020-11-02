import XCTest
@testable import SwiftObserver

class VariableTests: XCTestCase
{
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
        
        let observer = TestObserver()
        
        observer.observe(text)
        {
            XCTAssertEqual($0.new, "text")
            
            didUpdate = true
        }
        
        text <- "text"
        
        XCTAssertEqual(text.value, "text")
        XCTAssert(didUpdate)
    }
}
