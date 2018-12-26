# SwiftObserver Changelog

# v5

## v5.0

### v5.0.1

Removed

* Variable string assignment operator
* Variable number assignment operators

Changed

* Reworked Documentation

Added

* SPM Support
* Gitter chat

### v5.0.0

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
* **Consistent variable operators:** The operators on string- and number variables now work on all combinations of optional and non-optional generic and main types. For instance, string concatenation via `+` works on all pairs of `String`, `String?`, `Var<String>`, `Var<String?>`, `Var<String>?` and `Var<String?>?`.
  * All variables with values of type `String`, `Int`, `Float` and `Double` also have a non-optional property that is named after the value type (`string`, `int` ...).
