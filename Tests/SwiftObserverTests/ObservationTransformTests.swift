import XCTest
import SwiftObserver

class ObservationTransformTests: XCTestCase
{
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
    
    let controller = TestObserver()
    
    class TestObserver: Observer
    {
        let receiver = Receiver()
    }
}
