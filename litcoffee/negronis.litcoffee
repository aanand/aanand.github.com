I was out last Friday at a bar where they had a "Negroni Tic-Tac-Toe" offer---you could custom-build your drink from a selection of 3 gins, 3 vermouths and 3 amari, and if you got "3 in a row" you'd get &pound;5 off your bill. It's a laughably stingy deal, but it got me thinking. About functional programming, I mean.

    class Negroni
      constructor: (@gin, @vermouth, @amaro) ->
        # Build over ice, stir well

      inspect: -> "Negroni(#{@gin}, #{@vermouth}, #{@amaro})"

The Negroni is often described as a "manly" drink, but fuck your gender-essentialism---let's just call it _badass_. Everything I ever needed to know about it, by the way, I learned from [Felix](http://manhattansproject.com/on-the-negroni/). I personally find Punt e Mes a shade too bitter when combined with Campari, but that's just me.

    # some shorthands for the Node console
    print = (args...) -> console.log(args...)
    inspect = (thing) -> if thing.inspect then thing.inspect() else thing.toString()

    print "Here's how I make it at home:",
      new Negroni("Botanist", "Martini Rosso", "Campari")
      # => Negroni(Botanist, Martini Rosso, Campari)

Point is, there are 3&times;3&times;3&nbsp;=&nbsp;27 possible combinations at that bar, a delicious Rubik's Cube of liver damage. How would you enumerate them all?

    assemble = (g, v, a) ->
      g.map (gin) ->
        v.map (vermouth) ->
          a.map (amaro) ->
            new Negroni(gin, vermouth, amaro)

    allGins      = ["Botanist", "Bombay Sapphire", "Blackwoods 60%"]
    allVermouths = ["Martini Rosso", "Cocchi", "Punt e Mes"]
    allAmari     = ["Campari", "Aperol", "Cynar"]
    
    print assemble(allGins, allVermouths, allAmari)

    # => [ [ [ Negroni(Botanist, Martini Rosso, Campari),
    #          Negroni(Botanist, Martini Rosso, Aperol),
    #          Negroni(Botanist, Martini Rosso, Cynar) ],
    #        [ Negroni(Botanist, Cocchi, Campari),
    #          Negroni(Botanist, Cocchi, Aperol),
    #          Negroni(Botanist, Cocchi, Cynar) ],
    #      ...]
    #    ...]

Hmmm. It's a start, but that's altogether too much nesting. We'll never get anything done if we're spending all our time unboxing drinks.

    Array.prototype.flatMap = (fn) ->
      this.map(fn).reduce(((a, b) -> a.concat(b)), [])

    assemble = (g, v, a) ->
      g.flatMap (gin) ->
        v.flatMap (vermouth) ->
          a.map (amaro) ->
            new Negroni(gin, vermouth, amaro)

The outer two `map`s are replaced with `flatMap`, which maps and then flattens the resulting array.

    print assemble(allGins, allVermouths, allAmari)

    # => [ Negroni(Botanist, Martini Rosso, Campari),
    #      Negroni(Botanist, Martini Rosso, Aperol),
    #      Negroni(Botanist, Martini Rosso, Cynar),
    #      Negroni(Botanist, Cocchi, Campari),
    #      Negroni(Botanist, Cocchi, Aperol),
    #      Negroni(Botanist, Cocchi, Cynar),
    #      Negroni(Botanist, Punt e Mes, Campari),
    #    ...]

Much better.

Of course, it's almost never a good idea to make 27 cocktails. Let's row back a bit and consider a much more common scenario: you've got a guest round and they'd fancy just one Negroni. They don't much mind _what_ gin, vermouth or amaro it's made with---you're more worried about whether you have them at all. Can you satisfy them?

We need to represent the _potential presence or absence_ of a thing.

    yep = (thing) ->
      {
        inspect: -> "yep(#{inspect(thing)})"
      }

    nope =
      {
        inspect: -> "nope"
      }

    print "Here's something:", yep("Gin")
    print "Here's nothing:", nope

So, time to write a new `assemble()` method, right? To check individually for the presence or absence of each of our ingredients, and only return a `yep()` if we've got all 3?

Nope. `assemble()` can stay as it is. We just need to implement `map` and `flatMap`.

    yep = (thing) ->
      {
        inspect: -> "yep(#{inspect(thing)})"

        map:     (f) -> yep(f(thing))
        flatMap: (f) -> f(thing)
      }

    nope =
      {
        inspect: -> "nope"

        map:     (f) -> nope
        flatMap: (f) -> nope
      }

    print "If we have no ingredients:",
      assemble(nope, nope, nope)
      # => nope
    
    print "If we have only gin and amaro:",
      assemble(yep("Gin"), nope, yep("Amaro"))
      # => nope

    print "If we have gin, vermouth and amaro:",
      assemble(yep("Gin"), yep("Vermouth"), yep("Amaro"))
      # => yep(Negroni(Gin, Vermouth, Amaro))

Magic. `assemble()` will accept anything that supports those two methods. All it expresses is that you need all 3 ingredients to make a Negroni---not how to get them, or how many to make. That logic lives entirely in the definitions of `map` and `flatMap`: for arrays, all possible combinations of elements are enumerated; for `yep` and `nope`, we only ever have zero or one of something, and we short-circuit as soon as the first zero (a.k.a. `nope`) is encountered.

Sadly, it turns out we don't have any of the ingredients to hand. You can order them online, though! Indeed, you have 3 fast-delivery specialist suppliers (one per ingredient---they're _highly_ specialised) bookmarked for this very purpose. Within a few moments, each one has promised that a bottle is on its way to you, and you can thus pass on the promise of a Negroni to your patient, thirsty guest.

    Promise = require("promise")

    Promise.prototype.map     = (fn) -> this.then(fn)
    Promise.prototype.flatMap = (fn) -> this.then(fn)

    order = (name) ->
      new Promise (resolve) ->
        setTimeout((-> resolve(name)), 1000)

    g = order("Gin")      # a Promise of "Gin"
    v = order("Vermouth") # a Promise of "Vermouth"
    a = order("Amaro")    # a Promise of "Amaro"

    promisedNegroni = assemble(g, v, a) # a Promise of a Negroni

    print "Your Negroni is on its way. Any second now..."

    promisedNegroni.then (negroni) ->
      print "Ah! It's here:", negroni
      # => Negroni(Gin, Vermouth, Amaro)

---

I'm not the first one to point out that [promises are the monad of asynchronous programming](http://blog.jcoglan.com/2011/03/11/promises-are-the-monad-of-asynchronous-programming/), but the topic has become pertinent, because [the Promises/A+ spec](https://github.com/promises-aplus) is still in formation. If programmers can rely on a monadic interface for promises, this opens up the possibility of writing code which will work with _any_ monad, not just promises---as I've tried to demonstrate with `assemble()` above.

The spec as it stands is not enough: for one thing, a monad must provide a means of wrapping a plain value, e.g. `Array.of(1)` or `Promise.of(1)`. I avoided implementing such a method in the examples above for simplicity's sake, and used `map` instead, but the following are equivalent:

    [1, 2, 3].map(fn)

    Array.prototype.of = (x) -> [x]
    [1, 2, 3].flatMap (x) -> Array.of(fn(x))

A thornier issue is that a promise's `then` method, as specified, treats the return value of the passed-in function differently depending on whether it's a promise---essentially, it must try to intelligently determine whether to be `map` or `flatMap`---which is why the two methods we implemented on `Promise.prototype` are identical.

Besides the inherent unreliability of trying to determine an object's type in a dynamically-typed language, such overloading is likely to lead to difficult-to-predict bugs and difficult-to-reason-about code when promises are _treated_ like well-behaved monads, but _aren't_. We got away with it this time, but I wouldn't feel confident writing more complex code, knowing that "smart" logic was there.

There [has](http://brianmckenna.org/blog/category_theory_promisesaplus) [been](https://github.com/promises-aplus/resolvers-spec/issues/24) [some](https://github.com/promises-aplus/promises-spec/issues/94) [discussion](https://github.com/promises-aplus/promises-spec/issues/97) on this topic in the last few days. Sadly, the authors have so far been difficult to convince. This is understandable---the theory is difficult to explain, and examples of the potential problems non-obvious (I am personally unable to produce a simple example).

A more directly appealing argument was made by [Reg](https://github.com/promises-aplus/promises-spec/issues/94#issuecomment-16294840):

> A long time ago in a company far, far away, there was a young engineer given a herculean task within an impossible deadline. He created LiveScript. One of the decisions he made was to make functions first-class values rather than have them be "something else" like the other popular languages of the day. Another was to use prototypical inheritance rather than classical inheritance, like the other popular languages of the day.

> It would take years for the programming community to embrace the power of functions as first-class values in his language. Most people agree that Crockford got the ball rolling, followed by Oliver Steele and you can trace a direct line down to Jeremy Ashkenas and Underscore from there. Today, it is unthinkable to imagine a JavaScript without functions that can return functions or apply functions.

> Conversely, prototypical inheritance hasn't reached a tipping point. The vast majority of programmers simply emulate classical inheritance and do not exploit its power in any way.

> What does this history tell me about promises?

> I think that promises-that-are-monads are in the same category as these two ideas I cited. If we embrace the idea of promises being first-class monads, we will likely have a lot of "meh" for a year or maybe three. Then someone will write a library or give a talk and the light will go on. It is had to imagine what wonderful thing will be created when that happens.

This speaks to me. The power of first-class functions had already been amply demonstrated when LiveScript was designed---just not in the mainstream. Similarly, the power of the monad abstraction has been amply demonstrated in functional languages, but not yet in the mainstream.

It may be too late for `then`---too much code already relies on its current behaviour, and besides, it's useful. A [concurrent spec for monads](https://github.com/pufuwozu/fantasy-land) (they call it `chain`, not `flatMap`) has been started, and we could just hope that most promise implementors choose to support that too... but I strongly suspect the majority won't bother, even though it'd be trivial.

To have the `chain` and `of` methods required in Promises/A+ would be a _much_ bigger win.

