![SwiftObserver](https://raw.githubusercontent.com/flowtoolz/SwiftObserver/master/Documentation/swift.jpg)

# SwiftObserver

[![badge-pod]](http://cocoapods.org/pods/SwiftObserver) ![badge-pms] ![badge-languages] [![badge-gitter]](https://gitter.im/flowtoolz/SwiftObserver?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge) ![badge-platforms] ![badge-mit]

SwiftObserver is a lightweight framework for reactive Swift. Its design goals make it easy to learn and a joy to use:

1. [**Meaningful Code**](https://github.com/flowtoolz/SwiftObserver/blob/master/Documentation/philosophy.md#meaningful-code):<br>SwiftObserver promotes meaningful metaphors, names and syntax, producing highly readable code.
2. [**Non-intrusive Design**](https://github.com/flowtoolz/SwiftObserver/blob/master/Documentation/philosophy.md#non-intrusive-design):<br>SwiftObserver doesn't limit or modulate your design. It just makes it easy to do the right thing.
3. [**Simplicity**](https://github.com/flowtoolz/SwiftObserver/blob/master/Documentation/philosophy.md#simplicity-and-flexibility):<br>SwiftObserver employs very few simple concepts and applies them consistently without exceptions.
4. [**Flexibility**](https://github.com/flowtoolz/SwiftObserver/blob/master/Documentation/philosophy.md#simplicity-and-flexibility):<br>SwiftObserver's types are simple but universal and composable, making them applicable in many situations.
5. [**Safety**](https://github.com/flowtoolz/SwiftObserver/blob/master/Documentation/philosophy.md#safety):<br>SwiftObserver makes memory management meaningful and easy. Oh yeah, real memory leaks are impossible.

[*Reactive Programming*](https://en.wikipedia.org/wiki/Reactive_programming) adresses the central challenge of implementing a clean architecture: [*Dependency Inversion*](https://en.wikipedia.org/wiki/Dependency_inversion_principle). SwiftObserver breaks *Reactive Programming* down to its essence, which is the [*Observer Pattern*](https://en.wikipedia.org/wiki/Observer_pattern).

SwiftObserver is just about 1200 lines of production code, but it also approaches a 1000 hours of work, thinking it through, letting go of fancy features, documenting it, [unit-testing it](https://github.com/flowtoolz/SwiftObserver/blob/master/Tests/SwiftObserverTests/SwiftObserverTests.swift), and battle-testing it [in practice](http://flowlistapp.com).

* [Get Involved](#get-involved)
* [Get Started](#get-started)
    * [Install](#install)
    * [Introduction](#introduction)
* [Memory Management](#memory-management)
* [Variables](#variables)
    * [Use Variable Values](#use-variable-values)
    * [Observe Variables](#observe-variables) 
    * [Variables are Codable](#variables-are-codable)
* [Mappings](#mappings)
    * [Create Mappings](#create-a-mapping)
    * [Swap Mapping Sources](#swap-mapping-sources)
    * [Chain Mappings](#chain-mappings)
    * [Use Prebuilt Mappings](#use-prebuilt-mappings)
* [Ad Hoc Mapping](#ad-hoc-mapping)
* [Messengers](#messengers)
    * [The Messenger Pattern](#the-messenger-pattern)
    * [Using Messengers](#using-messengers)
* [Custom Observables](#custom-observables)
    * [Declare Custom Observables](#declare-custom-observables)
    * [Send Custom Messages](#send-custom-messages)
    * [The Latest Message](#the-latest-message)
    * [Make State Observable](#make-state-observable)
* [Weak Observables](#weak-observables)
* [Specific Patterns](#specific-patterns)
* [Why the Hell Another Reactive Library?](#why)

# Get Involved

Found a **bug**? Create a [github issue](https://github.com/flowtoolz/SwiftObserver/issues/new/choose).

Need a **feature**? Create a [github issue](https://github.com/flowtoolz/SwiftObserver/issues/new/choose).

Want to **improve** stuff? Create a [pull request](https://github.com/flowtoolz/SwiftObserver/pulls).

Want to start a **discussion**? Visit [Gitter](https://gitter.im/flowtoolz/SwiftObserver/).

Need **support** and troubleshooting? Write at <swiftobserver@flowtoolz.com>.

Want to **contact** us? Write at <swiftobserver@flowtoolz.com>.

# Get Started

## Install

With [**Carthage**](https://github.com/Carthage/Carthage), add this line to your [Cartfile](https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md#cartfile):

```
github "flowtoolz/SwiftObserver" ~> 5.0
```

Then follow [these instructions](https://github.com/Carthage/Carthage#adding-frameworks-to-an-application) and run `$ carthage update --platform ios`.

With [**Cocoapods**](https://cocoapods.org), adjust your [Podfile](https://guides.cocoapods.org/syntax/podfile.html):

```ruby
use_frameworks!

target "MyAppTarget" do
  pod "SwiftObserver", "~> 5.0"
end
```

Then run `$ pod install`.

With the [**Swift Package Manager**](https://github.com/apple/swift-package-manager/tree/master/Documentation#swift-package-manager), adjust your [Package.swift](https://github.com/apple/swift-package-manager/blob/master/Documentation/Usage.md#create-a-package) file:

~~~swift
// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "SPMExample",
    dependencies: [
        .package(url: "https://github.com/flowtoolz/SwiftObserver.git",
                 .upToNextMajor(from: "5.0.1"))
    ],
    targets: [
        .target(name: "SPMExample",
                dependencies: ["SwiftObserver"])
    ],
    swiftLanguageVersions: [.v4_2]
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

class Dog: Observer {
    deinit {
        stopObserving() // stops ALL observations this Dog is doing
    } 
}
~~~

### Observers

By conforming to `Observer`, the *observer* adopts functions for starting and ending observations. Each observation involves one *observer* and one observed object. <a id="combined-observations"></a> An  `Observer` may start up to three observations with one combined call:

~~~swift
dog.observe(tv, bowl, doorbell) { image, food, sound in
    // either the tv's going, I got some food, or the bell rang
}
~~~

To process *messages* from an observed object, the *observer* must be alive. There's no awareness after death in memory:

```swift
class Dog: Observer {
    init {
        observe(Sky.shared) { color in
            // for this closure to be called, this Dog must live
        }
    }
}
```

### Observables

For objects to be observable, they must conform to `Observable`. There are four ways to make these *observables*:

1. Create a [*variable*](#variables). It's an `Observable` that holds a value and sends value changes.
2. Create a [*mapping*](#mappings). It's an `Observable` that transforms *messages* from a *source observable*.
3. Create a [*messenger*](#messengers). It's an `Observable` through which other objects communicate.
4. Implement a [custom](#custom-observables) `Observable` by conforming to `CustomObservable`.

You use every `Observable` the same way. There are only three things to note:

1. Observing an `Observable` does not have the side effect of keeping it alive. Someone must own it via a strong reference. (Note that you can still [observe with a chain of ad hoc transformations](#ad-hoc-mapping) all in a single line.)
2. The property `latestMessage` typically returns the last sent *message* or one that indicates that nothing changed. It's a way for clients to request (pull) the "current" message, in addition to waiting for the `Observable` to send (push) the next. [Combined observations](#combined-observations) also rely on `latestMessage`.
3. Typically, an `Observable` sends its *messages* by itself. But anyone can make it send  `latestMessage` via `send()` or any other *message* via `send(_:)`.

# Memory Management

To avoid abandoned observations piling up in memory, *observers* should, before they die, stop their observations. One way to do that is to stop each observation when it's no longer needed:

```swift
dog.stopObserving(Sky.shared)
```

An even simpler and safer way is to let *observers*, right before they die, stop all their observations:

```swift
class Dog: Observer {
    deinit {
        stopObserving()  // stops ALL observations this Dog is doing
    }
}
```

You can stop an *observable's* observations via `observable.stopObservations()`. But when an *observable* dies, it automatically stops all its observations, so you don't need to do anything in its `deinit`.

Forgetting some observations wouldn't waste significant memory. But you should understand, control and express the mechanics of your code to a degree that prevents systemic leaks.

The three above mentioned functions are all you need for safe memory management. If you still want to erase observations that you may have forgotten, there are two other functions for that:

1. `observable.stopAbandonedObservations()`
2. `stopAllAbandonedObservations()` (Erases **every** observation whos *observer* is dead)

> Memory management with SwiftObserver is meaningful and safe. There are no contrived constructs like "Disposable" or "DisposeBag". And since you can always flush out orphaned observations, real memory leaks are impossible.

# Variables

A `Var<Value>` has a property `value: Value`. If `Value` is `Equatable` or `Comparable`, the whole `Var<Value>` will also conform to the respective protocol.

## Use Variable Values

You can set `value` directly, via initializer and via the `<-` operator:

~~~swift
let text = Var<String?>()    // text.value == nil
text.value = "a text"
let number = Var(23)         // number.value == 23
number <- 42                 // number.value == 42
~~~

### Number Values

If you use some number type `Number` that is either an `Int`, `Float` or `Double`:

1. Every `Var<Number>`, `Var<Number?>`, `Var<Number>?` and `Var<Number?>?` has either a `var int: Int`, `var float: Float` or `var double: Double`. That property is non-optional and interprets `nil` values as zero.

2. You can apply numeric operators `+`, `-`, `*` and `/` to all pairs of `Number`, `Number?`, `Var<Number>`, `Var<Number?>`, `Var<Number>?` and `Var<Number?>?`.

3. ```swift
    let numVar = Var<Int?>()     // numVar.value == nil
    print(numVar.int)            // 0
    numVar.int += 5              // numVar.value == 5
    numVar <- Var(1) + 2         // numVar.value == 3
    ```

### String Values

1. Every `Var<String>`, `Var<String?>`, `Var<String>?` and `Var<String?>?` has a `var string: String`. That property is non-optional and interprets `nil` values as `""`.
2. Representing its `string` property, every `Var<String>` and `Var<String?>` conforms to `BidirectionalCollection`, `Collection` and `Sequence`.
3. You can apply concatenation operator `+` to all pairs of `String`, `String?`, `Var<String>`, `Var<String?>`, `Var<String>?` and `Var<String?>?`.

## Observe Variables

A `Var<Value>` sends *messages* of type `Change<Value>`, providing the `old` and `new` value, with `latestMessage` holding the current `value` in both properties: `old` and `new`.

~~~swift
observer.observe(variable) { change in
    if change.old == change.new {
        // message was manually sent, no value change
    }
}
~~~

A `Var` sends a `Change<Value>` whenever its `value` actually changes. Just starting to observe the `Var` does **not** trigger a *message*. This keeps it simple, predictable and consistent, in particular in combination with [*mappings*](#mappings). Of course, you can always manually send `latestMessage` via `send()`.

Internally, a `Var` appends new values to a queue, so all its *observers* get to process a `value` change before the next change takes effect. This is for situations when the `Var` has multiple *observers* and at least one of them changes the `value` in response to a `value` change.

## Variables are Codable

`Var` is `Codable`, so when you declare a type with `Var` properties, you can make it `Codable` by simply adopting the `Codable` protocol. To this end, `Var.Value` must be `Codable`:

~~~swift
class Model: Codable {
    private(set) var text = Var("String Variable")
}

let model = Model()

if let modelJSON = try? JSONEncoder().encode(model) {
    print(String(data: modelJSON, encoding: .utf8) ?? "error")
    // ^^ {"text":{"storedValue":"String Variable"}}
            
    if let decodedModel = try? JSONDecoder().decode(Model.self, from: modelJSON) {
        print(decodedModel.text.value)
        // ^^ String Variable
    }
}
~~~

Note that `text` is a `var` instead of a `let`. It cannot be constant because the implicit decoder must mutate it. However, clients of `Model` would be supposed to set only `text.value` and not `text` itself, so the setter is private.

# Mappings

## Create Mappings

Create a new `Observable` that maps (transforms) the *messages* of a given *source observable*:

~~~swift
let text = Var<String?>()
let textLength = text.map { $0.new?.count ?? 0 }  // textLength.source === text
// ^^ an Observable that sends Int messages
~~~

You can access the *source* of a *mapping* via the `source` property. A *mapping* holds the `source` strongly, just like arrays and other data structures would hold an `Observable`. You could rewrite the above example like so:

```swift
let textLength = Var<String?>().map { $0.new?.count ?? 0 }
// ^^ textLength.source is of type Var<String?>
```

When you want to hold an `Observable` weakly, wrap it in [`Weak`](#weak-observables). For instance, you can let a *mapping* hold its *source*  weakly:

```swift
let toString = Weak(Var<Int?>()).new().unwrap(0).map { "\($0)" }
let sourceIsDead = toString.source.observable == nil // true
// ^^ no one holds Var<Int?>(), so it dies
```

As [mentioned earlier](#observables), you use a *mapping* like any other `Observable`: You hold a strong reference to it somewhere, you stop observing it (not its *source*) at some point, and you can call `latestMessage`, `send(_:)` and `send()` on it.

## Swap Mapping Sources

You can also reset the `source`, causing the *mapping* to send a *message* (with respect to its [*filter*](#filter)). Although the `source` is replaceable, it's of a specific type that you determine by creating the *mapping*.

So, you may create a *mapping* without knowing what `source` objects it will have over its lifetime. Just use an ad-hoc dummy *source* to create the *mapping* and, later, reset `source` as often as you like:

```swift
let title = Var<String?>().map {  // title.source must be a Var<String?>
    $0.new ?? "untitled"
}

let titleSource = Var<String?>("Some Title String")
title.source = titleSource
```

Being able to declare *mappings* as mere transformations, independent of their concrete *sources*, can help, for instance, in developing view models.

## Chain Mappings

You may chain *mappings* together:

```swift
let mapping = Var<Int?>().map {   // mapping.source is a Var<Int?>
    $0.new ?? 0                   // Change<Int?> -> Int
}.filter {
    $0 > 9                        // only forward integers > 9
}.map {
    "\($0)"                       // Int -> String
}
// ^^ mapping sends messages of type String
```

**When you chain *mappings* together, you actually compose them into one single *mapping***. So the `source` of a *mapping* is never another *mapping*. It always refers to the original *source* `Observable`. In the above example, the `source` of the created *mapping* is a `Var<Int?>`.

## Use Prebuilt Mappings

### New

When an `Observable` sends *messages* of type `Change<Value>`, you often only care about  the `new` value of that change. If so, use `new()`:

~~~swift
let text = Var<String?>().new()
// ^^ sends messages of type String?
~~~

### Unwrap

Sometimes, we make *message* types optional, in particular when they have no meaningful initial value. But we often don't want to deal with optionals down the line. You can apply the *mapping* `unwrap(_:)` to **any** `Observable` that sends optional *messages*. It unwraps the optionals using a default value:

~~~swift
let title = Var<String?>().new().unwrap("untitled")
// ^^ sends messages of type String, replacing nil with "untitled"
~~~

If you want `unwrap(_:)` to never actually send the default, just filter out `nil` values before:

~~~swift
let title = Var<String?>().new().filter{ $0 != nil }.unwrap("")
// ^^ sends messages of type String, not sending at all for nil values
~~~

### Filter

When you just want to filter- and not actually transform *messages*, use `filter`:

```swift
let shortText = Var("").new().filter { $0.count < 5 }
// ^^ sends messages of type String, suppressing long strings
```

A *mapping* that has a *filter* maps and sends only those *source messages* that pass the *filter*. Of course, the *filter* cannot apply when you actively request the *mapping's* `latestMessage`.

You could use a *mapping's* `filter` property to see which *source* *messages* get through:

```swift
shortText.filter?(Change(nil, "this is too long")) ?? true // false
```

### Select

Use the `select` filter to receive only one specific *message*. `select` is available on all *observables* that send `Equatable` *messages*. When observing a *mapping* produced by `select`, the closure takes no arguments:

```swift
let notifier = Var("").new().select("my notification")

observer.observe(notifier) {  // nothing going in
    // someone sent "my notification"
}
```

# Ad Hoc Mapping

The moment we start a particular observation, we often want to apply common transformations to it. Of course, **we cannot observe an ad hoc created [*mapping*](#mappings)**:

```swift
dog.observe(bowl.map({ $0 == .wasFilled })) { bowlWasFilled in
    // FAIL: This closure will never run since no one holds the observed mapping!
    // .map({ $0 == .wasFilled }) creates a mapping which immediately dies                       
}   
```

Instead of holding a dedicated [*mapping*](#mappings) somewhere, you can map the observation itself:

```swift
dog.observe(bowl).map({ $0 == .wasFilled }) { bowlWasFilled in
    if bowlWasFilled {
        // clear bowl in under a minute
    }
}   
```

You do this *ad hoc mapping* in the same terms in which you create stand-alone [*mappings*](#mappings): With `map`, `new`, `unwrap`, `filter` and `select`. And you also chain these transformations together:

```swift
let number = Var(42)
        
observer.observe(number).new().map {
    "\($0)"         // Int -> String
}.filter {
    $0.count > 1    // filter out single digit integers
}.map {
    Int.init($0)    // String -> Int?
}.filter {
    $0 != nil       // filter out nil values
}.unwrap(-1) {      // Int? -> Int, and pass final message receiver
    print($0)       // process Int
}
```

Consequently, each transform function comes in 2 variants:

1. The chaining variant returns a result on which you call the next transform function.
2. The terminating variant takes your actual *message* receiver in an additional closure argument.


When the chain is supposed to end on `map` or `filter`, let `receive` terminate it to stick with [trailing closures](https://docs.swift.org/swift-book/LanguageGuide/Closures.html#ID102):

~~~swift
dog.observe(bowl).map {
    $0 == .wasFilled    // Bowl.Message -> Bool
}.receive {
    if $0 {             // if bowl was filled
        // clear bowl in under a minute
    }
} 
~~~

Remember that a `select` closure takes no arguments because it runs only for the selected *message*:

```swift
dog.observe(Sky.shared).select(.blue) {  // no argument in
    // the sky became blue, let's go for a walk!
}
```

# Messengers

## The Messenger Pattern

When *observer* and *observable* need to be more decoupled, it is common to use a mediating *observable* through which any object can anonymously send *messages*. An example of this mediator is [`NotificationCenter`](https://developer.apple.com/documentation/foundation/notificationcenter).

This use of the *Observer Pattern* is sometimes called *Messenger*, *Notifier*, *Dispatcher*, *Event Emitter* or *Decoupler*. Its main differences to direct observation are:

- The actual *observable*, which is the messenger, sends no *messages* by itself.
- Every object can trigger *messages*, without adopting any protocol.
- Multiple sending objects trigger the same type of *messages*.
- An *observer* may indirectly observe multiple other objects through one observation.
- *Observers* don't care as much who triggered a *message*.
- *Observer* types don't need to depend on the types that trigger *messages*.

## Using Messengers

### Use a Variable as a Messenger

You could use a [mapped](#mappings) `Var` as a mediating messenger:

```swift
let textMessenger = Var("").new()

observer.observe(textMessenger) { textMessage in
    // respond to text message
}
    
textMessenger.send("my text message")
```

This sort of implementation doesn't duplicate *messages*. If you want `latestMessage` to return the last *message* that was sent, for instance for combined observations, you'd have to store *messages* in the `Var` instead of just sending them. The latest *message* is then available through `latestMessage` and `source`:

```swift
textMessenger.source <- "my text message" // sends the message
// textMessenger.latestMessage == "my text message"
// textMessenger.source.value == "my text message"
```

### Use the Messenger Class

We recommend using `Messenger`:

```swift
let textMessenger = Messenger("")

observer.observe(textMessenger) { textMessage in
    // respond to text message
}
        
textMessenger.send("my text message")
// textMessenger.latestMessage == "my text message"
```

`Messenger` offers some advantages over any `Var` based implementation:

1. The intended use of the object is explicit.
2. All sent *messages* become `latestMessage` (also guaranteeing that `send()` resends the last sent *message*).
3. You have the option to deactivate *message* buffering via `remembersLatestMessage = false`.
4. You can reset the latest *message* without sending. In particular, optional *message* types allow to erase the buffered *message* via `latestMessage = nil`.
5. The *message* type doesn't need to be `Codable`.

### Receive One Specific Notification

No matter how you implement your messenger, you may use `select` to observe (subscribe to-) one specific *message*:

```swift
observer.observe(textMessenger).select("my notification") {
    // respond to "my notification"
}
```

# Custom Observables

## Declare Custom Observables

Implement your own `Observable` by conforming to `CustomObservable`. A custom *observable* just needs to specify its `Message` type and store a `Messenger<Message>`. Here's a minimal example:

~~~swift
class Minimal: CustomObservable {
    let messenger = Messenger<String?>()
    typealias Message = String?
}
~~~

A typical `Message` would be some `enum`:

~~~swift
class Model: CustomObservable {
    let messenger = Messenger(Event.didInit)
    typealias Message = Event
    
    enum Event { case didInit, didUpdate, willDeinit }
}
~~~

## Send Custom Messages

Messages are custom and yet fully typed. An `Observable` sends whatever it likes whenever it wants via `send(_ message: Message)`. This `Observable` sends optional strings:

~~~swift
class Model: CustomObservable {
    init { send("did init") }
    func foo() { send(nil) }
    deinit { send("will deinit") }
    
    let messenger = Messenger<String?>()
    typealias Message = String?
}
~~~

## The Latest Message

A `CustomObservable` uses its `messenger` to implement `Observable`. For instance, `send(_:)` internally calls `messenger.send(_:)`. 

By default, a `Messenger` remembers the last *message* it sent, therefore `latestMessage` on a `CustomObservable` works as expected, in particular for combined observations. However, the `CustomObservable` is in control of that duplication and can always deactivate it:

~~~swift
class NoDuplication: CustomObservable {
    init {
        remembersLatestMessage = false  // latestMessage stays nil
    }

    let messenger = Messenger<String?>()
    typealias Message = String?
}
~~~

If your `Message` is optional, you can also erase the buffered *message* at any point via `messenger.latestMessage = nil`.

## Make State Observable

To inform *observers* about value changes, similar to `Var<Value>`, you would use `Change<Value>`, and you might want to customize `latestMessage` so it returns a message based on the latest (current) value:

~~~swift
class Model: CustomObservable {
    var latestMessage: Change<String?> {
        Change(state, state)
    }
       
    var state: String? {
        didSet {
            if oldValue != state {
                send(Change(oldValue, state))
            }
        }
    }
        
    let messenger = Messenger(Change<String?>())
}
~~~

Note that Swift can (as of now) not infer the `associatedtype` `Message` from a generic property like `messenger`, but it can infer `Message` from `latestMessage`. So the above example doesn't need this: `typealias Message = Change<String?>`.

# Weak Observables

When you want to put an `Observable` into some data structure or as the *source* into a *mapping* and hold it there as a `weak` reference, you may want to wrap it in `Weak<O: Observable>`:

~~~swift
let number = Var(12)
let weakNumber = Weak(number)

controller.observe(weakNumber) { message in
    // process message of type Change<Int>
}

var weakNumbers = [Weak<Var<Int>>]()
weakNumbers.append(weakNumber)
~~~

`Weak<O: Observable>` is itself an `Observable` and functions as a complete substitute for its wrapped `weak` `Observable`, which you can access via the `observable` property:

~~~swift
let numberIsAlive = weakNumber.observable != nil
let numberValue = weakNumber.observable?.value
~~~

Since the wrapped `observable` might die, `Weak` has to buffer, and therefore **duplicate**, the value of `latestMessage`. This is a necessary price for holding an `Observable` weakly while using it all the same.

# Specific Patterns

Patterns that emerged from using SwiftObserver [are documented over here](https://github.com/flowtoolz/SwiftObserver/blob/master/Documentation/specific-patterns.md#specific-patterns).

# <a id="why"></a>Why the Hell Another Reactive Library?

SwiftObserver diverges from convention. It follows the reactive idea in generalizing the *Observer Pattern*. But it doesn't inherit the metaphors, terms, types, or function- and operator arsenals of common reactive libraries. This freed us to create something different, something we **love** to work with.

Leaving out the right kind of fancyness leaves us with the right kind of simplicity, a simplicity which is powerful. 

Read more about the [philosophy and features of SwiftObserver](https://github.com/flowtoolz/SwiftObserver/blob/master/Documentation/philosophy.md#the-philosophy-of-swiftobserver).

# License

SwiftObserver is released under the MIT license. [See LICENSE](https://github.com/flowtoolz/SwiftObserver/blob/master/LICENSE) for details.

[badge-gitter]: https://img.shields.io/badge/chat-Gitter-red.svg?style=flat-square

[badge-pod]: https://img.shields.io/cocoapods/v/SwiftObserver.svg?label=version&style=flat-square

[badge-pms]: https://img.shields.io/badge/supports-CocoaPods%20%7C%20Carthage%20%7C%20SPM-green.svg?style=flat-square
[badge-languages]: https://img.shields.io/badge/language-Swift-orange.svg?style=flat-square
[badge-platforms]: https://img.shields.io/badge/platforms-iOS%20%7C%20macOS%20%7C%20tvOS%20%7C%20watchOS%20%7C%20Linux-lightgrey.svg?style=flat-square
[badge-mit]: https://img.shields.io/badge/license-MIT-lightgrey.svg?style=flat-square
