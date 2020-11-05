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
    
    func testBufferLatestMessageIsOptionalOnObservableWithOptionalMessage()
    {
        let buffer = Messenger<Int?>().buffer()
        XCTAssert(type(of: buffer.latestMessage) == Int?.self)
    }
    
    func testBufferLatestMessageIsOptionalOnObservableWithNonOptionalMessage()
    {
        let buffer = Messenger<Int>().buffer()
        XCTAssert(type(of: buffer.latestMessage) == Int?.self)
    }
    
    func testLogWarningWhenApplyingBufferToBufferWithNonOptionalMessage()
    {
        Log.shared.add(observer: self)
        let alreadyBuffered = Var<Int?>()
        let expectedWarning = alreadyBuffered.warningWhenApplyingBuffer(messageIsOptional: false)
        _ = alreadyBuffered.buffer()
        XCTAssert(latestLogEntry?.message.contains(expectedWarning) ?? false)
        Log.shared.remove(observer: self)
    }
    
    func testLogWarningWhenApplyingBufferToBufferWithOptionalMessage()
    {
        Log.shared.add(observer: self)
        latestLogEntry = nil
        let alreadyBuffered = Messenger<Int>().buffer()
        XCTAssertNil(latestLogEntry)
        let expectedWarning = alreadyBuffered.warningWhenApplyingBuffer(messageIsOptional: true)
        _ = alreadyBuffered.buffer()
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
