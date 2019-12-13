# Specific Patterns

This document describes a few patterns that emerged from usage.

In general, SwiftObserver meets almost all needs for callbacks and continuous propagation of data up the control hierarchy (against the direction of control). Typical applications are the propagation of data from domain model to use cases, from use cases to view models, from view models to views, and from views to view controllers.

## The Messenger Pattern

When *observer* and *observable* need to be more decoupled, it is common to use a mediating *observable* through which any object can anonymously send *messages*. An example of this mediator is [`NotificationCenter`](https://developer.apple.com/documentation/foundation/notificationcenter).

This use of the *Observer Pattern* is sometimes called *Messenger*, *Notifier*, *Dispatcher*, *Event Emitter* or *Decoupler*. Its main differences to direct observation are:

- The actual *observable*, which is the messenger, sends no *messages* by itself.
- Every object can trigger *messages*, without adopting any protocol.
- Multiple sending objects trigger the same type of *messages*.
- An *observer* may indirectly observe multiple other objects through one observation.
- *Observers* don't care as much who triggered a *message*.
- *Observer* types don't need to depend on the types that trigger *messages*.

SwiftObserver's class `Messenger` covers the messenger pattern directly.

## Stored Messenger

A *Stored Messenger* is the bare bone pattern tht defines `Observable`. However, sometimes we have to implement observability more implicitly, without conforming to `Observable`.

Instead of making a class `C` directly observable through `Observable`, you just give it a messenger as a property. `C` sends its updates via its messenger, and observers of `C` actually observe the messenger of `C`:

~~~swift
class C {
   let messenger = Messenger<Event?>() // C is indirectly observable via messenger
}
~~~

And why would you want that? Avoiding explicit conformane to `Observable` helps in two scenarios ...

### 1. Require Specific Observability in an Interface

We want to declare a variable or constant as conforming to an interface (let's say `Database`) specifying (among other functionality) observability with a specific message type (say `DatabaseUpdate`).

#### Challenge

We don't want to define an abstract base class because objects conforming to the interface should be able to derive from their own (and more meaningful) class (like `ICloudDatabase`).

Now, we would want to define a protocol like this:

~~~swift
protocol Database: Observable where Message == DatabaseUpdate {
   // declare other database functionality
}
~~~

But this protocol could only be used as a generic constraint because it has an associated type requirement (Swift doesn't have generalized existentials yet).

We can't declare a variable or constant of the protocol type `Database`, like we are used to with delegate protocols:

~~~swift
weak var delegate: MyDelegateProtocol
// ^^ perfectly fine

var database: Database
// ^^ compiler error: Protocol 'Database' can only be used as a generic constraint because it has Self or associated type requirements
~~~

#### Solution

We use a `Database` protocol but without any conformance to `Observable`. Instead, we only require the `Database` to have a messenger:

~~~swift
protocol Database {
   var messenger: Messenger<DatabaseUpdate> { get }
   // declare other database functionality
}
~~~

Now, in contrast to an `Observable`, we must manually route all observation of the database through its messenger, but at least it works.

### 2. Inherit and Extend Observability

Consider this case: I have a generic class `Tree`. It is a `Observable`, so tree nodes can observe their branches. Then I have an `Item` which derives from `Tree`. `Item` cannot extend or override the `Tree.Message`.

In order to further specify what items can send to their observers, the `Tree` must use its messenger without direct conformance to `Observable`. This tree messenger should (somewhat redundantly) be named after its class: `treeMessenger`, so that there's no confusion in inheriting classes about which ancestor owns the messenger.

Generally speaking, to be able to extend observability in derived classes, observability should be more granular in the base class. Instead of making the base class as a whole observable, one could give it observable properties or dedicated messengers.