---
title: Passing Off as a Native with jquery.tappable.js
kind: article
created_at: 2011-07-05 21:13
summary: Apple may or may not hate the open web, but they certainly don’t make click behaviour pretty in Mobile Safari. Unfortunately, taking control of it is more involved than it perhaps ought to be. [jquery.tappable.js](https://github.com/aanand/jquery.tappable.js) does (most of) the hard work for you.
---

I hope we can all agree that [mobile web apps shouldn’t pretend to be native apps][mobile-native], but I don’t like the thought of having to accept the current state of most mobile apps as the hand we’ve been dealt. The whole business feels somewhat 2000-era, which is frankly weird—we’ve spent a good decade improving the look and feel of apps in the browser, but the majority of mobile web apps seem content with a half-hearted grey-boxes-and-lines style and a rigid, transitionless interactivity.

Does the responsibility lie with the vendors of mobile browsers? Partially. Apple are only now getting round to adding [native support for scrollable elements][ios-scrolling]: so far, we’ve been stuck with a range of lovingly crafted fakeries that range from ‘pathetic’ to ‘uncanny valley’. The problem goes beyond the slow pace of change, though—even when the functionality required to implement higher-quality interaction _is_ in place, it’s often in such a way as to leave an inordinate amount of work to the app developer. A perfect example of this is the default behaviour of ‘clickable’ elements in Mobile Safari.

Tap a link, a button or indeed any element with a `click` event defined, and two unpleasant things happen. First, _nothing_, for 300 milliseconds. Then, an ugly dark-grey overlay—you know the one I'm talking about. Compared to the responsiveness of clickable UI elements in native apps, using a mobile app where every element behaves this way feels like operating your iPhone with someone else’s finger.

In developing [nnnnext](http://nnnnext.com), I quickly came to the decision that this was _not good enough_, and set about trying to fix it. First, I did the simplest thing. For each ‘tappable’ element:

1. Style the element with `-webkit-tap-highlight-color: rgba(0,0,0,0)` to hide the overlay.
2. Listen for the `touchstart` event and add a class to the element so you can style its ‘touched’ state.
3. Listen for the `touchmove` event, and remove the class if fired. This deactivates the button if the user moves their finger away or scrolls the page.
4. Listen for the `touchend` event. If the class is still there, remove it and fire the callback. Otherwise, do nothing.

For the initial release of nnnnext, this sufficed. Elements reacted _instantly_ when touched, and again when you lifted your finger. There was one niggle, though—if you scrolled the page and happened to touch a tappable element, you’d get a flash of blue as the `touchstart` and `touchmove` events fired in quick succession. Turns out that tap-highlighting of elements in iOS lists (for example the Settings app) _does_ have a delay on it (although it’s closer to 150ms[^click-delay]), and with good reason.

[^click-delay]: I suspect the reason Mobile Safari’s click delay is 300ms long is to allow time for the user to double-tap; nonetheless, this backwards-compatibility makes 99% of interactions sluggish. I’d have just broken `dblclick` events and been done with it.

Right then: we need our delay back, except we’ll make it shorter. What are the event listener semantics now?

They’re _horrible_, that’s what.

Event order                              | Desired effect
---------------------------------------- | --------------
touchstart, timeout, touchend            | Highlight on timeout, de-highlight and fire callback on touchend (“long tap”)
touchstart, touchend, timeout            | Fire callback on timeout (“short tap”)
touchstart, timeout, touchmove, touchend | Highlight, then de-highlight on touchmove (“long tap” cancelled by scrolling)
touchstart, touchmove, timeout, touchend | None (scroll)
touchstart, touchmove, touchend, timeout | None (scroll)

Good luck figuring that one out. I’ll skip forward now, as I promised up there in the first paragraph that I’d done the hard work for you. [jquery.tappable.js][jquery-tappable] implements the above behaviour, and falls back to `click` events in desktop browsers for good measure. Have fun!

[jquery-tappable]: https://github.com/aanand/jquery.tappable.js
[mobile-native]: http://cvil.ly/2011/06/19/pretenders-why-mobile-web-apps-should-stop-trying-to-act-like-native-apps/
[ios-scrolling]: http://cubiq.org/ios5-the-first-true-web-app-ready-platform

