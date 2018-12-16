# Specific Patterns

This document describes a few patterns that emerged from usage.

In general, SwiftObserver meets almost all needs for callbacks and continuous propagation of data up the control hierarchy (against the direction of control). Typical applications are the propagation of data from domain model to use cases, from use cases to view models, from view models to views, and from views to view controllers.

## Messenger

### The Messenger Pattern

When observer and observable need to be more decoupled, it is common to use a mediating observable through which any object can anonymously send updates. An example of this mediator is `Foundation`'s `NotificationCenter`.

This extension of the *Observer Pattern* is sometimes called *Messenger*, *Notifier*, *Dispatcher*, *Event Emitter* or *Decoupler*. Its main differences to direct observation are:

- An observer may indirectly observe multiple other objects.
- Observers don't care who triggered an update.
- Observer types don't need to depend on the types that trigger updates.
- Updates function more as messages (notifications, events) than as artifacts of raw data.
- Every object can trigger updates, without adopting any protocol.
- Multiple objects may share the same update type and trigger the same updates.

### A Simple Messenger Implementation

You could use a mapped `Variable` as a mediating messenger:

~~~swift
let textMessenger = Var("").new()

observer.observe(textMessenger) { message in
    // respond to text message
}
    
textMessenger.send("text message")
~~~

This sort of implementation doesn't duplicate messages. If you want `latestUpdate` to return the last message that was sent, for instance for combined observations, you'd have to store messages in the source `Var` instead of just sending them. The latest message is then available through `source` and `latestUpdate`:

~~~swift
textMessenger.source <- "some message" // sends the message
let latestMessage = textMessenger.latestUpdate // or: textMessenger.source.value
~~~

### The Messenger Class

You can also use `Messenger`, which offers some advantages over a simple `Var("").new()`:

1. The intended use of the object is explicit
2. All sent messages become `latestUpdate` (also guaranteeing that `send()` resends the last sent message)
3. You have the option to deactivate update buffering via `remembersLatestMessage = false`
4. You can reset the latest update without triggering a send. In particular, optional update types allow to erase the buffered update: `latestMessage = nil`.
5. The message type doesn't need to be `Codable`

~~~swift
let textMessenger = Messenger("")

observer.observe(textMessenger) { message in
    // respond to message
}
        
textMessenger.send("my text message")
let lastMessage = textMessenger.latestUpdate // "my text message"
~~~

No matter how you implement your messenger, you may use `select` to observe (subscribe to-) one specific message:

~~~swift
observer.observe(textMessenger).select("my event") {
    // respond to "my event"
}
~~~


## Owned Messenger

An *Owned Messenger* is a helpful, and sometimes necessary, alternative to `CustomObservable`.

Instead of making a class `C` directly observable through `CustomObservable`, you just give it a messenger as a property. `C` sends its updates via its messenger, and observers of `C` actually observe the messenger of `C`:

~~~swift
class C {
   let messenger = Messenger<Event?>() // C is indirectly observable
}
~~~

And why would you want that? An plain old *Owned Messenger* is necessary in three scenarios ...

### 1. Require Specific Observability in an Interface

We want to declare a variable or constant as conforming to an interface (let's say `Database`) specifying (among other functionality) observability with a specific update type (say `DatabaseUpdate`).

#### Challenge

We don't want to define an abstract base class because objects conforming to the interface should be able to derive from their own (and more meaningful) class (like `ICloudDatabase`).

Now, we would want to define a protocol like this:

~~~swift
protocol Database: CustomObservable where UpdateType == DatabaseUpdate {
   // declare other database functionality
}
~~~

But this protocol could only be used as a generic constraint because it has an associated type requirement (Swift doesn't have generalized existentials yet).

We can't declare a variable or constant of the protocol type `Database`, like we are used to with delegate protocols:

~~~swift
weak var delegate: MyDelegateProtocol
// ^^ perfectly fine

var database: Database
// ^^ compiler error: Protocol 'Database' can only be used as a generic constraint because it has Self or associated type requirements
~~~

#### Solution

We use a `Database` protocol but without any conformance to `CustomObservable`. Instead, we only require the `Database` to have a messenger:

~~~swift
protocol Database {
   var messenger: Messenger<DatabaseUpdate?> { get }
   // declare other database functionality
}
~~~

Now, in contrast to a `CustomObservable`, we must manually route all observation of the database through its messenger, but at least it works.

### 2. Observe Apple Classes that Can't be Referenced Weakly

There are a number of classes from Apple's frameworks that [cannot be referenced weakly](https://developer.apple.com/library/archive/releasenotes/ObjectiveC/RN-TransitioningToARC/Introduction/Introduction.html#//apple_ref/doc/uid/TP40011226-CH1-SW17). Among them are `NSMenuView`, `NSFont` and `NSTextView`.

When we create a custom `NSTextView` and try to observe it, we get a runtime error:

~~~swift
class MyTextView: NSTextView: CustomObservable {
   let messenger = Messenger(TextEvent.none)
   typealias UpdateType = TextEvent
}

let textView = MyTextView()

observe(textView) { textEvent in
   // process event
}

// the error reads:
// objc[89748]: Cannot form weak reference to instance (0x600000c8a5e0) of class NSTextView. It is possible that this object was over-released, or is in the process of deallocation.
~~~

So, once again, we use an owned messenger but without direct conformance to `CustomObservable`:

~~~swift
class MyTextView: NSTextView {
   let messenger = Messenger(TextEvent.none)
}

let textView = MyTextView()

observe(textView.messenger) { textEvent in
   // process text event
}
~~~

### 3. Inherit and Extend Observability

Consider this case: I have a generic class `Tree`. It is a `CustomObservable`, so tree nodes can observe their branches. Then I have an `Item` which derives from `Tree`. `Item` cannot extend or override the `Tree.UpdateType`.

In order to further specify what items can send to their observers, the `Tree` must has to use its messenger without direct conformance to `CustomObservable`. This tree messenger should (somewhat redundantly) be named after its class: `treeMessenger`, so that there's no confusion in inheriting classes about which ancestor owns the messenger.