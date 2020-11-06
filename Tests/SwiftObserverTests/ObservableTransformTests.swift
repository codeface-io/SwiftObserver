import XCTest
@testable import SwiftObserver
import SwiftyToolz

class ObservableTransformTests: XCTestCase, LogObserver
{
    static override func setUp()
    {
        super.setUp()
        Log.shared.minimumLevel = .error
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
        Log.shared.add(observer: self)
        let alreadyACache = Var<Int?>()
        let expectedWarning = alreadyACache.warningWhenApplyingCache(messageIsOptional: false)
        _ = alreadyACache.cache()
        XCTAssert(latestLogEntry?.message.contains(expectedWarning) ?? false)
        Log.shared.remove(observer: self)
    }
    
    func testLogWarningWhenApplyingCacheToCacheWithOptionalMessage()
    {
        Log.shared.add(observer: self)
        latestLogEntry = nil
        let alreadyACache = Messenger<Int>().cache()
        XCTAssertNil(latestLogEntry)
        let expectedWarning = alreadyACache.warningWhenApplyingCache(messageIsOptional: true)
        _ = alreadyACache.cache()
        XCTAssert(latestLogEntry?.message.contains(expectedWarning) ?? false)
        Log.shared.remove(observer: self)
    }
    
    func testReplacingOriginOfTransform()
    {
        let original = Var<Int?>(1)
        
        let transform = original.new().unwrap().map { "\($0)" }
        
        let observer = FreeObserver()
        
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
    
    func receive(_ entry: Log.Entry) { latestLogEntry = entry }
    private var latestLogEntry: Log.Entry?
}
