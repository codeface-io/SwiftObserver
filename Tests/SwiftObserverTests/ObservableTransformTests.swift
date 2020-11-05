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
    
    func receive(_ entry: Log.Entry) { latestLogEntry = entry }
    private var latestLogEntry: Log.Entry?
}
