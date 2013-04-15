I was out last Friday at a bar where they had a "Negroni Tic-Tac-Toe' offer---you could custom-build your drink from a selection of 3 gins, 3 vermouths and 3 amari, and if you got "3 in a row" you'd get &pound;5 off your bill. It's a laughably stingy deal, but it got me thinking.

    class Negroni
      constructor: (@gin, @vermouth, @amaro) ->
        # Build over ice, stir well

      toString: -> "Negroni(#{@gin}, #{@vermouth}, #{@amaro})"

      # for the Node console
      inspect: -> @toString()

The Negroni is often described as a "manly" drink, but fuck your gender-essentialism---let's just call it _badass_. Everything I ever needed to know about it, by the way, I learned from [Felix](http://manhattansproject.com/on-the-negroni/). I personally find Punt e Mes a shade too bitter when combined with Campari, but that's just me.

    console.log "Here's how I make it at home:"
    console.log new Negroni("Botanist", "Martini Rosso", "Campari")

Point is, there are 3&times;3&times;3&nbsp;=&nbsp;27 possible combinations at that bar, a delicious Rubik's Cube of liver damage. How would you enumerate them all?

    assemble = (g, v, a) ->
      g.map (gin) ->
        v.map (vermouth) ->
          a.map (amaro) ->
            new Negroni(gin, vermouth, amaro)

    allGins      = ["Botanist", "Bombay Sapphire", "Blackwoods 60%"]
    allVermouths = ["Martini Rosso", "Cocchi", "Punt e Mes"]
    allAmari     = ["Campari", "Aperol", "Cynar"]
    
    console.log assemble(allGins, allVermouths, allAmari)

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

    console.log assemble(allGins, allVermouths, allAmari)

    # => [ Negroni(Botanist, Martini Rosso, Campari),
    #      Negroni(Botanist, Martini Rosso, Aperol),
    #      Negroni(Botanist, Martini Rosso, Cynar),
    #      Negroni(Botanist, Cocchi, Campari),
    #      Negroni(Botanist, Cocchi, Aperol),
    #      Negroni(Botanist, Cocchi, Cynar),
    #      Negroni(Botanist, Punt e Mes, Campari),
    #    ...]

Much better.

Of course, it's almost never a good idea to make 27 cocktails. Let's row back a bit and consider a much more common scenario: you've got a guest round and they'd fancy just one. They don't much mind _what_ gin, vermouth or amaro it's made with---you're more worried about whether you have them at all. Can you satisfy them?

We need to represent the _potential presence or absence_ of a thing.

    yep = (thing) ->
      {
        toString: -> "yep(#{thing})"
        inspect:  -> @toString()
      }

    nope =
      {
        toString: -> "nope"
        inspect:  -> @toString()
      }

    console.log yep("Gin") # => yep(Gin)
    console.log nope       # => nope

So, time to write a new `assemble()` method, right? To check individually for the presence or absence of each of our ingredients, and only return a `yep()` if we've got all 3?

Nope. `assemble()` can stay as it is. We just need to implement `map` and `flatMap`.

    yep = (thing) ->
      {
        toString: -> "yep(#{thing})"
        inspect:  -> @toString()

        map:     (f) -> yep(f(thing))
        flatMap: (f) -> f(thing)
      }

    nope =
      {
        toString: -> "nope"
        inspect:  -> @toString()

        map:     (f) -> nope
        flatMap: (f) -> nope
      }

    console.log "If we have no ingredients:"
    console.log assemble(nope, nope, nope)
    # => nope
    
    console.log "If we have only gin and vermouth:"
    console.log assemble(yep("Gin"), yep("Vermouth"), nope)
    # => nope

    console.log "If we have gin and vermouth and amaro:"
    console.log assemble(yep("Gin"), yep("Vermouth"), yep("Amaro"))
    # => yep(Negroni(Gin, Vermouth, Amaro))

Magic. `assemble()` will accept anything that supports those two methods. All it expresses is that you need all 3 ingredients to make a Negroni---not how to get them, or how many to make.

Sadly, it turns out we don't have any of the ingredients to hand. You can go online and order them, though, and indeed have 3 fast-delivery specialist suppliers (one per ingredient---they're _highly_ specialised) bookmarked for this very purpose. Within a few moments, each one has promised that a bottle is on its way to you, and you can thus pass on the promise of a Negroni to your patient, thirsty guest.

    Promise = require("promise")

    Promise.prototype.map     = (fn) -> this.then(fn)
    Promise.prototype.flatMap = (fn) -> this.then(fn)

    order = (name) ->
      new Promise (resolve) ->
        setTimeout((-> resolve(name)), 1000)

    g = order("Gin")      # a promise of gin
    v = order("Vermouth") # a promise of vermouth
    a = order("Amaro")    # a promise of amaro

    promisedNegroni = assemble(g, v, a) # a promise of a Negroni

    console.log "Your Negroni is on its way. Here's your order:"
    console.log promisedNegroni
    console.log "Any second now..."

    promisedNegroni.then (negroni) ->
      console.log "Ah! It's here: #{negroni}"

