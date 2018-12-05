![SwiftObserver](https://raw.githubusercontent.com/flowtoolz/SwiftObserver/master/Documentation/swift.jpg)

# SwiftObserver

[![badge-pod]](http://cocoapods.org/pods/SwiftObserver) ![badge-pms] ![badge-languages] ![badge-platforms] ![badge-mit]

SwiftObserver is a lightweight framework for reactive Swift. 

It's unconventional, [covered by tests](https://github.com/flowtoolz/SwiftObserver/blob/master/Tests/SwiftObserverTests/SwiftObserverTests.swift) and designed to be readable, usable, flexible, non-intrusive, simple and safe.

[Reactive programming](https://en.wikipedia.org/wiki/Reactive_programming) adresses the central challenge of implementing a clean architecture: [Dependency Inversion](https://en.wikipedia.org/wiki/Dependency_inversion_principle). SwiftObserver breaks reactive programming down to its essence, which is the [Observer Pattern](https://en.wikipedia.org/wiki/Observer_pattern).

SwiftObserver is just 800 lines of production code, but it's also hundreds of hours of work, thinking it through, letting features go for the sake of simplicity, documenting it, unit-testing it, and battle-testing it [in practice](http://flowlistapp.com).

* [Install](#install)
* [Get Started](#get-started)
    * [Observers](#observers)
    * [Observables](#observers)
* [Variables](#variables)
    * [Variable Value](#variable-value)
    * [Variable Updates](#variable-updates) 
    * [Variables are Codable](#variables-are-codable)
    * [More on Variables](#more-on-variables)
* [Custom Observables](#custom-observables)
    * [Declare an Observable](#declare-an-observable)
    * [Send Updates](#send-updates)
    * [Observable State](#observable-state)
* [Mappings](#mappings)
* [Combined Observation](#combined-observation)
* [Memory Management](#memory-management)
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
dog.observe(Sky.shared) { color in
   // marvel at the sky changing its color
}

class Dog: Observer {
   deinit {
      stopObserving() // stops ALL observations this dog is doing
   } 
}
~~~

## Observers

*Observers* adopt the `Observer` protocol, which gives them functions for beginning and ending observations.

After starting to observe some object, the observer must be alive for the observation to continue. There's no awareness after death in memory. But that's a bit easy to overlook when we start observing from within the observer, which is what we often do:

```swift
class Dog: Observer {
   init {
      observe(Sky.shared) { color in
         // for this closure to run, this Dog must live
      }
   }
   
   deinit { stopObserving() }
}
```

## Observables

For objects to be observable, they must conform to `Observable`. 

You get *Observables* in three ways:

1. Create a [*Variable*](#variables). It's an `Observable` that holds a value and sends value updates.
2. Implement a [custom](#custom-observables) `Observable`.
3. Create a [*Mapping*](#mappings). It's an `Observable` that transforms updates from a source *Observable*.

You use all *Observables* the same way. There are just a couple things to note:

- Observing an `Observable` does not have the side effect of keeing it alive. Someone must be its owner and have a strong reference to it. (Note that this won't prevent us from chaining [*Mappings*](#mappings) in a single line.)
- An `Observable` has a property `latestUpdate` of the type of updates it sends. It's a way for clients to actively get the last or "current" update in addition to observing it. ([Combined observations](#combined-observation) also make use of `latestUpdate`.)
- Generally, an `Observable` sends its updates by itself. But anyone can make it send additional updates via `observable.send(update)`.
- An `Observable` has a function `send()` which sends the `latestUpdate` (except where you override `send()` in a [Custom *Observable*](#custom-observables)).

# Variables

## Variable Value

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

A `Var<Value>` sends updates of type `Update<Var.Value>`, providing the old and new value:

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

Create a new `Observable` that maps (transforms) the updates of a given one:

~~~swift
let text = Var<String>()
let textLength = text.map { $0.new?.count ?? 0 } // mapping of `text`
~~~

As mentioned above, you use a *Mapping* like any other `Observable`: You hold a strong reference to it somewhere, stop observing it (not its source) at some point, and you can call `latestUpdate`, `send(update)` and `send()`.

## Map `Update` Onto `new` Value

Often we want to observe only the new value of a variable without the old one. The special mapping `new()` maps a value update onto its new value. It is available for all observables whos update type is `Update<_>` (not just for variables):

~~~swift
let text = Var<String>()
let newestTextLength = text.new().map { $0?.count ?? 0 }
~~~

## Filter Updates

The `filter(filter)` mapping filters updates:

~~~swift
let available = Var(100)
let scarcityWarning = available.new().unwrap(0).filter { $0 < 10 }
~~~

You can actually apply a prefilter with every general mapping:
​    
~~~swift
let available = Var(100)
let orderText = available.new().unwrap(0).map(prefilter: { $0 < 10 }) {
    "Send me \(100 - $0) new ones."
}
~~~

Observers can also filter single observations without creating any filter mapping at all:
​    
~~~swift
let available = Var(100)
let latestAvailable = available.new().unwrap(0)
    
observer.observe(latestAvailable, filter: { $0 < 10 }) { lowNumber in
    // oh my god, less than 10 left!
}
~~~

Observers may also observe one specific event via the `select` parameter:
​    
~~~swift
let available = Var(100)
let latestAvailable = available.new().unwrap(0)
    
observer.observe(latestAvailable, select: 9) {        
    // oh my god, only 9 left!
}
~~~

Note that this response closure does not take any arguments because it only gets called for the specified event.
​    
## Unwrap Optional Updates

The value of a `Var` is always optional. That's why you can create one without initial value and also set its value `nil`:

~~~swift
let number = Var<Int>()
number <- nil
~~~

However, we often don't want to deal with optionals down the line. You can easily get rid of the optional with the special mapping `unwrap(default)`:
​	
~~~swift
let latestUnwrappedNumber = number.new().unwrap(0)

observer.observe(latestUnwrappedNumber) { newInteger in
   // newInteger is not optional!
}
~~~

The mapping will replace `nil` values with the default. If you want the mapping to never actively send the default, you can apply a filter before it:
​    
~~~swift
let latestUnwrappedNumber = number.new().filter({ $0 != nil }).unwrap(0)
~~~


## Chain Mappings Together

A mapping holds a `weak` reference to its mapped observable. You can check whether the observable still exists and even reset it via `mapping.observable`. When a mapping's observabe changes, the mapping sends an update.

You must have some strong reference to a mapped observable because the mapping has none. However, when you chain mappings together, you only have to hold the last mapping strongly because chaining actually combines them into one:

~~~swift
let newUnwrappedText = text.new().unwrap("")
~~~

The intermediate mapping created by `new()` will die immediately, but the resulting `newUnwrappedText` will still live and be fully functional.
​    
Because chained mappings get combined into one mapping, the `observable` property on a mapping never refers to another mapping. It always refers to the original mapped `Observable`. In the above example, `newUnwrappedText.observable` would refer to `text`.

One useful consequence of this chaining is that you can create a mapping without an actual underlying observable. Use an ad-hoc dummy observable to create the mapping and set the actual observable later:

~~~swift
let mappedTitle = Var<String>().new().unwrap("untitled")
mappedTitle.observable = titleStringVariable
~~~

Being able to define observable mappings independent of any underlying mapped observable can help, for instance, in developing view models.

# Combined Observation

You can observe up to three observable objects:

~~~swift
let newText = text.new()
let number = Var(42)
let model = Model()
	
observer.observe(newText, number, model) { textValue, numberUpdate, event in
   // process new combination of String, number update and event
}
~~~

This does not create any new observable object, and the observer won't need to remove itself from anything other than the three observed objects. Of course, memory management is no concern if the observer calls `stopAllObserving()` at some point.

You won't need to distinguish different combining functions.

* Other reactive libraries dump at least `merge`, `zip` and `combineLatest` on your brain. [SwiftObserver](https://github.com/flowtoolz/SwiftObserver) avoids all that by offering the most universal form of combined observation, in which the update trigger can be identified. (In the worst case, you must ensure the involved custom observables send updates of type `Update<_>`.) All other combine functions could be built on top of that using mappings.
	
* Anyway, this universal mutual observing is all you need in virtually all cases. You're free to focus on the meaning of combined observations and forget the syntax!

This combined observation does not duplicate the data of any observed object. When one object sends an update, the involved closures pull update information of other observed objects directly from them.

Not having to duplicate data where multiple things must be observed is one of the reasons to use these combined observations. However, some reactive libraries choose to not make full use of object-oriented programming, so far that the combined observables could be value types. This forces these libraries to duplicate data by buffering the data sent from observables.

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
   
   // custom observable implementation ...
}
```

Forgetting your observations would almost never eat up significant memory. But you should know, control and explicate the mechanics of your code to a degree that prevents systemic leaks.

The above mentioned functions are all you need for safe memory management. If you still want to erase observations that you may have forgotten, there are 3 ways to do that:

1. Stop observing dead observables: `observer.stopObservingDeadObservables()`
2. Remove dead observers from an observable: `observable.removeDeadObservers()`
3. Erase all observations whos observer or observable are dead: `removeAbandonedObservations()`

> Memory management with SwiftObserver is meaningful and safe. There are no contrived constructs like "Disposable" or "DisposeBag". And since you can always flush out orphaned observations, real memory leaks are impossible.

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
- All the power of combining without a single dedicated combine function
- Combined observations send one update per observable. No tuple destructuring necessary.
- Optional variable types plus ability to map onto non-optional types. And no other optionals on generics, which avoids optional optionals and gives you full controll over value and update types.
- Chain mappings together without creating strong references to the mapped objects, without side effects ("mysterious memory magic") and without depending on the existence of the other mappings.
- No delegate protocols to implement
- Variables are `Codable`, so model types are easy to encode and persist.
- Pure Swift code for clean modelling. Not even dependence on `Foundation`.
- Call observation and mappings directly on observables (no mediating property)
- Seemless integration of the *Notifier Pattern*
- No data duplication for combined observations
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
