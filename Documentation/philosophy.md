# Philosophy and Features

This is the opinionated side of SwiftObserver. I invite you put it on like a shoe. See if it fits, take it for what it's worth and evolve it via PR or email: <hello@codeface.io>.

* [What You Might Like](#what-you-might-like)
  * [Meaningful Code](#meaningful-code)
  * [Non-intrusive Design](#non-intrusive-design)
  * [Simplicity and Flexibility](#simplicity-and-flexibility)
  * [Safety](#safety)
* [Why Combined Observation is Overrated](#why-combined-observation-is-overrated)
* [What You Might Not Like](#what-you-might-not-like)

# What You Might Like

## Meaningful Code

* Readable code down to the internals

  > I comb internal code with as much regularity and care as if it was public API, so you can peek under the hood to understand SwiftObserver perfectly.

* Meaningful expressive metaphors

  * No arbitrary, contrived or technical metaphors like "disposable", "dispose bag", "signal", "emitter", "stream" or "sequence"

  > A note on "signals": In the tradition of Elm and the origins of reactive programming,  many reactive libraries use "signal" as a metaphor, but how they apply the term is more confusing than helpful, in particular when they suggest that the "signal" is what's being observed.
  >
  > Our closest context of reference here is information theory, where a signal is what's being technically transmitted from a source to a receiver. By observing the source, the receiver receives a signal which conveys messages. Would we apply the metaphor to reactive programming, the signal would rather correspond to the actual data that *observables* send to *observers*.

- Meaningful (semantically consistent) metaphor combinations

  > That is: no combination of incompatible metaphors that stem from completely different domains

  > A common and nonsensical mixture is "subscribing" to a "signal". Even Elm, which had signals and still has subscriptions, never mixed the two.
  >
  > "subscribing" to an "observable" doesn't make much sense either. Why isn't it a "subscribable" then? Why is it a radical idea to "observe" an "observable"? Is an "observable" a publication?

- A meaningful level of abstraction that's focused on the essential *Observer Pattern*

  > SwiftObserver is pragmatic and doesn't overgeneralize the *Observer Pattern* in any arbitrary direction. It doesn't go overboard with models like "streams" or "sequences" but keeps things more simple, real-world oriented and meaningful to actual application domains.

- Meaningful code at the point of use (no technical boilerplate)

  - No mediating property on *observables* for starting observations or creating mappings
  - No "tokens" and the like to pass around or store
  - No memory management boilerplate code at the point of observation
  - No tuple destructuring in combined observations

- Meaningful syntax

  - The syntax reflects the intent and metaphor of the *Observer Pattern*: *Observers* are active subjects while *observables* are passive objects which are unconcerned about being observed:

    ```swift
    dog.observe(sky)
    observer.observe(observable)
    subject.actUpon(object)
    ```

  > Note: Many definitions of the *Observer Pattern*, including [Wikipedia](https://en.wikipedia.org/wiki/Observer_pattern), have the subject / object roles reversed, which we consider not merely a misnomer but, above all, a secondary level of analysis.
  >
  > They look at observation from a technical rather than a conceptual point of view, focusing on *how* the problem is being *solved* rather than *what* the solution *means*.
  >
  > The illusion the *Observer Pattern* is supposed to create is that an *observer* observes an *observable*. Linguistically, that is: subject, predicate, object. The subject actively acts on the object, while the object is passively being acted upon.
  >
  > Of course, to achieve this under the hood, *observables* must actively trigger some data propagation. But we should look at the solution more pragmatically in terms of the real-world meaning that we set out to model in the first place.

## Non-intrusive Design

- No delegate protocols to implement

- Custom *observables* without having to inherit from any base class

  - You're in control of the ancestral tree of your classes.
  - All classes can easily be observed, even views and view controllers.
  - You can keep model and logic code independent of any observer frameworks and techniques.

  > If the model layer had to be stuffed with heavyweight constructs just to be observed, it would become a technical issue rather than an easy to change,  meaningful, direct representation of domain-, business- and view logic.

- No restrictions on how you organize, store or persist the state of your your app

  * You can freely model your domain-, business- and view logic with all your familiar design patterns and types.

- No optional optionals

  - You have full control over value and *message* types.
  - You can make your *message* types optional. SwiftObserver will never spit them back at you wrapped in additional optionals, not even in combined observations.
  - You can easily unwrap optional *messages* via the *mapping* `unwrap`.

- No under the hood side effects in terms of ownership and life cycles

  * You stay in control of when objects die and of which objects own which others.
  * Your code stays explicit.

- No duplication

  - SwiftObserver never duplicates the *messages* that are being sent around, in particular in [combined observations](#combined-observations) and transforms. This is in stark contrast to other reactive libraries yet without compomising functional aspects.

  > Note: Not having to duplicate data where multiple things must be observed is one of the reasons to use combined observations in the first place. However, some reactive libraries choose to not make full use of object-orientation, so far that the combined observables could be value types. This forces these libraries to duplicate data by caching the messages sent from observables.
  >
  > SwiftObserver not only leverages object-orientation, for combined observations, it also offers a regular "pull model" in which observers can pull messages from observables, in addition to the typical reactive "push model" in which observables push their messages to observers.
  >
  > "Pulling" just reflects the natural way objects operate. Observers can act on observables without problem, since that is the actual technical direction of control and dependence. The problem that reactive techiques solve is propagating data **against** the direction of control. 
  >
  > A "pull model" is also in line with functional programming: Instead of caching state, the combined observation calls and combines functions on observables.

## Simplicity and Flexibility

- Very few simple but universal concepts and types

- Pure Swift for clean modelling, not even any dependence on `Foundation`

- Transforms can be instantiated as first-class *observables* that can be treated like any other *observable*.

- One universal consistent syntax for transforming *messages* and chaining these transformations

- Use a small but universal set of prebuilt transformations wherever you transform *messages*:

  - `map`
  - `new`
  - `unwrap` (with and without default)
  - `filter`
  - `select`
  - `filterAuthor`
  - `from`
  - `notFrom`

- One universal (combined) observation

  - One function to observe 1-3 *observables*
  - Still, you get all the power of combined observation.
  - Combined observation has no special syntax and imposes no additional cognitive load.
  - [Here's more on the nature of combined observation](#combined-observation-is-overrated)

- Create an *observable* plus a chain of *transforms* in one line.

- Observe an *observable* with an ad-hoc chain of transformations in one line.

- Use the `<-` operator to directly set variable values.

- Use common operators directly on number- and string variables.

- Variables are `Codable`, so model types are easy to encode and persist.

- Pull the current *message* from any caching *observable* via `latestMessage`. 

- Receive the old **and** new value from variables

- Seamless coverage of the *Messenger Pattern* (or *Notifier Pattern*) via the `Messenger` class

- Reference any *observable* weakly by wrapping it in `Weak`

  - Hold `weak` references to *observables* in a data structure:

    ```swift
    let strongNumber = Var(12)
    var arrayOfWeakNumbers = [Weak<Var<Int>>]()
    arrayOfWeakNumbers.append(Weak(strongNumber))
    ```

  - Create transforms that hold their sources weakly:

    ```swift
    let strongNumber = Var(12)
    let toString = Weak(strongNumber).new().map { "\($0)" }
    ```

## Safety

- When an observers or observables die, their observations stop automatically.
- Memory leaks are impossible.
- Stop observations in the same expressive way you start them: `observer.stopObserving(observable)`
- Stop **all** observations of an *observer* with **one** call: `observer.stopObserving()`

# Why Combined Observation is Overrated

Other reactive libraries dump the combine functions `merge`, `zip` and `combineLatest` on your brain. And at one point, I was convinced combined observations are an essential part of reactive programming. Practice has changed my mind. SwiftObserver offers no combined observation anymore. This decision is the result of a long process, involving many practical applications, discovering what's really essential, and letting go of big fancy features, one by one.

It has emerged as part of the philosophy (or insight if you will) on which SwiftObserver is built, that combined observation is a non-essential feature to the purpose of the observer pattern, dependency inversion, reactive code design and clean architecture. I would even argue that combined observation is an anti pattern. So SwiftObserver will not blow up its complexity or compromise its elegance, consistency or principles, just to support combined observation.

Combined observation can always easily be replaced by single observations. Each single observation would just call a function that does the "combined" update and pulls the necessary data from wherever it needs to.

`combineLatest` is by far the most used combine function in practice and covers practically all "needs" for combined observation. The above suggested update function can be equivalent to `combineLatest` when the involved observables conform to `ObservableCache`, so the update function can directly pull the latest message from them. `ObservableCache` generally reduces the need for explicit combine functions in the first place, since the interesting data can often be pulled directly from *observables*. 

As the founder of SwiftObserver, I even have to note, that I don't use combined observation anymore at all. It never offers me a benefit over single observation in practice. To the contrary: Managing observations proves to be harder when they're coupled. 

My hunch is that `merge`, `zip` and `combineLatest` in other reactive libraries originate less from practical need and more from a desire to gerneralize and to max out the metaphors of "data streams" or "sequences". The underlying conceptual mis-alignment here would be, that *observables* in an *observer-observable* relationship are really **supposed** to send **messages** rather than anonymous **data**. I'll explain why.

All that is required for dependency inversion is that the *observer* gets informed about events that it might need to react to. The *observer* then decides whether to act at all, how to act and what data it requires, and it pulls exactly that data from wherever it needs to, including from *observables*. It is not the job of the *observable* to presume what data any *observer* might need. It's not supposed to depend on the *observer's* concerns, which is the whole reason why we invert that dependency through the *Observer Pattern*. The *observable's* job is just to tell what happened. 

So, in a clean decoupled design that adheres to the idea of the *ObserverPattern*, *observables* naturally send **messages** rather than **data**, and combining *messages* wouldn't be as meaningful or helpful.

# What You Might Not Like

- Not conform to Rx (the semi standard of reactive programming)
- SwiftObserver is focused on the foundation of reactive programming. UI bindings are available as [UIObserver](https://github.com/flowtoolz/UIObserver), but that framework is still in its infancy. You're welcome to make PRs.
- Observers and observables must be objects and cannot be of value types. However:
  1. Variables can hold any type of values and observables can send any type of messages. 
  2. We found that entities active enough to observe or significant enough to be observed are typically not mere values that are being passed around. What's being passed around are the messages that observables send to observers, and those messages are prototypical value types.
  3. For fine granular observing, the `Var` type is appropriate, further reducing the "need" (or shall we say "anti pattern"?) to observe value types.
