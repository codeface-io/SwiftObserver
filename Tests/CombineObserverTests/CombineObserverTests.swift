import XCTest
import CombineObserver
import SwiftObserver
import SwiftyToolz

@available(iOS 13.0, tvOS 13.0, *)
class CombineObserverTests: XCTestCase
{
    func testCreatingAndSubscribingToPublisher()
    {
        @Observable var number = 7
        let numberPublisher = $number.publisher()
        
        var receivedNumbers = [Int]()
        
        let cancellable = numberPublisher.sink { receivedNumbers += $0.new }
        XCTAssertEqual(receivedNumbers, [7])
        
        number = 42
        XCTAssertEqual(receivedNumbers, [7, 42])
        
        cancellable.cancel() // just to avoid warning
    }
    
    func testUsingDropFirstOnPublisher()
    {
        @Observable var number = 7
        let numberPublisher = $number.publisher()
        
        var receivedNumbers = [Int]()
        
        let cancellable = numberPublisher.dropFirst().sink { receivedNumbers += $0.new }
        XCTAssertEqual(receivedNumbers, [])
        
        number = 42
        XCTAssertEqual(receivedNumbers, [42])
        
        cancellable.cancel() // just to avoid warning
    }
    
    func testCreatingPublisherOnUncachedObservable()
    {
        @Observable var number = 200
        let numberFilter = $number.new().filter { $0 > 100 }
        let filterPublisher = numberFilter.publisher()
        
        var receivedNumbers = [Int]()
        
        let cancellable = filterPublisher.sink { receivedNumbers += $0 }
        XCTAssertEqual(receivedNumbers, [])
        
        number = 300
        XCTAssertEqual(receivedNumbers, [300])
        
        cancellable.cancel() // just to avoid warning
    }
}
