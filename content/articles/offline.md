---
title: Offline Support is Valuable, and You Can’t Add it Later
kind: article
created_at: 2011-08-13 23:11
summary: Non-trivial offline functionality in a web application is more valuable than you might have initially assumed, if you care about the user experience on mobile devices. It’s also not a feature you can easily add after you’ve already built a working product. It has a profound effect on how your app should be designed, and you have to plan for it from the outset if you don’t want to end up rewriting the bulk of your communication logic.
---

<!-- w: tf -->

If you’re designing a web application to run primarily on desktop browsers, you’ve probably already decided against implementing offline functionality. That’s entirely fair: there’s almost always an Internet connection available, and you’ll save yourself a lot of time.

If you’re considering implementing a mobile interface, though, you would do well to seriously consider implementing offline support too, even though mobile users usually have an Internet connection. Let me explain.

Why It’s Valuable
-----------------

Mobile Internet connectivity is rubbish. I’m a Vodafone user living in London, and seeing the 3G icon in my iPhone’s status bar is as commonplace and pleasurable an event as finding somewhere you can sit down to drink on a Friday. This has profound implications for the assumptions you can make when designing the communication logic of your application, if you value the mobile user experience. To lay it out:

1. You can’t assume a request will complete in a short time.
2. You can’t assume a request will even make it to the server.
3. If it does, you can’t assume the response will make it back.
4. If the request does fail, you won’t know whether it made it to the server or not.
5. If the connection is slow, or flaky, it may well stay that way.

For every single type of request your application will make, you will have to deal with these limitations. Consequently, if you’ve come straight from the world of comparatively fast, always-on broadband, many things you’re used to doing are now anti-patterns. Off the top of my head:

1. When a user initiates an action that requires communication with the server, you can’t expect them to wait, doing nothing, until it’s succeeded—they could be waiting for minutes.
2. If the action fails due to network error, you can’t simply tell them to try again in a moment—if it failed once, it’ll probably fail again.
3. If the user wants to perform several such actions in quick succession, you _really_ can’t do either of the above two things. Have you ever used an application that worked that way? You can feel your hair greying.

An application designed along these traditional lines, built on the assumption that an Internet connection is not just available, but reliable and fast, will be incredibly frustrating to use over a poor-quality connection.

What I’m getting at is that offline support isn’t just a way of making your app usable when there’s no Internet connection. It can also be a way of making it usable when the Internet connection is awful, which, depending on the app, could be a much more common occurrence. You simply need to broaden your definition of “offline” to mean not just “there is no connection”, but “there is no _good_ connection”.

Why You Can’t Add it Later
--------------------------

As touched upon earlier, the workflow for processing actions in an application that assumes a fast, always-on Internet connection goes something like this:

1. User initiates action.
2. App makes request to server.
3. If the request succeeds, the UI is updated to reflect the changes to application state.
4. If the request fails, the user is notified.

The problem with this design is that the assumption of connectivity is fundamental. In the absence of a good Internet connection, it’s merely annoying. In the absence of any Internet connection at all, it fails at step 2.

The good news is that, in my limited experience, getting into the offline mindset requires only one key realisation: when you leave the world of timely, reliable communication, **the local database, not the server’s, must be the gateway for all persistent changes in application state**.

When I say “the local database”, I really mean [HTML5 Local Storage][local-storage], and when I say it must “be the gateway”, I mean the workflow must change to something resembling this:

1. User initiates action.
2. Changes to application state are persisted locally.
3. The UI is updated.
4. At some point—now or later—the local database and the server are synchronised.

Which, you might realise, is how native smartphone apps are designed. The good ones, anyway.

When your application is designed this way, its “offline” usability skyrockets. Many common user actions—checking off a todo, archiving an email, composing a blog post, reading something previously downloaded—can be performed with no latency and little to no loss in immediate utility. Indeed, Backbone.js’ [example todo app][backbone-todo] is a functional and useful application that never even needs to talk to a server.

The not-so-hidden cost of this approach, of course, is that you have a new responsibility: **you** must ensure every update makes it home. That means retrying requests when they fail. _That_ means ensuring actions are never processed twice, so my blog post doesn’t appear multiple times just because it got through the first time but the response never made it back. It might also mean preserving the order of actions performed.

In short, it means you have to carefully design your application for [eventual consistency][eventual-consistency]—given enough time, the server and the client will agree. Because the client is no longer a dumb terminal—it’s a node in a distributed system, with its own opinion of the current state of the application.

Indeed, “the current state of the application” no longer has a canonical meaning. What if the user has the application installed on two devices, and has made updates on both of them? Proceed far enough down this rabbit-hole and it becomes necessary to [leave behind the Newtonian universe][relativity].

If this sounds like more trouble than it’s worth... well, it might be. Your call. But I hope I’ve made the value of offline support clearer, and if you’re planning on implementing it, I hope you’re really _planning_ it.

[local-storage]: http://diveintohtml5.org/storage.html
[backbone-todo]: http://backbonejs.org/examples/todos/index.html
[eventual-consistency]: http://en.wikipedia.org/wiki/Eventual_consistency
[relativity]: http://afeinberg.github.com/2011/06/17/replication-atomicity-and-order-in-distributed-systems.html
