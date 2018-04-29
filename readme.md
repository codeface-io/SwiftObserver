# SwiftObserver

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?longCache=true&style=flat-square)](https://github.com/Carthage/Carthage)  [![Pod Version](https://img.shields.io/cocoapods/v/SwiftObserver.svg?longCache=true&style=flat-square)](http://cocoapods.org/pods/SwiftObserver)

<img src="https://raw.githubusercontent.com/flowtoolz/SwiftObserver/master/Documentation/TypeDependencies.jpg" style="width:100%;max-width:640px;display:block;margin-left:auto;margin-right:auto"/>

SwiftObserver is a reactive programming framework for pure Swift. It is designed to be usable, flexible, non-intrusive, readable, simple and safe.

There are some [unit tests of SwiftObserver](https://github.com/flowtoolz/SwiftObserver/blob/master/Tests/SwiftObserverTests.swift), which also demonstrate its use.

## Contents

* [Installation](#installation)
* [1. Keep It Simple Sweety](#kiss)
* [2. The Easiest Memory Management](#memory)
* [3. Variables](#variables)
* [4. Create Variables as Combinations of Others](#pair-variables)
* [5. Custom Observables](#custom-observables)
* [6. Create Observables as Mappings of Others](#mappings)
* [7. One Combine To Rule Them All](#combine)
* [Why the Hell Another Reactive Library?](#why)

## <a name="installation"></a>Installation

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

## <a name="kiss"></a>1. Keep It Simple Sweety

* No need to learn a bunch of arbitrary metaphors, terms or types.

	Observers observe observable objects, and observed objects send updates to their observers. That's it. Just readable code:

	~~~swift
	observer.observe(observable)
	{
	   update in
	
	   // respond to update
	}
	~~~

* Any object can observe. But observers who adopt the `Observer` protocol can use more convenient functions for starting and ending observation.
* There are 3 kinds of observable objects:

	1. Variables, wich may be composed of other variables
		
	2. Custom observables, which conform to the `Observable` protocol
		
	3. Mappings from other observable objects

	We'll get to each of these. First, something else...

## <a name="memory"></a>2. The Easiest Memory Management

* There are no Disposables, Cancelables, Tokens, DisposeBags etc to handle. Simply call `stopAllObserving()` on an observer, and its references are removed from everything it observes:

	~~~swift
	class Controller: Observer
	{
	   deinit { stopAllObserving() }
	}
	~~~

* Observers can also stop observing an observable object via `observer.stopObserving(observable)`.
* Another way to remove observers from an observable object is to call `observable.removeAllObservers()`.
* To actively remove dead observer references from a variable, you may call `variable.removeNilObservers()`.
* Although you don't need to handle "disposables" or tokens after adding an observer, all objects are internally hashed, so performance is never an issue.
* Even if you forget to remove observers from observables, you likely won't run into problems because abandoned obervervings get pruned internally at every opportunity.

## <a name="variables"></a>3. Variables

* A variable is of type `Variable` (alias `Var`) and holds a value in its `value` property. Values must be `Codable` and `Equatable`. Creating a variable without initial value sets the value `nil`. You may use the `<-` operator to set a value:

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


## <a name="pair-variables"></a>4. Create Variables as Combinations of Others

* You can observe combinations of variables, which are actually recursive variable pairs. Like a simple variable of type `Var`, a `PairVariable` sends updates of type `Update<Value>`, only here the value is a `Pair<Value1, Value2>`, which holds values for both combined variables:

	~~~swift
	let textAndNumber = text + number

	observer.observe(textAndNumber)
	{
	   update in
		
	   let newText = update.new.left
	   let newNumber = update.new.right
		
	   // respond to latest text and number values
	}
	~~~
	
* Like with variables of type `Var`, you must hold a reference to a combined variable that you want to observe. The example above assumes that `textAndNumber` remains in scope during observation. However, observing an ad-hoc variable combination makes no sense at all:

	~~~swift
	observer.observe(Var("friday") + Var(13))
	{
	   update in
		
	   // FAIL! The observed variable has local scope and will deinit!
	}
	~~~

* You can nest and store combined variables and set their values:

	~~~swift
	let combinedVariable = Var(0.75) + Var("text") + Var(10)
	
	combinedVariable <- Pair(Pair(0.33, "new"), 42)
	~~~

* You may use the `+++` operator for combining variable values. The last line from above can be written as: 

	~~~swift
	combinedVariable <- 0.33 +++ "new" +++ 42
	~~~	
	
* A variable combination stores no value of its own. Instead it reads and sets the values of the variables it combines. So the above line changes the values of all three involved variables and would update all observers of these three.

* A variable combination sends an update whenever one of the combined variables changes its value. Since variables send the old and new values in their updates, update handlers can easily determine the one variable that triggered the update.

* A variable combination holds strong references to its combined variables. So you don't need to hold references to the combined variables - only to the resulting combination.

## <a name="custom-observables"></a>5. Custom Observables

* Custom observables just need to adopt the `CustomObservable` protocol (alias `Observable`) and provide a `var update: UpdateType { get }` of the type of updates they wish to send:

    ~~~swift
    class Model: Observable
    {
        var update: Event { return .didNothing }
	   
        enum Event { case didNothing, didUpdate, willDeinit }
    }
    ~~~
	
	Swift will infer the `update` type so you don't need to write `typealias UpdateType = Event`.

* Combined variables as well as combined observation sometimes request the current update state from their constituting observables. Therefor, observables offer the `update` property, which is also a way for other clients to actively get the update state in addition to observing it.

* The `update` property should typically return the last update that was sent or a value that indicates that nothing changed. But it can be optional and may (always) return `nil`:

	~~~swift
	class MinimalObservable: Observable
	{
	   var update: String? { return nil }
	}
	~~~

* Updates are custom and yet fully typed. A custom observable sends whatever it likes whenever it wants via `updateObservers(update)`:

	~~~swift
	class Model: Observable
	{
	   deinit { updateObservers(.willDeinit) }
	   
	   // ...
	}
	~~~
	
* Using the `update` property together with an `UpdateType` that is an `Update<_>`, a custom observable can have a state and be used like a variable:

	~~~swift
	class Model: Observable
	{
	   var update: Update<String?>
	   {
	      return Update(state, state)
	   }
	   
	   var state: String?
	   {
	      didSet
	      {
	         if oldValue != state
	         {
	            updateObservers(Update(oldValue, state))
	         }
	      }
	   }
	}
	~~~
	

## <a name="mappings"></a>6. Create Observables as Mappings of Others

* Create a new observable object by mapping a given one:

	~~~swift
	let text = Var<String>()
	        
	let latestText = text.map { $0.new }
	        
	let latestTextLength = latestText.map { $0?.count ?? 0 }
	~~~

* Often we want to observe only the new value of a variable without the old one. Above, we mapped a value update onto its new value. This mapping is already available for all observables whos update type is `Update<_>` (not just for variables). The above code can be written as:

	~~~swift
	let text = Var<String>()
	        
	let latestTextLength = text.new().map { $0?.count ?? 0 }
	~~~
	
* The value of a `Var` is always optional. That's why you can create one without initial value and also set its value `nil`:

	~~~swift
	let number = Var<Int>()
	number <- nil
	~~~
	
	However, we often don't want to deal with optionals down the line. You can easily get rid of the optional by providing a default value:
	
	~~~swift
	let latestNumber = number.new().unwrap(0)

	observer.observe(latestNumber)
	{
	   newInteger in
		
	   // newInteger is not optional!
	}
	~~~	

* This default is only required for the `update` property every observable provides in accordance with the `ObservableProtocol`. It will only come into play when the unwrapped observable didn't trigger the update but just provided its current `update` state. Of course, this can only happen where multiple observables are being observed (combined observation or observation of combined variable).

	The above example is not a combined observation, so only `latest number` can trigger the update. When the `value` of `latestNumber` is set to `nil`, the `unwrap` mapping sends nothing to its obervers, not even the default `0`. So when `newInteger` is zero, the observer knows that it's a real value and not just a replacement for `nil`.

## <a name="combine"></a>7. One Combine To Rule Them All

* In addition to creating a new variable by combining others, you can also observe multiple observable objects of any type and without creating a new object:

	~~~swift
	let newText = text.new()
	let numberAndText = number + text
	let model = Model()
	
	observer.observe(newText, numberAndText, model)
	{
	   textValue, numberAndTextUpdate, event in
		
	   // process new combination of String, pair update and event
	}
	~~~
	
* This does not create any combined observable, and the observer won't need to remove itself from anything other than the 3 observed variables. Of course, memory management is no concern if the observer calls `stopAllObserving()` at some point.

* You won't need to distinguish different combining functions.

	Other reactive libraries dump at least `merge`, `zip` and `combineLatest` on your brain. [SwiftObserver](https://github.com/flowtoolz/SwiftObserver) avoids all that by offering the most universal form of combined observation, in which the update trigger can be identified. (In the worst case, you must ensure the involved custom observables send updates of type `Update<_>`.) All other combine functions could be built on top of that using mappings.
	
	 Anyway, this universal mutual observing is all you need in virtually all cases. You're free to focus on the meaning of combined observations and forget the syntax!

* This combined observation does not duplicate the data of any observed object. When one object sends an update, the involved closures pull update information of other observed objects directly from them.

	Not having to duplicate data where multiple things must be observed is one of the reasons to use these combined observations. However, some reactive libraries choose to not make full use of object-oriented programming, so far that the combined observables could be value types. This forces these libraries to duplicate data by buffering the data sent from observables.

## <a name="why"></a>Why the Hell Another Reactive Library?

SwiftObserver diverges from convention. It follows the reactive idea in generalizing the observer pattern. But it doesn't inherit the metaphors, terms, types, or function- and operator arsenals of common reactive libraries. This freed us to create something we love.

What you might like:

- Readable code down to the internals, no arbitrary confusing metaphors
- Super easy to understand and use
- Remove observer from all observables with 1 function call
- No cancellables or tokens to pass around and store
- Ability to pull current update from observable
- Memory gets cleared even if the client/observer forgets to manage it
- Combine variables with `+`
- Set combined values back into combined variables
- Use `<-` operator to directly set variable values
- Recieve old *and* new value from variables
- No distinction between "hot-" and "cold signals" necessary
- All the power of combining without a single dedicated combine function
- Optional variable types plus ability to map onto non-optional types
- Variables are `Codable`
- Call observation and mappings directly on observables (no mediating property)
- No data duplication, no internal buffers
- Custom observables without having to inherit from any class
- Maximum freedom for your architectural- and design choices

What you might not like:

- Not conform to Rx (the semi standard of reactive programming)
- Not many operators included
- No UI bindings included
- Observers and observables must be objects and cannot be structs. (Of course, variables can hold any type of values and observables can send any type of updates.)
- For now, your code must hold strong references to observables that you want to observe. In other libraries, variable combinations or mappings would be kept alive as a side effect of being observed.

### Ending Note: Focus On Meaning Not On Technicalities

* Because classes have to implement nothing to be observable, you can keep model and logic code independent of any observer frameworks and techniques. If the model layer had to be stuffed with heavyweight constructs just to be observed, it would become a technical issue instead of an easy to change,  meaningful, direct representation of domain-, business- and view logic.
* Unlike established Swift implementations of the Redux approach, [SwiftObserver](https://github.com/flowtoolz/SwiftObserver) lets you freely model your domain-, business- and view logic with all your familiar design patterns and types. There are no restrictions on how you organize and store your app state.
* Unlike established Swift implementations of the Reactive approach, [SwiftObserver](https://github.com/flowtoolz/SwiftObserver) lets you in control of the ancestral tree of your classes. There is not a single class that you have to inherit. Therefore, all your classes can be directly observed, even views and view controllers.
* There are no protocols that you have to implement. Your code remains focused and decoupled. Because there are no delegate protocols, there is no limit to how many things an observer can observe or to how many observers a thing can have.
