![SwiftObserver](https://raw.githubusercontent.com/flowtoolz/SwiftObserver/master/Documentation/swift.jpg)

# [v6.0.0-beta]

This is the branch for the next major update. Overall, SwiftObserver becomes more powerful, consistent, simple, performant and safe.

The documentation here does **not** yet cover all commited changes and their implications. 

Here's a preliminary list of changes:

* Memory management is completely new:
  * Before 6.0, memory leaks were *technically* impossible, because SwiftObserver still had a handle on dead observers, and you could flush them out when you wanted "to be sure". Now, dead observations are actually impossible and you don't need to worry about them.
  * Observers now automatically clean up when they die, so a call of `stopObserving()` in deinit can now be omitted. Observers can still call `stopObserving(observable)` and `stopObserving()` if they want to manually end observations.
  * `Observer` now has one protocol requirement, which is typically implemented as `let connections = Connections()`. The `connections` object keeps the `Observer`s observations alive.
  * A few memory management functions were removed since they were overkill and are definitely unnecessary now.
  * The new design scales better and should be more performant with ginormous amounts of observers and observables.
* The `Observable` protocol has become simpler.
  * The requirement `var latestMessage: Message {get}` is gone.
  * No more message duplication in messengers since the `latestMessage` requirement is limited to `BufferedObservable`s. And so, switching buffering on or off on messengers is also no more concern.
  * Message buffering now happens exactly whenever it is really possible, that is whenever the observable is backed by an actual value (like variables are) and there is no filter involved in the observable. Filters annihilate random access pulling. The weirdness of a mapping having to ignore its filter in its implementation of `latestMessage` is gone.
  * `Observable` just requires one `Messenger`.
  * All observables are now implemented the same way and are thereby on equal footing. You could now easily reimplement `Var` and benefit from the order maintaining message queue of `Messenger`.
* Custom observables are simpler to implement:
  * The protocol is the familiar `Observable`. No more separate `CustomObservable`.
  * The `typealias Message = MyMessageType` can now be omitted.
  * The need to use optional message types to be able to implement `latestMessage` is gone.
* Observers can optionally receive the author of a message via an alternative closure wherever they normally pass in a message handler, even in combined observations. And observables can optionally attach an author other than themselves to a message, if they want to.
  * This major addition breaks no existing code and the author argument is only present when declared in the observer's message handler or the observable's `send` function.
  * This is hugely beneficial when observing shared mutable states like the repository / store pattern, really any storage abstraction, classic messengers (notifiers) and more.
  * Most importantly, an observer can now ignore messages that he himself triggered, even when the trigger was indirect. This avoids redundant and unintended reactions.
* The internals are better implemented and more readable.
  * No forced unwraps for the unwrap transforms
  * No weird function and filter compositions
  * No more unnecessary indirection and redundance in adhoc observation transforms
  * Former "Mappings" are now separated into the three simple composable transforms: map, filter and unwrap.
  * The number of lines has actually decreased from about 1250 to about 1050.
  * The `ObservableObject` base class is gone.
* Other consistency improvements and features:
  * An observer can now check whether it is observing an observable via `observer.isObserving(observable)`.
  * Stand-alone and ad hoc transforms now also include an `unwrap()` transform that requires no default message.
  * Message order is maintained for all observables, not just for variables. All observables use a message queue now.
  * The source of transforms cannot be reset as it was the case for mappings. As a nice side effect, the question whether a mapping fires when its source is reset is no concern anymore.
  * `Change<Value>` is more appropriately named `Update<Value>` since its properties `old` and `new` can be equal.
  * `Update` is `Equatable` when its `Value` is `Equatable`, so messages of variables can be selected via `select(Update(specificOldValue, specificNewValue))` or any specific value update you define.
  * The issue that certain Apple classes (like NSTextView) cannot directly be `Observable` because they can't be referenced weakly is gone. SwiftObserver now only references an `Observable`'s `messenger` weakly.

# SwiftObserver

[![badge-pod]](http://cocoapods.org/pods/SwiftObserver) ![badge-pms] ![badge-languages] [![badge-gitter]](https://gitter.im/flowtoolz/SwiftObserver?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge) ![badge-platforms] ![badge-mit]

SwiftObserver is a lightweight framework for reactive Swift. Its design goals make it easy to learn and a joy to use:

1. [**Meaningful Code**](https://github.com/flowtoolz/SwiftObserver/blob/master/Documentation/philosophy.md#meaningful-code) 💡<br>SwiftObserver promotes meaningful metaphors, names and syntax, producing highly readable code.
2. [**Non-intrusive Design**](https://github.com/flowtoolz/SwiftObserver/blob/master/Documentation/philosophy.md#non-intrusive-design) ✊🏻<br>SwiftObserver doesn't limit or modulate your design. It just makes it easy to do the right thing.
3. [**Simplicity**](https://github.com/flowtoolz/SwiftObserver/blob/master/Documentation/philosophy.md#simplicity-and-flexibility) 🕹<br>SwiftObserver employs few radically simple concepts and applies them consistently without exceptions.
4. [**Flexibility**](https://github.com/flowtoolz/SwiftObserver/blob/master/Documentation/philosophy.md#simplicity-and-flexibility) 🤸🏻‍♀️<br>SwiftObserver's types are simple but universal and composable, making them applicable in many situations.
5. [**Safety**](https://github.com/flowtoolz/SwiftObserver/blob/master/Documentation/philosophy.md#safety) ⛑<br>SwiftObserver makes memory management meaningful and easy. Oh yeah, real memory leaks are impossible.

SwiftObserver is very few lines of production code, but it's also beyond a 1000 hours of work, thinking it through, letting go of fancy features, documenting it, [unit-testing it](https://github.com/flowtoolz/SwiftObserver/blob/master/Tests/SwiftObserverTests/SwiftObserverTests.swift), and battle-testing it [in practice](http://flowlistapp.com).

## Why the Hell Another Reactive Swift Framework?

[*Reactive Programming*](https://en.wikipedia.org/wiki/Reactive_programming) adresses the central challenge of implementing a clean architecture: [*Dependency Inversion*](https://en.wikipedia.org/wiki/Dependency_inversion_principle). SwiftObserver breaks *Reactive Programming* down to its essence, which is the [*Observer Pattern*](https://en.wikipedia.org/wiki/Observer_pattern). It diverges from convention as it doesn't inherit the metaphors, terms, types, or function- and operator arsenals of common reactive libraries. It's less fancy than SwiftRx and Combine and offers a powerful simplicity you will actually **love** to work with.

## Contents

* [Get Involved](#get-involved)
* [Get Started](#get-started)
    * [Install](#install)
    * [Introduction](#introduction)
* [Messengers](#messengers)
* [Custom Observables](#custom-observables)
* [Variables](#variables)
    * [Observe Variables](#observe-variables)
    * [Use Variable Values](#use-variable-values) 
    * [Encode and Decode Variables](#encode-and-decode-variables)
* [Transforms](#transforms)
    * [Make Transforms Observable](#make-transforms-observable)
    * [Use Prebuilt Transforms](#use-prebuilt-transforms)
    * [Chain Transforms](#chain-transforms)
* [Advanced Observables](#advanced-observables)
    * [Message Buffering](#message-buffering)
    * [State Changes](#state-changes)
    * [Weak Reference](#weak-reference)
* [More](#more)

# Get Involved

* Found a **bug**? Create a [github issue](https://github.com/flowtoolz/SwiftObserver/issues/new/choose).
* Need a **feature**? Create a [github issue](https://github.com/flowtoolz/SwiftObserver/issues/new/choose).
* Want to **improve** stuff? Create a [pull request](https://github.com/flowtoolz/SwiftObserver/pulls).
* Want to start a **discussion**? Visit [Gitter](https://gitter.im/flowtoolz/SwiftObserver/).
* Need **support** and troubleshooting? Write at <swiftobserver@flowtoolz.com>.
* Want to **contact** us? Write at <swiftobserver@flowtoolz.com>.

# Get Started

## Install

With [**Carthage**](https://github.com/Carthage/Carthage), add this line to your [Cartfile](https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md#cartfile):

```
github "flowtoolz/SwiftObserver" ~> 6.0
```

Then follow [these instructions](https://github.com/Carthage/Carthage#adding-frameworks-to-an-application) and run `$ carthage update --platform ios`.

With [**Cocoapods**](https://cocoapods.org), adjust your [Podfile](https://guides.cocoapods.org/syntax/podfile.html):

```ruby
use_frameworks!

target "MyAppTarget" do
  pod "SwiftObserver", "~> 6.0"
end
```

Then run `$ pod install`.

With the [**Swift Package Manager**](https://github.com/apple/swift-package-manager/tree/master/Documentation#swift-package-manager), adjust your [Package.swift](https://github.com/apple/swift-package-manager/blob/master/Documentation/Usage.md#create-a-package) file:

~~~swift
// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "SPMExample",
    dependencies: [
        .package(url: "https://github.com/flowtoolz/SwiftObserver.git",
                 .upToNextMajor(from: "6.0.0"))
    ],
    targets: [
        .target(name: "SPMExample",
                dependencies: ["SwiftObserver"])
    ],
    swiftLanguageVersions: [.v5]
)
~~~

Then run `$ swift build` or `$ swift run`.

Finally, in your **Swift** files:

```swift
import SwiftObserver
```

## Introduction

> No need to learn a bunch of arbitrary metaphors, terms or types.<br>SwiftObserver is simple: **Objects observe other objects**.

Or a tad more technically: Observed objects send *messages* to their *observers*. 

That's it. Just readable code:

~~~swift
dog.observe(Sky.shared) { color in
    // marvel at the sky changing its color
}
~~~

### Observers

Any class can become an `Observer` by owning a `Receiver`:

```swift
class Dog: Observer {
    let receiver = Receiver()
}
```

The receiver keeps the observer's observations alive. The observer just holds the receiver strongly and doesn't do anything else with it.

<a id="combined-observations"></a> An  `Observer` may start up to three observations with one combined call:

```swift
dog.observe(tv, bowl, doorbell) { image, food, sound in
    // either the tv's going, I got some food, or the bell rang
}
```

For any message handling closure to be called, the observer must still be alive. There's no awareness after death in memory.

### Observables

Observable objects conform to `Observable`. There are four ways to make these *observables*:

1. Create a [*messenger*](#messengers). It's a minimal `Observable` through which other objects communicate.
2. Implement a [custom](#custom-observables) `Observable` by conforming to `Observable`.
3. Create a [*variable*](#variables). It's an `Observable` that holds a value and sends value updates.
4. Create a [*transform*](#transforms). It's an `Observable` that wraps and transforms a *source observable*.

Just starting to observe an `Observable` does **not** trigger a *message*. This keeps it simple, predictable and consistent, in particular in combination with [*transforms*](#transforms). However, you can make any `Observable` send any message at any time via `observable.send(message)`.

### Memory Management

When observers or observables die, SwiftObserver cleans up the involved observations automatically, and memory leaks are impossible. So there isn't really any memory management to worry about.

But observers can stop particular or all their observations:

```swift
dog.stopObserving(Sky.shared) // no more messages from the sky
dog.stopObserving() // no more messages at all
```

# Messengers

`Messenger` is the simplest `Observable` and the basis of any other `Observable`. It doesn't send messages by itself but anyone can send messages through it, and use it for any type of message:

```swift
let messenger = Messenger<String>()
observer.observe(messenger) { message in
    // respond to message
}
messenger.send("my message")
```

`Observable` is actually defined by having a `Messenger`:

```swift
public protocol Observable: class {
    var messenger: Messenger<Message> { get }
    associatedtype Message: Any
}
```

 `Messenger` is itself `Observable` because it points to itself as the required `Messenger`:

```swift
extension Messenger: Observable {
    public var messenger: Messenger<Message> { self }
}
```

A messenger delivers messages in exactly the order in which they were sent, even when observers make it send further messages from their message handling closures. Since `Observable` is defined in terms of `Messenger`, all observables keep that message order as well.

The `Messenger` class embodies the common [messenger / notifier pattern](Documentation/specific-patterns.md#the-messenger-pattern) and can be used for that out of the box. 

# Custom Observables

Every class can become `Observable` simply by owning a `messenger: Messenger<Message>`:

~~~swift
class MinimalObservable: Observable {
    let messenger = Messenger<String>()
}
~~~

The `Message` type is custom and yet well defined. An `Observable` sends whatever it likes whenever it wants via `send(_ message: Message)`. Enumerations often make good `Message` types for custom observables:

~~~swift
class Model: Observable {
    foo() { send(.willUpdate) }
    bar() { send(.didUpdate) }
    deinit { send(.willDie) }
    let messenger = Messenger<Event>()
    enum Event { case willUpdate, didUpdate, willDie }
}
~~~

# Variables

 `Var<Value>` is an `Observable` that has a property `value: Value`. 

## Observe Variables

Whenever its `value` changes, `Var<Value>` sends a *message* of type `Update<Value>`, informing about the `old` and `new` value:

~~~swift
observer.observe(variable) { update in
    let whatsTheBigDifference = update.new - update.old
}
~~~

In addition, you can always manually call `variable.send()` (without argument) to send an update in which `old` and `new` both hold the current `value` (see [`BufferedObservable`](#message-buffering)).

## Use Variable Values

`Value` must be `Equatable`, and based on its `value` the whole `Var<Value>` is `Equatable`.  If `Value` is `Comparable`, `Var<Value>` will also be `Comparable`.

You can set `value` via initializer, directly and via the `<-` operator:

~~~swift
let text = Var<String?>()    // text.value == nil
text.value = "a text"
let number = Var(23)         // number.value == 23
number <- 42                 // number.value == 42
~~~

### Number Values

If you use some number type `Number` that is either an `Int`, `Float` or `Double`:

1. Every `Var<Number>`, `Var<Number?>`, `Var<Number>?` and `Var<Number?>?` has a respective property `var int: Int`, `var float: Float` or `var double: Double`. That property is non-optional and interprets `nil` values as zero.

2. You can apply numeric operators `+`, `-`, `*` and `/` to all pairs of `Number`, `Number?`, `Var<Number>`, `Var<Number?>`, `Var<Number>?` and `Var<Number?>?`.

```swift
let numVar = Var<Int?>()     // numVar.value == nil
print(numVar.int)            // 0
numVar.int += 5              // numVar.value == 5
numVar <- Var(1) + 2         // numVar.value == 3
```

### String Values

1. Every `Var<String>`, `Var<String?>`, `Var<String>?` and `Var<String?>?` has a property `var string: String`. That property is non-optional and interprets `nil` values as `""`.
3. You can apply concatenation operator `+` to all pairs of `String`, `String?`, `Var<String>`, `Var<String?>`, `Var<String>?` and `Var<String?>?`.
3. Representing its `string` property, every `Var<String>` and `Var<String?>` conforms to `TextOutputStream`, `BidirectionalCollection`, `Collection`, `Sequence`, `CustomDebugStringConvertible` and `CustomStringConvertible`.

## Encode and Decode Variables

Every `Var<Value>` is `Codable` and requires its `Value` to be `Codable`. So when one of your types has `Var` properties, you can still easily make that type `Codable` by simply adopting the `Codable` protocol:

~~~swift
class Model: Codable {
    private(set) var text = Var("String Variable")
}
~~~

Note that `text` is a `var` instead of a `let`. It cannot be constant because Swift's implicit decoder must mutate it. However, clients of `Model` would be supposed to set only `text.value` and not `text` itself, so the setter is private.

# Transforms

Transforms make common steps of message processing more succinct and readable. They allow to filter, map, unwrap and select messages based on the messages themselves and based on their author. You may freely chain these transforms together and also define new ones with them.

This example transforms messages of type `Update<String?>` into ones of type `Int`:

```swift
let title = Var<String?>()
observer.observe(title).new().unwrap("Untitled").map({ $0.count }) { titleLength in
    // do something with the new title length
}
```

## Make Transforms Observable

You may transform a particular observation directly on the fly, like in the above example. Such ad hoc transforms give the observer lots of flexibility.

Or you may instantiate a new `Observable` that has the transform chain baked into it. The above example could then look like this:

```swift
let title = Var<String?>()
let titleLength = title.new().unwrap("Untitled").map { $0.count }
observer.observe(titleLength) { titleLength in
    // do something with the new title length
}
```

These stand-alone transforms allow multiple observers to receive the same preprocessing. But since they are distinct `Observable` objects, the scope in which their observation should last must hold them strongly. Holding transforms as dedicated observable objects suits entities like view models that represent transformations of other data.

## Use Prebuilt Transforms

No matter whether you apply transforms ad hoc or as stand-alone objects, they work the same way. The following list of available transforms shows them as observable objects, so we can skip most message handlers.

### Map

Map is your regular familiar `map` function. It transforms messages and often also their type:

```swift
let messenger = Messenger<String>()          // sends String
let stringToInt = messenger.map { Int($0) }  // sends Int?
```

### New

When an `Observable` like a `Var<Value>` sends *messages* of type `Update<Value>`, we often only care about  the `new` value of that update, so we map with `new()`:

~~~swift
let errorCode = Var<Int>()          // sends Update<Int>
let newErrorCode = errorCode.new()  // sends Int
~~~

### Filter

When you want to receive only certain messages, use `filter`:

```swift
let messenger = Messenger<String>()                     // sends String
let shortMessages = messenger.filter { $0.count < 10 }  // sends String if length < 10
```

### Select

Use `select` to receive only one specific *message*. `select` works wherever messages are `Equatable`. Because `select` maps messages onto `Void`, the receiving closure takes no argument:

```swift
let messenger = Messenger<String>()                   // sends String
let myNotifier = messenger.select("my notification")  // sends Void
observer.observe(myNotifier) {                        // no argument
    // someone sent "my notification"
}
```

### Unwrap

Sometimes, we make *message* types optional, for example when there is no meaningful initial value for a `Var`. But we often don't want to deal with optionals down the line. So we use `unwrap()`, supressing `nil` messages entirely:

~~~swift
let errorCodes = Messenger<Int?>()     // sends Int?       
let errorAlert = errorCodes.unwrap()   // sends Int if message is not nil
~~~

### Unwrap with Default

You may also unwrap optional messages by replacing all `nil` values with a default:

~~~swift
let points = Messenger<Int?>()         // sends Int?       
let pointsToShow = points.unwrap(0)    // sends Int with 0 for nil
~~~

### Filter Author

Filter authors the same way you filter messages:

```swift
let messenger = Messenger<String>()            // sends String
let friendMessages = messenger.filterAuthor {  // sends String if message is from friend
    friends.contains($0)
} 
```

### From

If only one author is of interest, filter authors with `from`:

```swift
let messenger = Messenger<String>()     // sends String
let joesMessages = messenger.from(joe)  // sends String if message is from joe
```

### Not From

```swift
let posts = Messenger<String>()        // sends String
let unreadPosts = posts.notFrom(self)  // sends String if message is from others
```

This last one is particularly useful when multiple objects observe and change shared data. The observers would only want to be informed about data changes that other observers made, so they would identify themselves as change authors when they change the data, and they would exclude themselves as authors when they observe the data.

## Chain Transforms

You may chain transforms together:

```swift
let numbers = Messenger<Int>()

observer.observe(numbers).map {
    "\($0)"                      // Int -> String
}.filter {
    $0.count > 1                 // filter out single digit integers
}.map {
    Int.init($0)                 // String -> Int?
}.unwrap {                       // Int? -> Int
    print($0)                    // receive resulting Int
}
```

Of course, ad hoc transforms like the above end on the actual message handling closure. Now, when the last transform in the chain also takes a closure argument for its processing, like `map` and `filter` do, we use `receive` to stick with the nice syntax of [trailing closures](https://docs.swift.org/swift-book/LanguageGuide/Closures.html#ID102):

~~~swift
dog.observe(Sky.shared).map {
    $0 == .blue     
}.receive {
    print("Will we go outside? \($0 ? "Yes" : "No")!")
} 
~~~

# Advanced Observables

## Message Buffering

A `BufferedObservable` is an `Observable` that also has a property `latestMessage: Message` which typically returns the last sent *message* or one that indicates that nothing has changed. That `latestMessage` is mostly required for combined observations like `observer.observe(o1, o2, o3) { m1, m2, m3 in /* ... */ }`. When one of the combined observables sends a message, the combined observation must **pull** messages from the other observables.

 There are three kinds of buffered observables:

1. Every *variable* is a `BufferedObservable`. Its `latestMessage` holds the current variable `value` in both properties of `Update`: `old` and `new`.
2. Every mapper whose mapped source observable is a `BufferedObservable` is itself a `BufferedObservable`. A buffered mapper just maps the `latestMessage` of its source. The ability of a chain of transformations to provide its `latestMessage` is only taken away by filters and the default-less unwrapper.
3. Custom implementations of `BufferedObservable`.

All `BufferedObservable`s can call `send()` without argument and, thereby, send the `latestMessage`.

## State Changes

To implement an `Observable` like `Var<Value>` that sends value updates, you would use the message type  `Update<Value>`. If you also want the observable to be suitable for combined observations, you make it a `BufferedObservable` and let `latestMessage` return a message based on the latest (current) value:

~~~swift
class Model: BufferedObservable {
    var latestMessage: Update<String> {
        Update(state, state)
    }
       
    var state: String = "" {
        didSet {
            if state != oldValue {
                send(Update(oldValue, state))
            }
        }
    }
        
    let messenger = Messenger<Update<String>>()
}
~~~

## Weak Reference

When you want to put an `Observable` into some data structure or as the *source* into a *transform* and hold it there as a `weak` reference, you may want to wrap it in `Weak<O: Observable>`:

~~~swift
let number = Var(12)
let weakNumber = Weak(number)

controller.observe(weakNumber) { message in
    // process message of type Update<Int>
}

var weakNumbers = [Weak<Var<Int>>]()
weakNumbers.append(weakNumber)
~~~

`Weak<O: Observable>` is itself an `Observable` and functions as a complete substitute for its wrapped `weak` `Observable`, which you can access via the `observable` property:

~~~swift
let numberIsAlive = weakNumber.observable != nil
let numberValue = weakNumber.observable?.value
~~~

`Weak` isn't buffered and doesn't duplicate any messages. It would be easy to implement a class `BufferedWeak` that wraps a `BufferedObservable` weakly. If you like to see that, maybe even just for consistency/completeness, let me know.

# More

* **Patterns:** Read more about some [patterns that emerged from using SwiftObserver](Documentation/specific-patterns.md#specific-patterns).
* **Philosophy:** Read more about the [philosophy and features of SwiftObserver](Documentation/philosophy.md#the-philosophy-of-swiftobserver).
* **Architecture:** Have a look at a [dependency diagram of the types of SwiftObserver](Documentation/architecture.md).
* **License:** SwiftObserver is released under the MIT license. [See LICENSE](LICENSE) for details.

[badge-gitter]: https://img.shields.io/badge/chat-Gitter-red.svg?style=flat-square

[badge-pod]: https://img.shields.io/cocoapods/v/SwiftObserver.svg?label=version&style=flat-square

[badge-pms]: https://img.shields.io/badge/supports-CocoaPods%20%7C%20Carthage%20%7C%20SPM-green.svg?style=flat-square
[badge-languages]: https://img.shields.io/badge/language-Swift-orange.svg?style=flat-square
[badge-platforms]: https://img.shields.io/badge/platforms-iOS%20%7C%20macOS%20%7C%20tvOS%20%7C%20watchOS%20%7C%20Linux-lightgrey.svg?style=flat-square
[badge-mit]: https://img.shields.io/badge/license-MIT-lightgrey.svg?style=flat-square
