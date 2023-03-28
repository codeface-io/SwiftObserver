import XCTest
@testable import SwiftObserver
import SwiftyToolz

class ObservableTransformTests: XCTestCase
{
    override func setUp()
    {
        super.setUp()
        Log.shared.minimumPrintLevel = .error
        
        Log.shared.add(observer: self)
        {
            self.latestLogEntry = $0
        }
    }
    
    func testCacheLatestMessageIsOptionalOnObservableWithOptionalMessage()
    {
        let cache = Messenger<Int?>().cache()
        XCTAssert(type(of: cache.latestMessage) == Int?.self)
    }
    
    func testCacheLatestMessageIsOptionalOnObservableWithNonOptionalMessage()
    {
        let cache = Messenger<Int>().cache()
        XCTAssert(type(of: cache.latestMessage) == Int?.self)
    }
    
    func testLogWarningWhenApplyingCacheToCacheWithNonOptionalMessage()
    {
        let alreadyACache = Var<Int?>()
        let expectedWarning = alreadyACache.warningWhenApplyingCache(messageIsOptional: false)
        _ = alreadyACache.cache()
        XCTAssert(latestLogEntry?.message.contains(expectedWarning) ?? false)
    }
    
    func testLogWarningWhenApplyingCacheToCacheWithOptionalMessage()
    {
        latestLogEntry = nil
        let alreadyACache = Messenger<Int>().cache()
        XCTAssertNil(latestLogEntry)
        let expectedWarning = alreadyACache.warningWhenApplyingCache(messageIsOptional: true)
        _ = alreadyACache.cache()
        XCTAssert(latestLogEntry?.message.contains(expectedWarning) ?? false)
    }
    
    func testReplacingOriginOfTransform()
    {
        let original = Var<Int?>(1)
        
        let transform = original.new().unwrap().map { "\($0)" }
        
        let observer = TestObserver()
        
        var lastUpdateFromOriginal: Update<Int?>?
        
        observer.observe(original)
        {
            lastUpdateFromOriginal = $0
        }
        
        var lastUpdateFromTransform: String?
        
        observer.observe(transform)
        {
            lastUpdateFromTransform = $0
        }
        
        XCTAssertNil(lastUpdateFromOriginal)
        XCTAssertNil(lastUpdateFromTransform)
        
        original.send()
        
        XCTAssertEqual(lastUpdateFromOriginal?.new, 1)
        XCTAssertEqual(lastUpdateFromTransform, "1")
        
        lastUpdateFromOriginal = nil
        lastUpdateFromTransform = nil
        
        let replacement = Var<Int?>(42)
        transform.origin.origin.origin = replacement
        
        XCTAssertNil(lastUpdateFromOriginal)
        XCTAssertNil(lastUpdateFromTransform)
        
        original.send()
        
        XCTAssertEqual(lastUpdateFromOriginal?.new, 1)
        XCTAssertNil(lastUpdateFromTransform)
        
        replacement.send()
        
        XCTAssertEqual(lastUpdateFromTransform, "42")
    }
    
    func testThatMappersOfCachesAreCaches()
    {
        XCTAssertEqual(Var(1).new().latestMessage, 1)
        XCTAssertEqual(Var<Int?>().new().unwrap(23).latestMessage, 23)
        XCTAssertEqual(Var(5).map({ $0.new == 5 }).latestMessage, true)
    }
    
    func testMappingSelect()
    {
        let text = Var<String?>()
        let textMapping = text.new().unwrap("").select("test")
        
        var didFire = false
        
        let observer = TestObserver()
        
        observer.observe(textMapping)
        {
            didFire = true
        }
        
        text <- "test"
        XCTAssert(didFire)
        
        didFire = false
        text <- "test2"
        XCTAssert(!didFire)
    }
    
    func testMappingsIncludingFilter()
    {
        let number = Var<Int?>(99)
        let doubleDigits = number.new().unwrap(0).filter { $0 > 9 }
        
        var observedNumbers = [Int]()
        
        let observer = TestObserver()
        
        observer.observe(doubleDigits)
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
        
        let observer = TestObserver()
        
        observer.observe(transform)
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
        
        let observer = TestObserver()
        
        observer.observe(textMessenger)
        {
            receivedMessage = $0
        }
        
        textMessenger.send(expectedMessage)
        
        XCTAssertEqual(receivedMessage, expectedMessage)
    }
    
    func testObservableMapObject()
    {
        let text = Var<String?>()
        
        let nonOptionalText = text.map { $0.new ?? "" }
        
        var didUpdate = false
        
        let observer = TestObserver()
        
        observer.observe(nonOptionalText)
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
        
        let observer = TestObserver()
        
        observer.observe(unwrappedText)
        {
            XCTAssertEqual($0, "")
            didUpdate = true
        }
        
        text.send()
        
        XCTAssert(didUpdate)
    }
    
    func testWeakObservableWrapper()
    {
        let weakNumber1 = Var(1).weak()
        XCTAssertNil(weakNumber1.origin)
        
        let strongNumber = Var(2)
        let weakNumber2 = strongNumber.weak()
        XCTAssertEqual(weakNumber2.origin?.value, 2)
    }
    
    func testWeakObservable()
    {
        var strongObservable: Var<Int>? = Var(10)
        
        let weakObservable = strongObservable!.weak()
        
        XCTAssert(strongObservable === weakObservable.origin)
        
        strongObservable = nil
        
        XCTAssertNil(weakObservable.origin)
    }
    
    func receive(_ entry: Log.Entry) { latestLogEntry = entry }
    private var latestLogEntry: Log.Entry?
    
    class TestObserver: Observer
    {
        let receiver = Receiver()
    }
}
