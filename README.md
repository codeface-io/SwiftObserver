![SwiftObserver](https://raw.githubusercontent.com/flowtoolz/SwiftObserver/master/Documentation/swift.jpg)

# SwiftObserver

[![badge-pod]](http://cocoapods.org/pods/SwiftObserver) ![badge-pms] ![badge-languages] ![badge-platforms] ![badge-mit]

*SwiftObserver* is a lightweight framework for reactive Swift. Its design goals make it easy to learn and a joy to use:

1. [**Meaningful Code**](#meaningful-code): SwiftObserver promotes meaningful metaphors, names and syntax, producing highly readable code.
2. [**Non-intrusive Design**](#non-intrusive-design): SwiftObserver doesn't limit or modulate your design. It just makes it easy to do the right thing.
3. [**Simplicity**](#simplicity): SwiftObserver employs very few simple concepts and applies them consistently without exceptions.
4. [**Flexibility**](#flexibility): SwiftObserver's types are simple but universal and composable, making them applicable in many situations.
5. [**Safety**](#safety): SwiftObserver makes memory management meaningful and easy. Oh yeah, real memory leaks are impossible.

[*Reactive Programming*](https://en.wikipedia.org/wiki/Reactive_programming) adresses the central challenge of implementing a clean architecture: [*Dependency Inversion*](https://en.wikipedia.org/wiki/Dependency_inversion_principle). *SwiftObserver* breaks *Reactive Programming* down to its essence, which is the [*Observer Pattern*](https://en.wikipedia.org/wiki/Observer_pattern).

*SwiftObserver* is just about 1100 lines of production code, but it's also hundreds of hours of work, thinking it through, letting features go for the sake of simplicity, documenting it, [unit-testing it](https://github.com/flowtoolz/SwiftObserver/blob/master/Tests/SwiftObserverTests/SwiftObserverTests.swift), and battle-testing it [in practice](http://flowlistapp.com).

* [Install](#install)
* [Get Started](#get-started)
    * [Observers](#observers)
    * [Observables](#observers)
* [Memory Management](#memory-management)
* [Variables](#variables)
    * [Set Variable Values](#set-variable-values)
    * [Observe Variables](#observe-variables) 
    * [Variables are Codable](#variables-are-codable)
    * [More on Variables](#more-on-variables)
* [Custom Observables](#custom-observables)
    * [Declare Custom Observables](#declare-custom-observables)
    * [Send Custom Updates](#send-custom-updates)
    * [Make State Observable](#make-state-observable)
* [Mappings](#mappings)
    * [Create Mappings](#create-a-mapping)
    * [Swap Mapping Sources](#swap-mapping-sources)
    * [Chain Mappings](#chain-mappings)
    * [Use Prebuilt Mappings](#use-prebuilt-mappings)
* [Ad Hoc Mapping](#ad-hoc-mapping)
* [Weak Observables](#weak-observables)
* [Specific Patterns](#specific-patterns)
* [Why the Hell Another Reactive Library?](#why)

# Install

Via [Carthage](https://github.com/Carthage/Carthage): Add this line to your [Cartfile](https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md#cartfile):

~~~
github "flowtoolz/SwiftObserver" ~> 4.1
~~~

Via [Cocoapods](https://cocoapods.org): Adjust your [Podfile](https://guides.cocoapods.org/syntax/podfile.html):

~~~ruby
use_frameworks!

target "MyAppTarget" do
  pod "SwiftObserver", "~> 4.1"
end
~~~

Then, in your Swift files:

~~~swift
import SwiftObserver
~~~

# Get Started

> No need to learn a bunch of arbitrary metaphors, terms or types.<br>*SwiftObserver* is simple: **Objects observe other objects**.

Or a tad more technically: Observed objects send updates to their *Observers*. 

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

## Observers

*Observers* adopt the `Observer` protocol, which gives them functions for starting and ending observations.

After starting to observe something, the *Observer* must be alive for the observation to continue. There's no awareness after death in memory. But that's a bit easy to overlook when we start observations from within the `Observer`, which is what we often do:

```swift
class Dog: Observer {
    init {
        observe(Sky.shared) { color in
            // for this closure to run, this Dog must live
        }
    }
}
```

<a id="combined-observations"></a> You may start up to three observations with one combined call:

~~~swift
dog.observe(tv, bowl, doorbell) { image, food, sound in
    // either the tv's going, I got some food, or the bell rang
}
~~~

## Observables

For objects to be observable, they must conform to `Observable`. 

You get *Observables* in three ways:

1. Create a [*Variable*](#variables). It's an `Observable` that holds a value and sends value updates.
2. Implement a [custom](#custom-observables) `Observable`.
3. Create a [*Mapping*](#mappings). It's an `Observable` that transforms updates from a *Source Observable*.

You use all *Observables* the same way. There are only 3 things to note about `Observable`:

- Observing an `Observable` does not have the side effect of keeping it alive. Someone must own it via a strong reference. (Note that this won't prevent us from [observing with a chain of transformations](#ad-hoc-mapping) all in a single line.)
- The property `latestUpdate` is of the type of updates the `Observable` sends. It's a way for clients to request (pull) the last or "current" update, as opposed to waiting for the `Observable` to send (push) it. ([Combined observations](#combined-observations) also pull `latestUpdate`.)
- Generally, an `Observable` sends its updates by itself. But anyone can make it send  `latestUpdate` via `send()` or any other update via `send(_:)`.

# Memory Management

To avoid abandoned observations piling up in memory, you should stop them before their *Observer* or *Observable* die. One way to do that is to stop each observation when it's no longer needed:

```swift
dog.stopObserving(Sky.shared)
```

An even simpler and safer way is to clean up objects right before they die:

```swift
class Dog: Observer {
    deinit {
        stopObserving()  // stops ALL observations this Dog is doing
    }
}

class Sky: Observable {
    deinit {
        removeObservers()  // stops ALL observations of this Sky
    }
    // Sky implementation ...
}
```

Forgetting some observations wouldn't waste significant memory. But you should understand, control and express the mechanics of your code to a degree that prevents systemic leaks.

The 3 above mentioned functions are all you need for safe memory management. If you still want to erase observations that you may have forgotten, there are 3 other functions for that:

1. `myObserver.stopObservingDeadObservables()`
2. `myObservable.removeDeadObservers()`
3. `removeAbandonedObservations()` (Erases **all** observations whos *Observer* or *Observable* are dead)

> Memory management with *SwiftObserver* is meaningful and safe. There are no contrived constructs like "Disposable" or "DisposeBag". And since you can always flush out orphaned observations, real memory leaks are impossible.

# Variables

## Set Variable Values

A `Var<Value>` has a property `var value: Value?`. You can set `value` via the `<-` operator.

~~~swift
let text = Var<String>()    // text.value == nil
text.value = "a text"
let number = Var(23)        // number.value == 23
number <- 42                // number.value == 42
~~~

### Numbers

If your `Var.Value` conforms to [`Numeric`](https://developer.apple.com/documentation/swift/numeric):

1.  `value` is accessible as a non-optional `number: Value`, interpreting `nil` as zero.
2. You can apply numeric operators `+`, `+=`, `-`, `-=`, `*` and `*=` to almost all pairs of `Var`, `Var?`, `Value` and `Value?`:

    ```swift
    let numVar = Var<Int>()         // numVar.value == nil
    print(numvar.number)            // 0
    numVar += 10                    // numVar.value == 10
    numVar -= Var(6)                // numVar.value == 4
    var number = Var(3) + Var(2)    // number == 5
    number += Var(5)                // number == 10
    ```

### Strings

If your `Var` is a `Var<String>`:

1. `value` is accessible as a non-optional `string: String`, interpreting `nil` as `""`.
2. Representing its `String` value, the `Var` conforms to `BidirectionalCollection`, `Collection` and `Sequence`.
3. You can apply concatenation operators `+` and `+=` to almost all pairs of `Var`, `Var?`, `String` and `String?`. 

## Observe Variables

A `Var<Value>` sends updates of type `Update<Value?>`, providing the old and new value:

~~~swift
observer.observe(variable) { update in
    if update.old == update.new {
        // update was manually triggered, no value change
    }
}
~~~

A `Var` sends an update whenever its `value` actually changes. Just starting to observe it does **not** trigger an update. This keeps it simple, predictable and consistent, in particular in combination with [*Mappings*](#mappings). You can always call `send()` on a `Var<Value>`, sending an `Update<Value?>` in which `old` and `new` are both the current `value`.

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
        print(decodedModel.text.value ?? "error")
        // ^^ String Variable
    }
}
~~~

Note that `text` is a `var` instead of a `let`. It cannot be constant because the implicit decoder must mutate it. However, clients of `Model` would be supposed to set only `text.value` and not `text` itself, so the setter is private.

## More on Variables

- If your `Var.Value` conforms to `Equatable` or `Comparable`, the whole `Var<Value>` will also conform to the respective protocol.
- Internally, a `Var` appends new values to a queue, so all its *Observers* get to process a value change before the next change takes effect. This is for situations when the `Var` has multiple *Observers* and at least one *Observer* changes the `value` in response to a `value` change.
- A `Var` is a bit more performant than a [custom *Observable*](#custom-observables) because `Var` maintains its own pool of *Observers*. So if you want to make a super large number of elements in some data structure observable, like particles in a simulation or nodes in a gigantic graph, give those elements a `Var` as an [*Owned Messenger*](https://github.com/flowtoolz/SwiftObserver/blob/master/Documentation/specific-patterns.md#owned-messenger).
- Generally, performance is not an issue. *Observables* and *Observers* are internally hashed by their respective [`ObjectIdentifier`](https://developer.apple.com/documentation/swift/objectidentifier).

# Custom Observables

## Declare Custom Observables

Custom *Observables* just need to adopt the `Observable` protocol and provide a property  `latestUpdate` of the type of updates they wish to send:

~~~swift
class Model: Observable {
    var latestUpdate = Event.didInit
    enum Event { case didInit, didUpdate, willDeinit }
}
~~~

Swift infers the associated `UpdateType` from `latestUpdate`, so you don't have to write `typealias UpdateType = Event`.

`latestUpdate` typically returns the last update that was sent or a value that indicates that nothing changed. It can be optional and may (always) return `nil`:

~~~swift
class MinimalObservable: Observable {
    let latestUpdate: Int? = nil
}
~~~

## Send Custom Updates

Updates are custom and yet fully typed. An `Observable` sends whatever it likes whenever it wants via `send(_ update: UpdateType)`. This `Observable` sends updates of type `String?`:

~~~swift
class StringObservable: Observable {
    var latestUpdate: String?
    
    init { send("did init") }
    func foo() { send(nil) }
    deinit { send("will deinit") }
}
~~~

## Make State Observable

Using update type `Update<Value>`, you can inform *Observers* about value changes, similar to how `Var<Value>` does that:

~~~swift
class Model: Observable {
    var latestUpdate: Update<String?> {
        return Update(state, state)
    }
   
    var state: String? {
        didSet {
            if oldValue != state {
                send(Update(oldValue, state))
            }
        }
    }
}
~~~

# Mappings

## Create Mappings

Create a new `Observable` that maps (transforms) the updates of a given *Source Observable*:

~~~swift
let text = Var<String>()
let textLength = text.map { $0.new?.count ?? 0 }  // textLength.source === text
// ^^ an Observable that sends Int updates
~~~

You can access the *Source* of a *Mapping* via the `source` property. A *Mapping* holds the `source` strongly, just like arrays and other data structures would hold an `Observable`. You could rewrite the above example like so:

```swift
let textLength = Var<String>().map { $0.new?.count ?? 0 }
// ^^ textLength.source is of type Var<String>
```

When you want to hold an `Observable` weakly, as the *Source* of a *Mapping* or in some data structure, wrap it in [`Weak`](#weak-observables).

As [mentioned earlier](#observables), you use a *Mapping* like any other `Observable`: You hold a strong reference to it somewhere, you stop observing it (not its *Source*) at some point, and you can call `latestUpdate`, `send(_:)` and `send()` on it.

## Swap Mapping Sources

You can even reset the `source`, causing the *Mapping* to send an update (with respect to its [*Filter*](#filter)). Although the `source` is replaceable, it's of a specific type that you determine by creating the *Mapping*.

So, you may create a *Mapping* without knowing what `source` objects it will have over its lifetime. Just use an ad-hoc dummy *Source* to create the *Mapping* and, later, reset `source` as often as you like:

```swift
let title = Var<String>().map {  // title.source must be a Var<String>
    $0.new ?? "untitled"
}

let titleSource = Var("Some Title String")
title.source = titleSource
```

Being able to declare *Mappings* as mere transformations, independent of their concrete *Sources*, can help, for instance, in developing view models.

## Chain Mappings

You may chain *Mappings* together:

```swift
let mapping = Var(Int).map {    // mapping.source is a Var<Int>
    $0.new ?? 0                 // Update<Int?> -> Int
}.filter {
    $0 > 9                      // only forward integers > 9
}.map {
    "\($0)"                     // Int -> String
}
// ^^ mapping sends updates of type String
```

**When you chain *Mappings* together, you actually compose them into one single *Mapping***. So the `source` of a *Mapping* is never another *Mapping*. It always refers to the original *Source* `Observable`. In the above example, the `source` of the created *Mapping* is a `Var<Int>`.

## Use Prebuilt Mappings

### New

When an `Observable` sends updates of type `Update<SomeType>`, you often only care about  the `new` value in that update. If so, use `new()`:

~~~swift
let text = Var<String>().new()
// ^^ sends updates of type String?
~~~

### Unwrap

A `Var<Value>` has a `var value: Value?` and sends updates of type `Update<Value?>`. However, we often don't want to deal with optionals down the line.

You can apply the *Mapping* `unwrap(_:)` to **any** `Observable` that sends optional updates. It unwraps the optionals using a default value:

~~~swift
let title = Var<String>().new().unwrap("untitled")
// ^^ sends updates of type String, replacing nil with "untitled"
~~~

If you want `unwrap(_:)` to never actually send the default, just filter out `nil` values before:

~~~swift
let title = Var<String>().new().filter{ $0 != nil }.unwrap("")
// ^^ sends updates of type String, not sending at all for nil values
~~~

### Filter

When you just want to filter- and not actually transform updates, use `filter`:

```swift
let shortText = Var<String>().new().unwrap("").filter { $0.count < 5 }
// ^^ sends updates of type String, suppressing long strings
```

A *Mapping* that has a *Filter* maps and sends only those *Source* updates that pass the *Filter*. Of course, the *Filter* cannot apply when you actively request the *Mapping's* `latestUpdate`.

You could use a *Mapping's* `filter` property to see which *Source* updates get through:

```swift
shortText.filter?(Update(nil, "this is too long")) ?? true // false
```

### Select

Use the `select` filter to receive only one specific update. `select` is available on all *Observables* that send `Equatable` updates. When observing a *Mapping* produced by `select`, the closure takes no arguments:

```swift
let notifier = Var<String>().new().select("my notification")

observer.observe(notifier) {  // nothing going in
    // someone sent "my notification"
}
```

# Ad Hoc Mapping

The moment we start a particular observation, we often want to apply common transformations to it. Of course, **we cannot observe an ad hoc created [*Mapping*](#mappings)**:

```swift
dog.observe(bowl.map({ $0 == .wasFilled })) { bowlWasFilled in
    // FAIL: This closure will never run since no one holds the observed mapping!
    // .map({ $0 == .wasFilled }) creates a mapping which immediately dies                       
}   
```

Instead of holding a dedicated [*Mapping*](#mappings) somewhere, you can map the observation itself:

```swift
dog.observe(bowl).map({ $0 == .wasFilled }) { bowlWasFilled in
    if bowlWasFilled {
        // clear bowl in under a minute
    }
}   
```

You do this *Ad Hoc Mapping* in the same terms in which you create stand-alone [*Mappings*](#mappings): With `map`, `new`, `unwrap`, `filter` and `select`. And you also chain these transformations together:

```swift
let number = Var(42)
        
observer.observe(number).new().unwrap(0).map {
    "\($0)"         // Int -> String
}.filter {
    $0.count > 1    // filter out single digit integers
}.map {
    Int.init($0)    // String -> Int?
}.filter {
    $0 != nil       // filter out nil values
}.unwrap(-1) {      // Int? -> Int, and pass final update receiver
    print($0)       // process Int
}
```

Consequently, each transform function comes in 2 variants:

1. The chaining variant returns a result on which you call the next transform function.
2. The terminating variant takes your actual update receiver in an additional closure argument.


When the chain is supposed to end on `map` or `filter`, let `receive` terminate it to stick with [trailing closures](https://docs.swift.org/swift-book/LanguageGuide/Closures.html#ID102):

~~~swift
observer.observe(number).map {
    $0.new ?? 0    // Update<Int?> -> Int
}.receive {
    print($0)      // process Int
}
~~~

Remember that a `select` closure takes no arguments because it runs only for the selected update:

```swift
dog.observe(Sky.shared).select(.blue) {  // no argument in
    // the sky became blue, let's go for a walk!
}
```

# Weak Observables

When you want to put an `Observable` into some data structure or as the *Source* into a *Mapping* and hold it there as a `weak` reference, you may want to wrap it in `Weak<O: Observable>`:

~~~swift
let number = Var(12)
let weakNumber = Weak(number)

controller.observe(weakNumber) { update in
    // process update of type Update<Int?>
}

var weakNumbers = [Weak<Var<Int>>]()
weakNumbers.append(weakNumber)
~~~

`Weak<O: Observable>` is itself an `Observable` and functions as a complete substitute for its wrapped `weak` `Observable`, which you can access via the `observable` property:

~~~swift
let numberIsAlive = weakNumber.observable != nil
let numberValue = weakNumber.observable?.value
~~~

Since the wrapped `observable` might die, `Weak` has to buffer, and therefore **duplicate**, the value of `latestUpdate`. This is a necessary price for holding an `Observable` weakly while using it all the same.

> Apart from `latestUpdate` on `Weak`, *SwiftObserver* never duplicates the data that is being sent around, not even in [combined observations](#combined-observations). This is in stark contrast to other reactive libraries yet without compomising functional aspects.

# Specific Patterns

Patterns that emerged from using *SwiftObserver* [are documented over here](https://github.com/flowtoolz/SwiftObserver/blob/master/Documentation/specific-patterns.md#specific-patterns).

# <a id="why"></a>Why the Hell Another Reactive Library?

SwiftObserver diverges from convention. It follows the reactive idea in generalizing the *Observer Pattern*. But it doesn't inherit the metaphors, terms, types, or function- and operator arsenals of common reactive libraries. This freed us to create something we love.

The following is still an incoherent brainstorm, outlining the goodies of SwiftObserver ...

## Meaningful Code

- Readable code down to the internals

- Meaningful names and metaphors

- No arbitrary, contrived or technical metaphors (like disposable, dispose bag, signal, emitter, stream, subscribing etc.)

   > A note on "signals": In the tradition of Elm and the origins of reactive programming,  many reactive libraries use "signal" as a metaphor, but how they apply the term is mostly inaccurate and, therefor, more confusing than helpful, for instance when it's suggested that the signal is what's being observed.
   >
   > The appropriate context of reference here is information theory, where a signal is what's being technically transmitted from a source to a receiver. By observing the source, the receiver receives a signal which conveys messages. Practically speaking: One observes the lighthouse itself, not the light it emits.
   >
   > So: Would we correctly apply the metaphor to reactive programming, the signal would correspond to the actual data that observables send to observers. But anyway, we consider the metaphor to be too technical to be generally meaningful to actual application domains.

- No inconsistent metaphors, meaning: no combination of incompatible metaphors that stem from completely different domains. A common and nonsensical mixture is "subscribing" to a "signal". Even Elm, which had signals and still has subscriptions, never mixed the two.

- SwiftObserver is pragmatic and doesn't overgeneralize the *Observer Pattern*, i.e. it doesn't go overboard with the metaphor of "streams" but keeps things more simple, real-world oriented and meaningful to actual application domains.

- No technical boiler plate code at the point of use

    - Create an abservable plus a chain of mappings in one line
    - Start observation and create mappings directly on observables, without a mediating property
        - (comparison to RxSwift would be illuminating here ...)
    - Observe an observable using an ad-hoc chain of transformations
    - No Cancellables, Disposables, DisposeBags or Tokens to pass around and store

- The *SwiftObserver* syntax clearly reflects the intent and metaphor of the *Observer Pattern*: Observers are active subjects while observables are passive objects which are unconcerned about being observed:

    ~~~swift
    dog.observe(sky)
    observer.observe(observable)
    subject.actUpon(object)
    ~~~

    > Note: Many definitions of the *Observer Pattern*, including [Wikipedia](https://en.wikipedia.org/wiki/Observer_pattern), have the subject / object roles reversed, which we consider not merely a misnomer but, above all, a secondary level of analysis.
    >
    > They look at observation from a technical rather than a conceptual point of view, focusing on *how* the problem is being *solved* rather than *what* the solution *means*.
    >
    > The illusion we want to create with the *Observer Pattern* is that an observer observes an observable. Linguistically, that is: subject, predicate, object. The subject actively acts on the object, while the object is passively being acted upon.
    >
    > Of course, to achieve this under the hood, observables must actively trigger some data propagation. But we should look at the solution more pragmatically in terms of the real(-world) meaning that we set out to model in the first place.

## Non-intrusive Design

* No delegate protocols to implement
* Maximum freedom for your architectural- and design choices
    - Because classes have to implement nothing to be observable, you can keep model and logic code independent of any observer frameworks and techniques. If the model layer had to be stuffed with heavyweight constructs just to be observed, it would become a technical issue rather than an easy to change,  meaningful, direct representation of domain-, business- and view logic.
    - Unlike established Swift implementations of the Redux approach, [SwiftObserver](https://github.com/flowtoolz/SwiftObserver) lets you freely model your domain-, business- and view logic with all your familiar design patterns and types. There are no restrictions on how you organize and store your app state.
    - Custom observables without having to inherit from any class
    - Unlike established Swift implementations of the Reactive approach, [SwiftObserver](https://github.com/flowtoolz/SwiftObserver) lets you in control of the ancestral tree of your classes. There is not a single class that you have to inherit. Therefore, all your classes can be directly observed, even views and view controllers.
* No optional generics except for variable values. This plus the ability to map onto non-optional updates greatly avoids optional optionals and gives you full controll over value and update types.

## Simplicity

- Very few but universal concepts / types
- Pure Swift code for clean modelling. Not even dependence on `Foundation`.
- No distinction between "hot-" and "cold signals"
- No distinction between Infinite and Finite "Series"
- Mappings are first-class Observables that can be treated like any other observable
- Combined observations send one update per observable. No tuple destructuring necessary.
- map Mappings, other observables and observations in the exact same terms and with the same chaining syntax.
- No specialized combine function, just one universal function to observe 1-3 observables, yet all the power of combined observation
    - Other reactive libraries dump at least `merge`, `zip` and `combineLatest` on your brain. [SwiftObserver](https://github.com/flowtoolz/SwiftObserver) avoids all that by offering the most universal form of combined observation, in which the update trigger can be identified. (In the worst case, you must ensure the involved observables send updates of type `Update<Value>`.) All other combine functions could be built on top of that using mappings.
    - Combined observation looks exactly like single observation but with more parameters, so it imposes no additional cognitive load.
    - The provided universal combined observation is all you need in virtually all cases. You're free to focus on the meaning of observations and forget its syntax.
- No data duplication:
   - Neither combined observations nor mappings duplicate the data they receive from observables. Combined observations pull update information directly from those observables that didn't trigger the received update.
   - Not having to duplicate data where multiple things must be observed is one of the reasons to use combined observations in the first place. However, some reactive libraries choose to not make full use of object-oriented programming, so far that the combined observables could be value types. This forces these libraries to duplicate data by buffering the updates sent from observables.
   - This is a result of a very simple and universal modelling of the notion of an "Observable". We combined the conventional "push model" in which observables push their updates to observers with a "pull model" in which observers can pull updates from observables, which is what they have always done and what never was the problem, since observers act on observables in the direction of control / dependence. The problem that reactive techiques solve is propagating data **against** the direction of control. Also a pull model is more in line with functional programming: Instead of buffering state, the observer calls and combines functions on observables.

## Flexibility

- Use `<-` operator to directly set variable values
- Variables are `Codable`, so model types are easy to encode and persist.
- Ability to pull current update from all observable
- Recieve old *and* new value from variables
- With Weak, you can chain mappings together without creating strong references to the mapped observables.
- With Weak, you can put Observables into a data structure like an array and still hold them weakly.
- Chaining Mappings has no side effects in terms of which objects are being held strongly and who owns whom. The code remains explicit and the coder in control.
- Mappings are independent of their mapped source observables, to the point where the sources can be freely swapped.
- Seemless integration of the *Notifier Pattern*

## Safety

- Remove observer from all observables with 1 function call
- No irreversible memory leaks, since orphaned observations can always be flushed out via `removeAbandonedObservations()`.

## What you might not like:

- Not conform to Rx (the semi standard of reactive programming)
- SwiftObserver is focused on the foundation of reactive programming. UI bindings are available as [UIObserver](https://github.com/flowtoolz/UIObserver), but that framework is still in its infancy. You're welcome to make PRs.
- Observers and observables must be objects and cannot be of value types. However:
  
   1. Variables can hold any type of values and observables can send any type of updates. 
   2. We found that entities active enough to observe or significant enough to be observed are typically not mere values that are being passed around. What's being passed around are the updates that observables send to observers, and those updates are prototypical value types.
   3. For fine granular observing, the `Var` type is appropriate, further reducing the "need" (or shall we say "anti pattern"?) to observe value types.

[badge-pod]: https://img.shields.io/cocoapods/v/SwiftObserver.svg?label=version&style=flat-square
[badge-pms]: https://img.shields.io/badge/supports-CocoaPods%20%7C%20Carthage-green.svg?style=flat-square
[badge-languages]: https://img.shields.io/badge/languages-Swift-orange.svg?style=flat-square
[badge-platforms]: https://img.shields.io/badge/platforms-iOS%20%7C%20macOS%20%7C%20tvOS%20%7C%20watchOS%20%7C%20Linux-lightgrey.svg?style=flat-square
[badge-mit]: https://img.shields.io/badge/license-MIT-lightgrey.svg?style=flat-square
