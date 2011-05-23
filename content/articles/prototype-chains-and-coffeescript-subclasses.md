---
title: Prototype Chains and CoffeeScript Subclasses
kind: article
created_at: 2011-05-20 14:16
summary: In developing [nnnnext.com](http://nnnnext.com), I tackled a surprising number of problems I’d not faced before as a web developer and programming language enthusiast. Here’s one of the more interesting ones, with what I feel is a pretty cute solution.
---

Context, briefly: nnnnext is a todo list for your music. It’s a single-page JavaScript app written in [CoffeeScript][coffeescript] and utilising [Backbone.js][backbone] for [lightweight][lightweight] MVC. Importantly, it has two similar-but-separate user interfaces: one for desktop web browsers, and another for multitouch devices.

Both interfaces are implemented as a set of classes (provided by CoffeeScript’s [simple classes implementation][coffeescript-classes]) that represent the different UI views. Each UI requires slightly different behaviour for _some_ views. For example, an element might contain a button that (in the desktop UI) appears when the element is hovered, and (in the touch UI) appears/disappears when the element is tapped. Consequently, some view classes are subclassed in one or both UIs in order to implement these differences. The class structure might look like this (implementation code omitted):

    ```coffeescript
    Views   = {}
    Desktop = {}
    Touch   = {}

    class Views.Widget   extends Backbone.View
    class Views.Thinger  extends Backbone.View
    class Views.Sprocket extends Backbone.View

    class Desktop.Widget extends Views.Widget

    class Touch.Widget   extends Views.Widget
    class Touch.Thinger  extends Views.Thinger

(Whatever you think of classical object-orientation and inheritance, it’s an undeniably good fit for MVC-style UI code—subclasses and the `super` keyword make augmentation of behaviour very straightforward[^classical-oo-and-mvc].)

[^classical-oo-and-mvc]: I should be careful about using the word “undeniably” though. I’m no expert on object systems. If you feel you can reasonably deny it, I’d love to [hear from you][email]!

So how, at runtime, might we instantiate the appropriate class? Running all instantiations through a helper method would certainly work:

    ```coffeescript
    # assume the existence of a `Mobile` boolean variable

    makeViewObject: -> (name, args...)
      UI    = if Mobile then Touch else Desktop
      klass = UI[name] || Views[name]

      new klass(args...)

    makeViewObject("Widget")   # => new Desktop.Widget OR new Touch.Widget
    makeViewObject("Thinger")  # => new Desktop.Thinger OR new Views.Thinger
    makeViewObject("Sprocket") # => new Views.Sprocket

...and if you’re most people, you’ll stop there. I, on the other hand, had just read Isaac Z. Schlueter’s [Evolution of a Prototypal Language User][evolution], hadn't done anything fun with prototype chains in years and didn’t like the idea of this unsightly helper method peppering my code. So I got to work.

Instead of `Views`, `Desktop` and `Touch` being plain objects, we create a `ViewShop` function, point `Views` at its prototype and make `Desktop` and `Touch` new `ViewShop`s, so that property access falls back to `ViewShop.prototype` (a.k.a. `Views`). Look, it’s easier if I just show you:

    ```coffeescript
    ViewShop = ->

    Views   = ViewShop.prototype
    Desktop = new ViewShop
    Touch   = new ViewShop

Now, after defining the view classes, access any property of `Desktop` or `Touch`, and prototype chaining works its magic:

    ```coffeescript
    Desktop.Widget   # => Desktop.Widget
    Desktop.Thinger  # => Views.Thinger
    Desktop.Sprocket # => Views.Sprocket

    Touch.Widget     # => Touch.Widget
    Touch.Thinger    # => Touch.Thinger
    Touch.Sprocket   # => Views.Sprocket

We need only make a `UI` variable that points to the right `ViewShop`, and we’re done:

    ```coffeescript
    UI = if Mobile then Touch else Desktop

    new UI.Widget   # => new Desktop.Widget OR new Touch.Widget
    new UI.Thinger  # => new Desktop.Thinger OR new Views.Thinger
    new UI.Sprocket # => new Views.Sprocket

Well anyway, I like it.

[coffeescript]: http://jashkenas.github.com/coffee-script/
[coffeescript-classes]: http://jashkenas.github.com/coffee-script/#classes
[backbone]:     http://documentcloud.github.com/backbone/
[lightweight]:  http://twitter.com/hylomorphism/status/71202209618067457
[evolution]:    http://blog.izs.me/post/4731036392/evolution-of-a-prototypal-language-user
[email]:        mailto:aanand.prasad@gmail.com
