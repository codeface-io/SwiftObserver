# SwiftObserver

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?longCache=true&style=flat-square)](https://github.com/Carthage/Carthage)  [![Pod Version](https://img.shields.io/cocoapods/v/SwiftObserver.svg?longCache=true&style=flat-square)](http://cocoapods.org/pods/SwiftObserver)

SwiftObserver is a reactive programming framework for pure Swift. It is designed to be ...

* :white_check_mark: usable  
* :white_check_mark: flexible  
* :white_check_mark: non-intrusive  
* :white_check_mark: readable  
* :white_check_mark: simple  
* :white_check_mark: safe

There are some [unit tests of SwiftObserver](https://github.com/flowtoolz/SwiftObserver/blob/master/Tests/SwiftObserverTests.swift), which also demonstrate its use.

## Contents

* [Installation](#installation)
* [1. Keep It Simple Sweety](#kiss)
* [2. The Easiest Memory Management](#memory)
* [3. Variables](#variables)
* [4. Custom Observables](#custom-observables)
* [5. Create Observables as Mappings of Others](#mappings)
* [6. One Combine To Rule Them All](#combine)
* [7. Messenger? Notifier? Dispatcher? It's All Observation](#messenger)
* [8. Why the Hell Another Reactive Library?](#why)

## <a id="installation"></a>Installation

SwiftObserver can be installed via [Carthage](https://github.com/Carthage/Carthage) and via [Cocoapods](https://cocoapods.org).

### Carthage

Add this line to your Cartfile:

~~~
github "flowtoolz/SwiftObserver"
~~~

### Cocoapods

Add this line to your Podfile:

~~~
pod 'SwiftObserver'
~~~

Now let's look at some of the goodies of SwiftObserver ...

## <a id="kiss"></a>1. Keep It Simple Sweety

* No need to learn a bunch of arbitrary metaphors, terms or types.

	Observers observe observable objects. Or the other way around: Observed objects send updates to their observers.
	
	That's it. Just readable code:

	~~~swift
	observer.observe(observable)
	{
	   update in
	
	   // respond to update
	}
	~~~

* SwiftObserver's type system is radically simple:
    <img src="https://raw.githubusercontent.com/flowtoolz/SwiftObserver/master/Documentation/TypeDependencies.jpg" style="width:100%;max-width:400px;display:block;margin-left:auto;margin-right:auto"/>

* Any object can observe. But observers who adopt the `Observer` protocol can use more convenient functions for starting and ending observation.

* All observables conform to the `Observable` protocol. There are three ways to make use of `Observable`:
	
    1. Use a pre-built `Observable`:
        * `Variable<Value>`
        * `Messenger<Message>`

    2. Implement your own custom `Observable`

    3. Create a new `Observable` by mapping an existing one

    We'll get to each of these. First, something else...

## <a id="memory"></a>2. The Easiest Memory Management

* There are no Disposables, Cancelables, Tokens, DisposeBags etc to handle. Simply call `stopAllObserving()` on an observer, and its references are removed from everything it observes:

	~~~swift
	class Controller: Observer
	{
	   deinit { stopAllObserving() }
	}
	~~~

* Observers can also stop observing an observable object via `observer.stopObserving(observable)`.
* Another way to remove observers from an observable object is to call `observable.removeAllObservers()`.
* To actively remove dead observer references from an observable object, you may call `observable.removeNilObservers()`.
* Although you don't need to handle tokens after adding an observer, all objects are internally hashed, so performance is never an issue.
* Even if you forget to remove observers from observables, you likely won't run into problems because abandoned obervervations get pruned internally at every opportunity.

## <a id="variables"></a>3. Variables

* A variable is of type `Variable<Value>` (alias `Var<Value>`) and holds a `value` of type `Value`. Values must be `Codable` and `Equatable`. Creating a variable without initial value sets the value `nil`. You may use the `<-` operator to set a value:

	~~~swift
	let number = Var(13)
	number.value = 23
	number.value = nil
	number <- 42
	
	let nilText = Var<String>()
	~~~
		
* An observed variable sends updates of type `Update<Value>` which gives access to the old and new value:
		
	~~~swift
	observer.observe(variable)
	{
	   update in
	
	   if update.new != update.old
	   {
	      // respond to value change
	   }
	}
	~~~
		
* Variables send an update upon starting observation in which case `new` and `old` both hold the current value. Of course, they also send an update whenever their value actually changes.
* Because a `Var` is `Codable`, objects composed of these variables are still automatically encodable and decodable in Swift 4, simply by adopting the `Codable` protocol:

	~~~swift
	class Model: Codable
	{
	   let text = Var("A String Variable")
	}
	
	let model = Model()
	
	if let modelData = try? JSONEncoder().encode(model)
	{
	   print(String(data: modelData, encoding: .utf8))
	}
	~~~
	
* Be aware that you must hold a reference to a variable that you want to observe. Observation alone creates no strong reference to the observed object. So observing an ad-hoc created variable makes no sense:

	~~~swift
	observer.observe(Var("friday 13"))
	{
	   update in
		
	   // FAIL! The observed variable has local scope and will deinit!
	}
	~~~

## <a id="custom-observables"></a>4. Custom Observables

* Custom observables just need to adopt the `Observable` protocol and provide a `var latestUpdate: UpdateType { get }` of the type of updates they wish to send:

    ~~~swift
    class Model: Observable
    {
        var latestUpdate: Event { return .didNothing }
	   
        enum Event { case didNothing, didUpdate, willDeinit }
    }
    ~~~
	
	Swift will infer the update type from `latestUpdate`, so you don't need to write `typealias UpdateType = Event`.

* Combined observations sometimes request the latest update from the observed objects. Therefor, observables offer the `latestUpdate` property, which is also a way for clients to actively get the current update state in addition to observing it.

* The `latestUpdate` property should typically return the last update that was sent or a value that indicates that nothing changed. But it can be optional and may (always) return `nil`:

	~~~swift
	class MinimalObservable: Observable
	{
	   var latestUpdate: String? { return nil }
	}
	~~~

* Updates are custom and yet fully typed. A custom observable sends whatever it likes whenever it wants via `send(update)`:

	~~~swift
	class Model: Observable
	{
	   deinit { send(.willDeinit) }
	   
	   // ...
	}
	~~~
	
* Using the `latestUpdate` property together with an `UpdateType` that is an `Update<_>`, a custom observable can have a state and be used like a variable:

	~~~swift
	class Model: Observable
	{
	   var latestUpdate: Update<String?>
	   {
	      return Update(state, state)
	   }
	   
	   var state: String?
	   {
	      didSet
	      {
	         if oldValue != state
	         {
	            send(Update(oldValue, state))
	         }
	      }
	   }
	}
	~~~
	

## <a id="mappings"></a>5. Create Observables as Mappings of Others

* Create a new observable object by mapping a given one:

	~~~swift
	let text = Var<String>()
	        
	let newestText = text.map { $0.new }
	        
	let newestTextLength = newestText.map { $0?.count ?? 0 }
	~~~

* Often we want to observe only the new value of a variable without the old one. Above, we mapped a value update onto its new value. This mapping is already available for all observables whos update type is `Update<_>` (not just for variables). The above code can be written as:

	~~~swift
	let text = Var<String>()
	        
	let newestTextLength = text.new().map { $0?.count ?? 0 }
	~~~
	
* A mapping holds a `weak` reference to its mapped observable. You can check whether a mapping still has its observable via `mapping.hasObservable`.
	
* A mapping is to be used like any other `Observable`:
    * An observer of the mapping would have to stop observing the mapping itself, not the mapped observable.
    * Observing a mapping does not keep it alive. You must hold a strong reference to a mapping that you want to use.
    * You can call `send(update)` on a mapping as well as any other function or property declared by `Observable`.

### Unwrap

* The value of a `Var` is always optional. That's why you can create one without initial value and also set its value `nil`:

	~~~swift
	let number = Var<Int>()
	number <- nil
	~~~
	
	However, we often don't want to deal with optionals down the line. You can easily get rid of the optional with the special mapping `unwrap(default)`:
	
	~~~swift
	let newestNumber = number.new().unwrap(0)

	observer.observe(newestNumber)
	{
	   newInteger in
		
	   // newInteger is not optional!
	}
	~~~	

* The default in `unwrap(default)` is only required for `latestUpdate` in accordance with the `Observable` protocol. It will only come into play when the unwrapped observable didn't trigger the update but just returned its latest update. Of course, this can only happen in combined observations (see next section).

	The above example is just a single observation and only `newestNumber` can trigger the update. When the `value` of `newestNumber` is set to `nil`, the `unwrap` mapping sends nothing to its obervers, not even the default `0`. So when `newInteger` is zero, the observer knows that it's a real value and not just a replacement for `nil`.

## <a id="combine"></a>6. One Combine To Rule Them All

* You can observe up to three observable objects:

	~~~swift
	let newText = text.new()
	let number = Var(42)
	let model = Model()
	
	observer.observe(newText, number, model)
	{
	   textValue, numberUpdate, event in
		
	   // process new combination of String, number update and event
	}
	~~~
	
    This does not create any new observable object, and the observer won't need to remove itself from anything other than the three observed objects. Of course, memory management is no concern if the observer calls `stopAllObserving()` at some point.

* You won't need to distinguish different combining functions.

	Other reactive libraries dump at least `merge`, `zip` and `combineLatest` on your brain. [SwiftObserver](https://github.com/flowtoolz/SwiftObserver) avoids all that by offering the most universal form of combined observation, in which the update trigger can be identified. (In the worst case, you must ensure the involved custom observables send updates of type `Update<_>`.) All other combine functions could be built on top of that using mappings.
	
	 Anyway, this universal mutual observing is all you need in virtually all cases. You're free to focus on the meaning of combined observations and forget the syntax!

* This combined observation does not duplicate the data of any observed object. When one object sends an update, the involved closures pull update information of other observed objects directly from them.

	Not having to duplicate data where multiple things must be observed is one of the reasons to use these combined observations. However, some reactive libraries choose to not make full use of object-oriented programming, so far that the combined observables could be value types. This forces these libraries to duplicate data by buffering the data sent from observables.
	
## <a id="messenger"></a>7. Messenger? Notifier? Dispatcher? It's All Observation

* When observer and observable need to be more decoupled, it is common to use a mediating observable through which any object can anonymously send updates. An example of this mediator is Foundation's `NotificationCenter`.

    This extension of the observer pattern is sometimes called *Messenger*, *Notifier*, *Dispatcher*, *Event Emitter* or *Decoupler*. Its main differences to direct observation are:
    
    - An observer may indirectly observe multiple other objects.
    - Observers don't care who triggered an update.
    - Observer types don't need to depend on the types that trigger updates.
    - Updates function more as messages (notifications, events) than as artifacts of raw data.
    - Every object can trigger updates, without adopting any protocol.
    - Multiple objects may share the same update type and trigger the same updates.

* You could simply use a global custom `Observable` as a mediating messenger. But SwiftObserver's generic class `Messenger<Message>` has a bit more to offer and plays well together with the `Observer` protocol.
    
* You may use the global `textMessenger` of type `Messenger<String>`:

    ~~~swift
    observer.observe(textMessenger)
    {
        textMessage in
        
        // respond to text message
    }
    
    textMessenger.send("some message")
    ~~~
    
* An `Observer` can also observe one specific message sent by some messenger:

    ~~~swift
    observer.observe("event name", from textMessenger)
    {
        // respond to "event name"
    }
    
    textMessenger.send("event name")
    ~~~

    Note that this response closure does not take any arguments because it only gets called for the specified message.
    
* You may also instantiate your own messenger as some `Messenger<Message>`:

    ~~~swift
    enum Event { case none, userError, techError }
        
    let eventMessenger = Messenger<Event>(.none)
    
    observer.observe(eventMessenger)
    {
        event in
        
        // repond to event
    }
    
    eventMessenger.send(.techError)
    ~~~

    The initializer of `Messenger<Message>` takes a `Message` that will be returned by `messenger.latestUpdate` as long as no update (message) has been sent.
    
     After at least one message has been sent, `latestUpdate` will return the last message, which you can also get via `messenger.latestMessage`.
    
* Since `Messenger<Message>` conforms to the `Observable` protocol, you can include messengers in combined observations:

    ~~~swift
    observer.observe(text, number, messenger)
    {
        textUpdate, numberUpdate, message in
        
        // respond to text update, number update and message
    }
    ~~~

## <a id="why"></a>8. Why the Hell Another Reactive Library?

SwiftObserver diverges from convention. It follows the reactive idea in generalizing the observer pattern. But it doesn't inherit the metaphors, terms, types, or function- and operator arsenals of common reactive libraries. This freed us to create something we love.

What you might like:

- Readable code down to the internals, no arbitrary confusing metaphors
- Super easy to understand and use
- Remove observer from all observables with 1 function call
- No cancellables or tokens to pass around and store
- Ability to pull current update from observable
- Memory gets cleared even if the client/observer forgets to manage it
- Use `<-` operator to directly set variable values
- Recieve old *and* new value from variables
- No distinction between "hot-" and "cold signals" necessary
- All the power of combining without a single dedicated combine function
- Combined observations send one update per observable. No tuple destructuring necessary.
- Optional variable types plus ability to map onto non-optional types
- Variables are `Codable`
- Call observation and mappings directly on observables (no mediating property)
- Seemless integration of the *Notifier Pattern*
- No data duplication for combined observations
- Custom observables without having to inherit from any class
- Maximum freedom for your architectural- and design choices

What you might not like:

- Not conform to Rx (the semi standard of reactive programming)
- Not many operators included
- No UI bindings included
- Observers and observables must be objects and cannot be structs. (Of course, variables can hold any type of values and observables can send any type of updates.)
- For now, your code must hold strong references to mappings that you want to observe. In other libraries, mappings are kept alive as a side effect of observing them.

### Ending Note: Focus On Meaning Not On Technicalities

* Because classes have to implement nothing to be observable, you can keep model and logic code independent of any observer frameworks and techniques. If the model layer had to be stuffed with heavyweight constructs just to be observed, it would become a technical issue instead of an easy to change,  meaningful, direct representation of domain-, business- and view logic.
* Unlike established Swift implementations of the Redux approach, [SwiftObserver](https://github.com/flowtoolz/SwiftObserver) lets you freely model your domain-, business- and view logic with all your familiar design patterns and types. There are no restrictions on how you organize and store your app state.
* Unlike established Swift implementations of the Reactive approach, [SwiftObserver](https://github.com/flowtoolz/SwiftObserver) lets you in control of the ancestral tree of your classes. There is not a single class that you have to inherit. Therefore, all your classes can be directly observed, even views and view controllers.
* There are no protocols that you have to implement. Your code remains focused and decoupled. Because there are no delegate protocols, there is no limit to how many things an observer can observe or to how many observers a thing can have.
