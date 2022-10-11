#if canImport(Combine)

import Combine
import SwiftObserver

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ObservableCache {
    
    /**
     Create a `Publisher` that publishes all messages sent by this `ObservableCache`
     */
    func publisher() -> PublisherOnObservableCache<Self> { .init(self) }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public class PublisherOnObservableCache<O: ObservableCache>: Publisher, Observer {
    
    init(_ observable: O) {
        self.observable = observable
        publisher = .init(observable.latestMessage)
        observe(observable, receive: publisher.send)
    }
    
    public let receiver = Receiver()
    private let observable: O
    
    public func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
        publisher.receive(subscriber: subscriber)
    }
    
    private let publisher: CurrentValueSubject<Output, Failure>
    
    public typealias Output = O.Message
    public typealias Failure = Never
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension SwiftObserver.ObservableObject {
    
    /**
     Create a `Publisher` that publishes all messages sent by this `ObservableObject`
     */
    func publisher() -> PublisherOnObservable<Self> { .init(self) }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public class PublisherOnObservable<O: SwiftObserver.ObservableObject>: Publisher, Observer {
    
    init(_ observable: O) {
        self.observable = observable
        observe(observable, receive: publisher.send)
    }
    
    public let receiver = Receiver()
    private let observable: O
    
    public func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
        publisher.receive(subscriber: subscriber)
    }
    
    private let publisher = PassthroughSubject<Output, Failure>()
    
    public typealias Output = O.Message
    public typealias Failure = Never
}

#endif
