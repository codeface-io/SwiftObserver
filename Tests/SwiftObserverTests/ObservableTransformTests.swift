import XCTest
@testable import SwiftObserver

class ObservableTransformTests: XCTestCase
{
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
}
