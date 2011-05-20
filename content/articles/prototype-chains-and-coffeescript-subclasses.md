---
title: Prototype Chains and CoffeeScript Subclasses
kind: article
created_at: 2011-05-20 14:16
summary: In developing [nnnnext.com](http://nnnnext.com), I tackled a surprising number of problems I’d not faced before as a web developer and programming language enthusiast. Here’s one of the more interesting ones, with what I feel is a pretty cute solution.
---

Context, briefly: nnnnext is a todo list for your music. It’s a single-page JavaScript app written in [CoffeeScript][coffeescript] and utilising [Backbone.js][backbone] for [lightweight][lightweight] MVC. Importantly, it has two similar-but-separate user interfaces: one for desktop web browsers, and another for multitouch devices.

Both interfaces are implemented as a set of classes (provided by CoffeeScript’s [simple classes implementation][coffeescript-classes]) that represent the different UI views. Each UI requires slightly different behaviour for _some_ views, and so some view classes are subclassed by one or both UIs. (Whatever you think of classical object-orientation and inheritance, it’s an undeniably good fit for MVC-style UI code—subclasses and the `super` keyword make augmentation of behaviour very straightforward[^classical-oo-and-mvc].)

[^classical-oo-and-mvc]: I should be careful about using the word “undeniably” though. I’m no expert on object systems. If you feel you can reasonably deny it, I’d love to [hear from you][email]!

For example: an element contains a button that (in the desktop UI) appears when the element is hovered, and (in the touch UI) appears/disappears when the element is tapped. Furthermore, in the touch UI, there must be more visual feedback than simply showing the button instantly. (The iPhone’s smooth animations aren’t just for show—instantaneous changes in a touch-based interface are jarring.)

The view class for this widget might, off the top of my head, look something like this:

<pre class="go"><code class="language-coffeescript">class Views.Widget extends Backbone.View
  render: -&gt;
    $(@el).html("I'm a widget. &lt;button&gt;Do something&lt;/button&gt;")
    this

  events:
    "click button": "doSomething"
  
  doSomething: (event) -&gt;
    # ...

class Desktop.Widget extends Views.Widget
  render: -&gt;
    super()

    button = @$("button")
    button.hide()
    $(@el).hover(-&gt; button.show(), -&gt; button.hide())

    this

class Touch.Widget extends Views.Widget
  render: -&gt;
    super()

    button = @$("button")
    button.css({"opacity": 0, "-webkit-transition": "0.5s"})
    $(@el).bind "touchend", -&gt;
      button.css("opacity", 1-parseInt(button.css("opacity")))

    this
</code></pre>

Blah blah blah.

[coffeescript]: http://jashkenas.github.com/coffee-script/
[coffeescript-classes]: http://jashkenas.github.com/coffee-script/#classes
[backbone]:     http://documentcloud.github.com/backbone/
[lightweight]:  http://twitter.com/hylomorphism/status/71202209618067457
[email]:        mailto:aanand.prasad@gmail.com
