import XCTest
import CombineObserver
import SwiftObserver
import SwiftyToolz

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
