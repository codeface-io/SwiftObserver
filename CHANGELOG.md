# SwiftObserver Changelog

## v7.0.3

Avoids compiling CombineObserver code on Linux since it's unavailable there

## v7.0.2

Fixes compile issues on iOS, tvOS and watchOS

## v7.0.1

Fixes the unstable version of the dependence on SwiftyToolz

## v7

This update lets go of some hard-earned features in favour of simplicity and shifts focus to native Swift features that have recently filled some gaps.

7.0.0 also expresses a renewed commitment to semantic versioning, in particular since SwiftObserver has moved to the [Codeface GitHub organization](https://github.com/codeface-io). 

### Removed
- `Promise` has been removed as any Promise/Future implementation is obsolete with Swift's latest native concurrency features.
- "One-shot" observations have been removed, as their primary purpose was to enable `Promise`.
- `FreeObserver` and "global" observations have been removed, since they undermined the memory management concept without much benefit
- Any value type-specific extensions of `Var<Value>` have been removed, as the property wrapper now fulfills their purpose.
- Cocoapods support has been dropped.

### Changed
- Protocol `Observable` has been renamed to `ObservableObject` so the new property wrapper could be conveniently named `Observable` and because the protocol is actually a class protocol.
- Author filters `from` and `notFrom` require **non**-optional `AnyAuthor`.

### Improved
- Variable values don't need to be `Codable` anymore. `Var<Value>` remains `Codable` where `Value` is.
- Many small refinements, more or less under the hood.

### Added
- Property wrapper `Observable` allows to make any `var: Value` observable by storing it in a wrapped `Var<Value>`.
- CombineObserver is a new library product of the SwiftObserver package, offering conversion of SwiftObserver's `ObservableObject`s into Combine `Publisher`s.

## v6.2

New functions on `Promise<Value>` that return a mapped new `Promise<MappedValue>`:
* `map(...)`
* `unwrap(default)`
* `new()`

## v6.1

All that's new is also compatible with message authors and ad-hoc transform chains:
* Promises:
  * `Promise<Value>` is a `Messenger<Value>` with some conveniences for async returns
  * Promise composition functions `promise`, `then` and `and`
* Free Observers:
  * Class for adhoc observers `FreeObserver`
  * Global function `observe(...)`, and `observed(...)` on observables, both use `FreeObserver.shared`
  * Global function `observeOnce(...)`, and `observedOnce(...)` on observables, both use `FreeObserver`
* `BufferedObservable`:
  * `BufferedObservable` has been renamed to `ObservableCache`.
  * `ObservableCache` can be created via observable transform `cache()`, which makes `Message` optional only when necessary.
  * `whenCached` retrieves non-optional message from caches that have optional `Message`.
* Observables can stop their observations via `stopBeingObserved()` and `stopBeingObserved(by: observer)`.
* `Weak` is available as observable transform `weak()` and is generally a regular transform object.
* All transforms have mutable property `origin` which is the underlying observable whose messages get transformed. 
* It's possible for an observer to do multiple simultaneous observations of the same observable.


## v6

* Memory management is new:
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

## v5.0.1 Consistent Variable Operators, SPM, Gitter

* Removed
  * Variable string assignment operator
  * Variable number assignment operators

* Changed
  * Reworked Documentation

* Added
  * SPM Support
  * Gitter chat

## v5 Performance, Consistency, Expressiveness, Safety

* **Renamings:**
  * Some memory management functions have been renamed to be more consistent with the overall terminology.
  * The type `Observable.Update` has been renamed to `Observable.Message`.
* **Non-optional generic types:** Variables and messengers do no longer add implicit optionals to their generic value and message types. This makes it possible to create variables with non-optional values and the code is more explicit and consistent.
  * You can still initialize variables and messengers without argument, when you choose to make their value or message type optional.
* **Dedicated observer pools:** All *observables* now maintain their own dedicated pool of *observers*. This improves many aspects:
  * All *observables* get highest performance
  * The whole API is more consistent
  * Custom *observable* implementations are more expressive and customizable
  * Memory management is easier as all *observables*, when they die, stop their observations
* **Meaningful custom observables:** Custom *observables* now adopt the `CustomObservable` protocol. And they provide a `Messenger<Message>` instead of the `latestUpdate`.
  * As long as Swift can't infer the type, you'll also have to specify the associated `Message` type.
* **Consistent variables:**
  * The operators on string- and number variables now work on all combinations of optional and non-optional generic and main types. For instance, string concatenation via `+` works on all pairs of `String`, `String?`, `Var<String>`, `Var<String?>`, `Var<String>?` and `Var<String?>?`.
  * All variables with values of type `String`, `Int`, `Float` and `Double` also have a non-optional property that is named after the value type (`string`, `int` ...).

## v4.2 Messengers

* Added class `Messenger` 
* Added class `ObservabeObject` as a mostly internally used abstract base class for *observables*. `Var`, `Mapping` and `Messenger` now derive from `ObservableObject`.

## v4.1 Consistent Mappings

* Made *Mapping* API more consistent
  * Renamed `prefilter` to `filter`
  * Added `filterMap` to *mappings* as their (mostly internally used) designated transform function
  * Removed `prefilter` argument from `map` function

## v4 Ad Hoc Mapping

* Added Ad Hoc Mapping of observations
* Added filter mapping `select` for all *observables*
* Removed `filter` argument from `observe` function
* Removed `select` argument from `observe` function
* Removed `Log` (back to SwiftyToolz)





