![SwiftObserver](https://raw.githubusercontent.com/flowtoolz/SwiftObserver/master/Documentation/swift.jpg)


# SwiftObserver

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?longCache=true&style=flat-square)](https://github.com/Carthage/Carthage)  [![Pod Version](https://img.shields.io/cocoapods/v/SwiftObserver.svg?longCache=true&style=flat-square)](http://cocoapods.org/pods/SwiftObserver)

SwiftObserver is a lightweight framework for reactive Swift. It's unconventional, [covered by tests](https://github.com/flowtoolz/SwiftObserver/blob/master/Tests/SwiftObserverTests.swift) and designed to be readable, usable, flexible, non-intrusive, simple and safe.

[Reactive programming](https://en.wikipedia.org/wiki/Reactive_programming) adresses the central challenge of implementing a clean architecture: [Dependency Inversion](https://en.wikipedia.org/wiki/Dependency_inversion_principle). SwiftObserver breaks reactive programming down to its essence, which is the [Observer Pattern](https://en.wikipedia.org/wiki/Observer_pattern).

SwiftObserver is just 800 lines of code, but it's also 900 hours of work, thinking it through, letting features go for the sake of simplicity, and battle-testing it [in practice](http://flowlistapp.com).

## Contents

* [Installation](#installation)
* [1. Getting Started](#kiss)
* [2. Memory Management](#memory)
* [3. Variables](#variables)
* [4. Custom Observables](#custom-observables)
* [5. Mappings](#mappings)
* [6. Combined Observation](#combine)
* [Appendix](#appendix)
    *  [Specific Patterns](https://github.com/flowtoolz/SwiftObserver/blob/master/Documentation/specific-patterns.md#specific-patterns)
    *  [Why the Hell Another Reactive Library?](#why)

## <a id="installation"></a>Installation

SwiftObserver can be installed via [Carthage](https://github.com/Carthage/Carthage) and via [Cocoapods](https://cocoapods.org).

### Carthage

Add this line to your Cartfile:

~~~
github 'flowtoolz/SwiftObserver'
~~~

### Cocoapods

Add this line to your Podfile:

~~~ruby
pod 'SwiftObserver'
~~~

## <a id="kiss"></a>1. Getting Started

No need to learn a bunch of arbitrary metaphors, terms or types. SwiftObserver is simple:

> Objects observe other objects.<br>
> Or a tad more technically: Observed objects send updates to their observers. 

That's it. Just readable code:

~~~swift
dog.observe(sky) { color in
   // marvel at the sky changing its color
}
~~~

Observers typically adopt the `Observer` protocol. For an object to be observable, it must conform to protocol `Observable`. You get `Observable` objects in three ways:

1. Instantiate a `Variable`. It's an `Observable` that holds a value and sends value updates.
2. Implement a custom `Observable` class.
3. Create a an `Observable` that maps (transforms) updates from a source `Observable`.

We'll get to each of these. First, something else ...

## <a id="memory"></a>2. Memory Management

There are no Disposables, Cancelables, Tokens, DisposeBags etc to handle. Simply call `stopAllObserving()` on an observer, and its references are removed from everything it observes:

~~~swift
class Controller: Observer {
   deinit { stopAllObserving() }
}
~~~
	
Although you don't need to handle tokens after starting observation, all objects are internally hashed, so performance is never an issue.

There are four more variants of ending observation:

* Stop observing a specific observable: `observer.stopObserving(observable)`
* Stop observing observables that don't exist anymore: `observer.stopObservingDeadObservables()`
* Remove observers that don't exist anymore: `observable.removeDeadObservers()`
* Remove all observers: `observable.removeObservers()`

If you systematically use the above functions or just call `stopAllObserving()` in `deinit` of all observers, observation itself cannot cause memory leaks.

However, should you still feel the need to erase orphaned observations at some point, just call `removeAbandonedObservations()`. It will flush out observations who lost their observable or lost their observers.

## <a id="variables"></a>3. Variables

A variable is of type `Variable<Value>` (alias `Var<Value>`) and holds a `value` of type `Value`. Values must be `Codable` and `Equatable`. Creating a variable without initial value sets the value `nil`. You may use the `<-` operator to set a value:

~~~swift
let number = Var(13)
number.value = 23
number.value = nil
number <- 42
	
let nilText = Var<String>()
~~~
		
An observed variable sends updates of type `Update<Value>` which gives access to the old and new value:
		
~~~swift
observer.observe(variable) { update in
   if update.old == update.new {
       // update was manually triggered, no value change
   }
}
~~~
		
A Variable sends an update whenever its value actually changes. Just starting to observe it does **not** trigger an update. This keeps it simple, predictable and consistent, in particular in combination with mappings.

You can always call `send()` on any observable to trigger an update. In that case, a `Variable` would send an `Update` in which `old` and `new` value are equal.
    
Because a `Var` is `Codable`, objects composed of these variables are still automatically encodable and decodable in Swift 4, simply by adopting the `Codable` protocol:

~~~swift
class Model: Codable {
   private(set) var text = Var("A String Variable")
}
	
let model = Model()
	
if let modelJson = try? JSONEncoder().encode(model) {
   print(String(data: modelJson, encoding: .utf8))
   let decodedModel = try? JSONDecoder().decode(Model.self, from: modelJson)
}
~~~
	
Notice that the `text` object is a `var` instead of a `let`. It cannot be a constant because Swift's decoder must set it.
    
However, other classes are only supposed to set `text.value` and not `text` itself, so we made the setter private via `private(set)`.
	
Be aware that you must hold a reference to an observable object that you want to observe. Observation alone creates no strong reference to it. So observing an ad-hoc created variable makes no sense:

~~~swift
observer.observe(Var("friday 13")) { update in
   // FAIL! The observed variable has local scope and will deinit!
}
~~~
	
A `Variable` appends new values to an internal queue, so all its observers get to process a value change before the next change takes effect. This is important in situations where a variable has multiple observers and at least one of them changes the variable value in reaction to a value change...

## <a id="custom-observables"></a>4. Custom Observables

Custom observables just need to adopt the `Observable` protocol and provide a `var latestUpdate: UpdateType { get }` of the type of updates they wish to send:

~~~swift
class Model: Observable {
    var latestUpdate: Event { return .didNothing }
    enum Event { case didNothing, didUpdate, willDeinit }
}
~~~
	
Swift will infer the update type from `latestUpdate`, so you don't need to write `typealias UpdateType = Event`.

Combined observations sometimes request the latest update from the observed objects. Therefor, observables offer the `latestUpdate` property, which is also a way for clients to actively get the current update state in addition to observing it.

The `latestUpdate` property should typically return the last update that was sent or a value that indicates that nothing changed. But it can be optional and may (always) return `nil`:

~~~swift
class MinimalObservable: Observable {
   var latestUpdate: String? { return nil }
}
~~~

Updates are custom and yet fully typed. A custom observable sends whatever it likes whenever it wants via `send(update)`:

~~~swift
class Model: Observable {
   deinit { send(.willDeinit) }
   // ...
}
~~~
	
Using `latestUpdate` property together with an `UpdateType` that is an `Update`, a custom `Observable` can have a state and be used similar to a `Variable`:

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

It is good practice to remove your observers before you die:

~~~swift
class Model: Observable {
   deinit { removeObservers() }
   // ...
}
~~~

## <a id="mappings"></a>5. Mappings

Create a new observable object by mapping a given one:

~~~swift
let text = Var<String>()
let latestTextLength = text.map { $0.new()?.count ?? 0 }
~~~
	
A mapping is to be used like any other `Observable`:
    
* An observer of the mapping would have to stop observing the mapping itself, not the mapped observable.
* Observing a mapping does not keep it alive. You must hold a strong reference to a mapping that you want to use.
* You can call `send(update)` on a mapping as well as any other function or property declared by `Observable`.
	
### Map `Update` Onto `new` Value

Often we want to observe only the new value of a variable without the old one. The special mapping `new()` maps a value update onto its new value. It is available for all observables whos update type is `Update<_>` (not just for variables):

~~~swift
let text = Var<String>()
let newestTextLength = text.new().map { $0?.count ?? 0 }
~~~
    
### Filter Updates

The `filter(filter)` mapping filters updates:

~~~swift
let available = Var(100)
let scarcityWarning = available.new().unwrap(0).filter { $0 < 10 }
~~~
    
You can actually apply a prefilter with every general mapping:
    
~~~swift
let available = Var(100)
let orderText = available.new().unwrap(0).map(prefilter: { $0 < 10 }) {
    "Send me \(100 - $0) new ones."
}
~~~
    
Observers can also filter single observations without creating any filter mapping at all:
    
~~~swift
let available = Var(100)
let latestAvailable = available.new().unwrap(0)
    
observer.observe(latestAvailable, filter: { $0 < 10 }) { lowNumber in
    // oh my god, less than 10 left!
}
~~~
    
Observers may also observe one specific event via the `select` parameter:
    
~~~swift
let available = Var(100)
let latestAvailable = available.new().unwrap(0)
    
observer.observe(latestAvailable, select: 9) {        
    // oh my god, only 9 left!
}
~~~
    
Note that this response closure does not take any arguments because it only gets called for the specified event.
    
### Unwrap Optional Updates

The value of a `Var` is always optional. That's why you can create one without initial value and also set its value `nil`:

~~~swift
let number = Var<Int>()
number <- nil
~~~
	
However, we often don't want to deal with optionals down the line. You can easily get rid of the optional with the special mapping `unwrap(default)`:
	
~~~swift
let latestUnwrappedNumber = number.new().unwrap(0)

observer.observe(latestUnwrappedNumber) { newInteger in
   // newInteger is not optional!
}
~~~	

The mapping will replace `nil` values with the default. If you want the mapping to never actively send the default, you can apply a filter before it:
    
~~~swift
let latestUnwrappedNumber = number.new().filter({ $0 != nil }).unwrap(0)
~~~	
    

### Chain Mappings Together

A mapping holds a `weak` reference to its mapped observable. You can check whether the observable still exists and even reset it via `mapping.observable`. When a mapping's observabe changes, the mapping sends an update.

You must have some strong reference to a mapped observable because the mapping has none. However, when you chain mappings together, you only have to hold the last mapping strongly because chaining actually combines them into one:

~~~swift
let newUnwrappedText = text.new().unwrap("")
~~~

The intermediate mapping created by `new()` will die immediately, but the resulting `newUnwrappedText` will still live and be fully functional.
    
Because chained mappings get combined into one mapping, the `observable` property on a mapping never refers to another mapping. It always refers to the original mapped `Observable`. In the above example, `newUnwrappedText.observable` would refer to `text`.

One useful consequence of this chaining is that you can create a mapping without an actual underlying observable. Use an ad-hoc dummy observable to create the mapping and set the actual observable later:

~~~swift
let mappedTitle = Var<String>().new().unwrap("untitled")
mappedTitle.observable = titleStringVariable
~~~
    
Being able to define observable mappings independent of any underlying mapped observable can help, for instance, in developing view models.

## <a id="combine"></a>6. Combined Observation

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



## <a id="appendix"></a>Appendix

### Specific Patterns

Patterns that emerged from using SwiftObserver [are documented over here](https://github.com/flowtoolz/SwiftObserver/blob/master/Documentation/specific-patterns.md#specific-patterns).

### <a id="why"></a>Why the Hell Another Reactive Library?

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

#### Focus On Meaning Not On Technicalities

* Because classes have to implement nothing to be observable, you can keep model and logic code independent of any observer frameworks and techniques. If the model layer had to be stuffed with heavyweight constructs just to be observed, it would become a technical issue instead of an easy to change,  meaningful, direct representation of domain-, business- and view logic.
* Unlike established Swift implementations of the Redux approach, [SwiftObserver](https://github.com/flowtoolz/SwiftObserver) lets you freely model your domain-, business- and view logic with all your familiar design patterns and types. There are no restrictions on how you organize and store your app state.
* Unlike established Swift implementations of the Reactive approach, [SwiftObserver](https://github.com/flowtoolz/SwiftObserver) lets you in control of the ancestral tree of your classes. There is not a single class that you have to inherit. Therefore, all your classes can be directly observed, even views and view controllers.
