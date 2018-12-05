![SwiftObserver](https://raw.githubusercontent.com/flowtoolz/SwiftObserver/master/Documentation/swift.jpg)

# SwiftObserver

[![badge-pod]](http://cocoapods.org/pods/SwiftObserver) ![badge-pms] ![badge-languages] ![badge-platforms] ![badge-mit]

SwiftObserver is a lightweight framework for reactive Swift. 

It's unconventional, [covered by tests](https://github.com/flowtoolz/SwiftObserver/blob/master/Tests/SwiftObserverTests/SwiftObserverTests.swift) and designed to be readable, easy, flexible, non-intrusive, simple and safe.

[Reactive programming](https://en.wikipedia.org/wiki/Reactive_programming) adresses the central challenge of implementing a clean architecture: [Dependency Inversion](https://en.wikipedia.org/wiki/Dependency_inversion_principle). SwiftObserver breaks reactive programming down to its essence, which is the [Observer Pattern](https://en.wikipedia.org/wiki/Observer_pattern).

SwiftObserver is just 800 lines of production code, but it's also hundreds of hours of work, thinking it through, letting features go for the sake of simplicity, documenting it, unit-testing it, and battle-testing it [in practice](http://flowlistapp.com).

* [Install](#install)
* [Get Started](#get-started)
    * [Observers](#observers)
    * [Observables](#observers)
* [Memory Management](#memory-management)
* [Variables](#variables)
    * [Set a Variable Value](#set-a-variable-value)
    * [Variable Updates](#variable-updates) 
    * [Variables are Codable](#variables-are-codable)
    * [More on Variables](#more-on-variables)
* [Custom Observables](#custom-observables)
    * [Declare an Observable](#declare-an-observable)
    * [Send Updates](#send-updates)
    * [Observable State](#observable-state)
* [Mappings](#mappings)
    * [Create a Mapping](#create-a-mapping)
    * [Change the Mapping Source](#change-the-mapping-source)
    * [Mapping Prefilter](#mapping-prefilter)
    * [Compose Mappings](#compose-mappings)
    * [Prebuilt Mappings](#prebuilt-mappings)
* [Weak Observables](#weak-observables)
* [Appendix](#appendix)
    * [Specific Patterns](https://github.com/flowtoolz/SwiftObserver/blob/master/Documentation/specific-patterns.md#specific-patterns)
    * [Why the Hell Another Reactive Library?](#why)

# Install

Via [Carthage](https://github.com/Carthage/Carthage): Add this line to your [Cartfile](https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md#cartfile):

~~~
github "flowtoolz/SwiftObserver" ~> 2.0
~~~

Via [Cocoapods](https://cocoapods.org): Adjust your [Podfile](https://guides.cocoapods.org/syntax/podfile.html):

~~~ruby
use_frameworks!

target "MyAppTarget" do
  pod "SwiftObserver", "~> 2.0"
end
~~~

Then, in your Swift files:

~~~swift
import SwiftObserver
~~~

# Get Started

> No need to learn a bunch of arbitrary metaphors, terms or types.<br>SwiftObserver is simple: **Objects observe other objects**.

Or a tad more technically: Observed objects send updates to their observers. 

That's it. Just readable code:

~~~swift
dog.observe(Sky.shared.color) { color in
   // marvel at the sky changing its color
}

class Dog: Observer {
   deinit {
      stopObserving() // stops ALL observations this dog is doing
   } 
}
~~~

## Observers

*Observers* adopt the `Observer` protocol, which gives them functions for starting and ending observations.

After starting to observe something, the *Observer* must be alive for the observation to continue. There's no awareness after death in memory. But that's a bit easy to overlook when we start observations from within the `Observer`, which is what we often do:

```swift
class Dog: Observer {
   init {
      observe(Sky.shared.color) { color in
         // for this closure to run, this Dog must live
      }
   }
}
```

An `Observer` may pre-filter updates when starting an observation:

```swift
dog.observe(Sky.shared.color, filter: { $0.isBright }) { color in
   // the sky became bright, let's go for a walk!
}   
```

An *Observer* may also care for just one specific update:

```swift
dog.observe(Sky.shared.color, select: .blue) {
   // the sky became blue, let's go for a walk!
}
```

The above observation closure takes no arguments because it only runs for the specified update, in this case `.blue`.

You may start up to three observations with one combined call:

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
3. Create a [*Mapping*](#mappings). It's an `Observable` that transforms updates from a source *Observable*.

You use all *Observables* the same way. There are just a couple things to note:

- Observing an `Observable` does not have the side effect of keeing it alive. Someone must be its owner and have a strong reference to it. (Note that this won't prevent us from [*chaining Mappings*](#compose-mappings) in a single line.)
- An `Observable` has a property `latestUpdate` of the type of updates it sends. It's a way for clients to actively get the last or "current" update in addition to observing it. ([Combined observations](#combined-observation) also make use of `latestUpdate`.)
- Generally, an `Observable` sends its updates by itself. But anyone can make it send additional updates via `observable.send(update)`.
- An `Observable` has a function `send()` which sends the `latestUpdate` (except where you override `send()` in a [Custom *Observable*](#custom-observables)).

# Memory Management

To avoid abandoned observations piling up in memory, you should stop them before their observer or observable die. One way to do that is to stop each observation when it's no longer needed:

```swift
dog.stopObserving(sky)
```

An even simpler and safer way is to clean up objects right before they die:

```swift
class Dog: Observer {
   deinit {
      stopObserving() // stops ALL observations this dog is doing
   } 
}

class Sky: Observable {
   deinit {
      removeObservers() // stops all observations of this sky
   }
   
   // other implementation ...
}
```

Forgetting your observations would almost never eat up significant memory. But you should know, control and express the mechanics of your code to a degree that prevents systemic leaks.

The above mentioned functions are all you need for safe memory management. If you still want to erase observations that you may have forgotten, there are 3 ways to do that:

1. Stop observing dead observables: `observer.stopObservingDeadObservables()`
2. Remove dead observers from an observable: `observable.removeDeadObservers()`
3. Erase all observations whos observer or observable are dead: `removeAbandonedObservations()`

> Memory management with SwiftObserver is meaningful and safe. There are no contrived constructs like "Disposable" or "DisposeBag". And since you can always flush out orphaned observations, real memory leaks are impossible.

# Variables

## Set a Variable Value

A `Var<Value>` has a property `var value: Value?`. You can set `value` via the `<-` operator.

~~~swift
let text = Var<String>()    // text.value == nil
text.value = "a text"
let number = Var(23)        // number.value == 23
number <- 42                // number.value == 42
~~~

If your `Var.Value` conforms to [`Numeric`](https://developer.apple.com/documentation/swift/numeric), you can apply `+=` and `-=` directly to the `Var`:

```swift
let number = Var(8)
number += 2 // number.value == 10
```

## Variable Updates

A `Var<Value>` sends updates of type `Update<Var.Value?>`, providing the old and new value:

~~~swift
observer.observe(variable) { update in
   if update.old == update.new {
       // update was manually triggered, no value change
   }
}
~~~

A `Var` sends an update whenever its `value` actually changes. Just starting to observe it does **not** trigger an update. This keeps it simple, predictable and consistent, in particular in combination with [*Mappings*](#mappings). You can always call `send()` on a `Var` which would trigger an `Update` in which `old` and `new` are both the current `value`.

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

- Internally, a `Var` appends new values to a queue, so all its observers get to process a value change before the next change takes effect. This is for situations when the `Var` has multiple observers and at least one observer changes the `value` in response to a `value` change.
- A `Var` is a bit more performant than a [custom observable](#custom-observables) because `Var` maintains its own observer list. So if you want to make a super large number of elements in some data structure observable, like particles in a simulation or nodes in a gigantic graph, give those elements a `Var` as an [Owned Messenger](https://github.com/flowtoolz/SwiftObserver/blob/master/Documentation/specific-patterns.md#owned-messenger). Generally, performance is not an issue since all objects are internally hashed.

# Custom Observables

## Declare an Observable

Custom observables just need to adopt the `Observable` protocol and provide the property  `latestUpdate` of the type of updates they wish to send:

~~~swift
class Model: Observable {
    var latestUpdate = Event.didInit
    enum Event { case didInit, didUpdate, willDeinit }
}
~~~

Swift will infer the associated `UpdateType` from `latestUpdate`, so you don't need to write `typealias UpdateType = Event`.

`latestUpdate` would typically return the last update that was sent or a value that indicates that nothing changed. It can be optional and may (always) return `nil`:

~~~swift
class MinimalObservable: Observable {
   let latestUpdate: Int? = nil
}
~~~

## Send Updates

Updates are custom and yet fully typed. An `Observable` sends whatever it likes whenever it wants via `func send(_ update: UpdateType)`. This `Observable` sends optional strings:

~~~swift
class StringObservable: Observable {
   var latestUpdate: String?
    
   init { send("did init") }
   func foo() { send(nil) }
   deinit { send("will deinit") }
}
~~~

## Observable State

Using type `Update`, you can inform observers about state changes, similar to a `Var`:

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

## Create a Mapping

Create a new `Observable` that maps (transforms) the updates of a given *Source Observable*:

~~~swift
let text = Var<String>()
let textLength = text.map { $0.new?.count ?? 0 } // textLength.source === text
// ^^ an Observable that sends Int updates
~~~

You can access the *Source* of a *Mapping* via the `source` property. A *Mapping* holds `source` strongly, just like arrays and other data structures would hold *Observables*. You could rewrite the above example like so:

```swift
let textLength = Var<String>().map { $0.new?.count ?? 0 }
// ^^ textLength.source is of type Var<String>
```

When you want to hold *Observables* weakly, as the *Source* of a *Mapping* or in some data structure, wrap it in [`Weak`](#weak-observables).

As [mentioned earlier](#observables), you use a *Mapping* like any other `Observable`: You hold a strong reference to it somewhere, you stop observing it (not its source) at some point, and you can call `latestUpdate`, `send(_ update: UpdateType)` and `send()` on it. 

## Change the Mapping Source

You can even reset `source`. When you do, the *Mapping* sends an update (with respect to its [prefilter](#mapping-prefilter)). Although the `source` object is replaceable, it is of a specific type that you determine when creating the *Mapping*.

So, you may create a *Mapping* without knowing what `source` objects it will have over its lifetime. Just use an ad-hoc dummy *Source* to create the *Mapping* and, later, reset `source` as often as you want:

```swift
let title = Var<String>().map { // title.source must be a Var<String>
    $0.new ?? "untitled"
}

title.source = someStringVariable
```

Being able to declare *Mappings* as mere transformations, independent of their concrete *Sources*, can help, for instance, in developing view models.

## Mapping Prefilter

You may give a *Prefilter* to a *Mapping*:

```swift
let bigNumberString = Var<Int>().map(prefilter: { ($0.new ?? 0) > 9 }) { 
    "\($0.new ?? 0) is a big number."
}
```

A *Mapping* maps and sends only those *Source* updates that pass its *Prefilter*. Of course, the *Prefilter* cannot apply when you actively request the *Mapping's* `latestUpdate`.

You may use the *Mapping's* optional `prefilter` to see which *Source* updates get through:

```swift
bigNumberString.prefilter?(Update(nil, 9)) ?? true // false
```

## Compose Mappings

You may chain *Mappings* together:

```swift
Var(false).map {                // a Var<Bool> as the source
    $0.new == true ? 1 : 0      // Update<Bool?> -> Int
}.map(prefilter: { $0 > 9 }) {  // only send numbers > 9
    "\($0)"                     // Int -> String
}.map {
    [$0]                        // String -> [String]
}
// ^^ creates a mapping that sends updates of type [String]
```

Chaining *Mappings* together actually composes them into one single *Mapping*. So the `source` of a *Mapping* is never another *Mapping*. It always refers to the original *Source* `Observable`. In the above example, the `source` of the created *Mapping* is a `Var<Bool>`.

## Prebuilt Mappings

### New

When an `Observable` like a `Var<Value>` sends updates of type `Update<Value?>`, you may only care about the `new` component in `Update<Value?>`. In that case, map the `Observable` with `new()`:

~~~swift
let text = Var<String>().new()
// ^^ sends updates of type String?
~~~

### Filter

When you only want to filter and not actually transform updates, map the `Observable` with a filter:

~~~swift
let text = Var<String>().new().filter { ($0?.count ?? 0) > 4 }
// ^^ sends updates of type String?, suppressing nil and short strings
~~~

### Unwrap

A `Var<Value>` has a `value: Value?` and sends updates of type `Update<Value?>`. However, we often don't want to deal with optionals down the line.

You may map **any** `Observable` that sends optional updates onto one that unwraps the optionals with a default value:

~~~swift
let title = Var<String>().new().unwrap("untitled")
// ^^ sends updates of type String, replacing nil with "untitled"
~~~

If you want `unwrap` to never actually send the default, just filter out `nil` values before:

~~~swift
let title = Var<String>().new().filter{ $0 != nil }.unwrap("")
// ^^ sends updates of type String, not sending at all for nil values
~~~

# Weak Observables

When you want to put *Observables* into some data structure but hold them weakly there, you may wrap them in `Weak`:

~~~swift
let number = Var(12)
let weakNumber = Weak(number)

controller.observe(weakNumber) { update in
   // process update
}

var weakNumbers = [Weak<Var<Int>>]()
weakNumbers.append(weakNumber)
~~~

`Weak` is itself an `Observable` and functions as a complete substitute for its wrapped weak `Observable`, which you can access via the `observable` property:

~~~swift
let numberIsAlive = weakNumber.observable != nil
~~~

Since the wrapped `Observable` isn't guaranteed to stay alive, `Weak` has to buffer, and therefore **duplicate**, the `latestUpdate` value. This is a necessary trade-off for holding weak *Observables* in data structures or as a *Mapping Source*.

> Apart from `Weak`, no SwiftObserver type (not even *Mappings*) duplicates the data that is being sent around. This is in stark contrast to other reactive libraries yet without compomising functional aspects.

# Appendix

## Specific Patterns

Patterns that emerged from using SwiftObserver [are documented over here](https://github.com/flowtoolz/SwiftObserver/blob/master/Documentation/specific-patterns.md#specific-patterns).

## <a id="why"></a>Why the Hell Another Reactive Library?

SwiftObserver diverges from convention. It follows the reactive idea in generalizing the *Observer Pattern*. But it doesn't inherit the metaphors, terms, types, or function- and operator arsenals of common reactive libraries. This freed us to create something we love.

What you might like:

- Readable code down to the internals, no arbitrary confusing metaphors
- Super easy to understand and use
- Remove observer from all observables with 1 function call
- No cancellables or tokens to pass around and store
- No irreversible memory leaks, since orphaned observations can always be flushed out via `removeAbandonedObservations()`.
- Ability to pull current update from observable
- Use `<-` operator to directly set variable values
- Recieve old *and* new value from variables
- No distinction between "hot-" and "cold signals" necessary
- All the power of combining without a single dedicated combine function:
    - Other reactive libraries dump at least `merge`, `zip` and `combineLatest` on your brain. [SwiftObserver](https://github.com/flowtoolz/SwiftObserver) avoids all that by offering the most universal form of combined observation, in which the update trigger can be identified. (In the worst case, you must ensure the involved observables send updates of type `Update<Value>`.) All other combine functions could be built on top of that using mappings.
    - Combined observation looks exactly like single observation with more parameters, so it imposes no additional cognitive load.
    - The provided universal combined observation is all you need in virtually all cases. You're free to focus on the meaning of observations and forget its syntax.
- Combined observations send one update per observable. No tuple destructuring necessary.
- Optional variable types plus ability to map onto non-optional types. And no other optionals on generics, which avoids optional optionals and gives you full controll over value and update types.
- Chain mappings together without creating strong references to the mapped objects, without side effects ("mysterious memory magic") and without depending on the existence of the other mappings.
- No delegate protocols to implement
- Variables are `Codable`, so model types are easy to encode and persist.
- Pure Swift code for clean modelling. Not even dependence on `Foundation`.
- Call observation and mappings directly on observables (no mediating property)
- Seemless integration of the *Notifier Pattern*
- No data duplication for combined observations:
    - Combined observation does not duplicate the data of any observed object. When one object sends an update, the involved closures pull update information of other observed objects directly from them.
    - Not having to duplicate data where multiple things must be observed is one of the reasons to use combined observations in the first place. However, some reactive libraries choose to not make full use of object-oriented programming, so far that the combined observables could be value types. This forces these libraries to duplicate data by buffering the updates sent from observables.
- The syntax clearly reflects the intent and metaphor of the *Observer Pattern*. Observers are active subjects while observables are passive objects which are unconcerned about being observed: `observer.observe(observable)`
- SwiftObserver is pragmatic and doesn't overgeneralize the *Observer Pattern*, i.e. it doesn't go overboard with the metaphor of *data streams* but keeps things more object-oriented and simple.
- Custom observables without having to inherit from any class
- Maximum freedom for your architectural- and design choices
- UI bindings are available as [UIObserver](https://github.com/flowtoolz/UIObserver), although that framework is still in its infancy.

What you might not like:

- Not conform to Rx (the semi standard of reactive programming)
- Observers and observables must be objects and cannot be structs. (Of course, variables can hold any type of values and observables can send any type of updates.)
- For now, your code must hold strong references to mappings that you want to observe. In other libraries, mappings are kept alive as a side effect of observing them.

### Focus On Meaning Not On Technicalities

* Because classes have to implement nothing to be observable, you can keep model and logic code independent of any observer frameworks and techniques. If the model layer had to be stuffed with heavyweight constructs just to be observed, it would become a technical issue instead of an easy to change,  meaningful, direct representation of domain-, business- and view logic.
* Unlike established Swift implementations of the Redux approach, [SwiftObserver](https://github.com/flowtoolz/SwiftObserver) lets you freely model your domain-, business- and view logic with all your familiar design patterns and types. There are no restrictions on how you organize and store your app state.
* Unlike established Swift implementations of the Reactive approach, [SwiftObserver](https://github.com/flowtoolz/SwiftObserver) lets you in control of the ancestral tree of your classes. There is not a single class that you have to inherit. Therefore, all your classes can be directly observed, even views and view controllers.

[badge-pod]: https://img.shields.io/cocoapods/v/SwiftObserver.svg?label=version&style=flat-square
[badge-pms]: https://img.shields.io/badge/supports-CocoaPods%20%7C%20Carthage-green.svg?style=flat-square
[badge-languages]: https://img.shields.io/badge/languages-Swift-orange.svg?style=flat-square
[badge-platforms]: https://img.shields.io/badge/platforms-iOS%20%7C%20macOS%20%7C%20tvOS%20%7C%20watchOS%20%7C%20Linux-lightgrey.svg?style=flat-square
[badge-mit]: https://img.shields.io/badge/license-MIT-lightgrey.svg?style=flat-square
