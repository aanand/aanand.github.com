---
title: Better Tap Behaviour with jquery.tappable.js
kind: article
created_at: 2011-07-05 21:13
updated_at: 2011-07-07 10:39
summary: The behaviour of tappable elements in Mobile Safari is unacceptably ugly. Unfortunately, taking control of it is more involved than it perhaps ought to be. [jquery.tappable.js](https://github.com/aanand/jquery.tappable.js) does (most of) the hard work for you.
---

I hope we can all agree that [mobile web apps shouldn’t pretend to be native apps][mobile-native], but I don’t like the thought of having to accept the current state of most mobile apps as the hand we’ve been dealt. The whole business feels somewhat 2000-era, which is frankly weird—we’ve spent a good decade improving the look and feel of apps in the browser, but the majority of mobile web apps seem content with a half-hearted grey-boxes-and-lines style and a rigid, transitionless interactivity.

Does the responsibility lie with the vendors of mobile browsers? Partially. Apple are only now getting round to adding [native support for scrollable elements][ios-scrolling]: so far, we’ve been stuck with a range of lovingly crafted fakeries that range from ‘pathetic’ to ‘uncanny valley’. The problem goes beyond the slow pace of change, though—even when the functionality required to implement higher-quality interaction _is_ in place, it’s often in such a way as to leave an inordinate amount of work to the app developer. A perfect example of this is the default behaviour of ‘clickable’ (or, rather, _tappable_) elements in Mobile Safari.

Tap a link, a button or indeed any element with a `click` event defined, and two unpleasant things happen. First, _nothing_, for around 300 milliseconds. Then, an ugly dark-grey overlay—you know the one I'm talking about. Compared to the responsiveness of tappable UI elements in native apps, using a mobile app where every element behaves this way feels like operating your iPhone with someone else’s finger.

In developing [nnnnext](http://nnnnext.com), I quickly came to the decision that this wasn’t good enough, and set about trying to fix it. While [removing the overlay][webkit-tap-highlight-color] was easy enough, it quickly became obvious that iOS’ touch behaviour is more complicated than I intitially suspected, primarily in that *it treats a “long tap” differently from a “short tap”*.

Perform a short tap (i.e. literally just _tap_ the screen), and the element is immediately highlighted and the appropriate action executed. Perform a long tap (keeping your finger down for a moment), and the element is highlighted after a short delay (around 150ms) and the action executed when you lift your finger—unless you move your finger first, in which case the highlight is immediately removed and the action cancelled.

The reason for the long-tap highlight delay became apparent after I’d coded my initial implementation: if the element is immediately highlighted when you put your finger down, then every time you scroll you’ll get a flash-of-highlight if you happen to start your scroll by putting your finger on that element. This is, I believe, why the delay is only in place on large, column-spanning elements of the type you can’t avoid touching when you scroll, while buttons and other small widgets react the moment you touch them.

I realised some of this only after implementing an incorrect solution, releasing it and blogging my ignorance. Another fact I overlooked is that Mobile Safari’s behaviour _only_ deviates from the rest of the OS on short taps. Long-tap behaviour is the same, but with short taps, both highlighting _and_ action are delayed, and for around twice as long as the long-tap highlight delay! The reason for this (though I failed to perceive this blindingly obvious fact at the time) is Safari’s _double-tap-to-zoom feature_—if there were no delay, or if it were much shorter, double-tapping would be impossible.

In most mobile-optimised web apps, however, zooming isn’t even enabled, rendering any short-tap delay worse than useless. Here, then, is our desired behaviour, expressed in terms of browser events:

Event order                              | Desired effect
---------------------------------------- | --------------
touchstart, timeout, touchend            | Highlight on timeout, fire callback on touchend (long tap)
touchstart, touchend, timeout            | Highlight and fire callback on touchend (short tap)
touchstart, timeout, touchmove, touchend | Highlight, then de-highlight on touchmove (long tap cancelled by scrolling)
touchstart, touchmove, timeout, touchend | None (scroll)
touchstart, touchmove, touchend, timeout | None (scroll)

I promised up there in the first paragraph that I’d done the hard work for you, and here you go: [jquery.tappable.js][jquery-tappable] implements this behaviour, and falls back to `click` events in desktop browsers for good measure.

It deviates from the above table in one respect, however—the highlight class is removed (or, in the case of a short tap, not added) before firing the callback. This is a matter of code aesthetics for me: I don’t want a library or plugin I’m using to add a transient class to an element without cleaning up after itself. When I need the highlight class to stick around longer (which in the nnnnext codebase is the exception, not the rule), I add it again in the callback function.

Anyway, examples:

    ```javascript
    // Basic usage
    $(element).tappable(function() { console.log("Hello World!") })

    // Add a delay
    $(element).tappable({
      callback:   function() { console.log("Hello World!") },
      touchDelay: 150
    })

    // Don't cancel taps when the user moves their finger
    $(element).tappable({
      callback:     function() { console.log("Hello World!") },
      cancelOnMove: false
    })

    // Don't highlight the element OR fire the callback unless a
    // specified condition is met
    $(element).tappable({
      callback: function()   { console.log("Hello World!")      },
      onlyIf:   function(el) { return $(el).hasClass('enabled') }
    })

Have fun!

[jquery-tappable]: https://github.com/aanand/jquery.tappable.js
[mobile-native]: http://cvil.ly/2011/06/19/pretenders-why-mobile-web-apps-should-stop-trying-to-act-like-native-apps/
[ios-scrolling]: http://cubiq.org/ios5-the-first-true-web-app-ready-platform
[webkit-tap-highlight-color]: http://css-infos.net/property/-webkit-tap-highlight-color

