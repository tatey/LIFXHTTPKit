# LIFXHTTPKit

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

A nice Mac OS X framework for the [LIFX HTTP API](http://api.developer.lifx.com/docs)
that has no external dependencies. Generate a personal access token at https://cloud.lifx.com/settings.

## Quick Usage

Power on all the lights.

``` swift
let client = Client(accessToken: "c87c73a896b554367fac61f71dd3656af8d93a525a4e87df5952c6078a89d192")
client.fetch()
let all = client.allLightTarget()
all.setPower(true)
```

Toggle power on one light.

``` swift
if let lightTarget = all.toLightTargets().first() {
  lightTarget.setPower(!one.power)
}
```

Use a closure to find out when the request completes.

``` swift
lightTarget.setPower(true) { (results, error) in
  if error != nil {
    println(error)
  } else {
    println(results)
  }
}
```

Use a closure to observer changes to lights.

``` swift
let observer = all.addObserver {
  if all.power {
    button.titleLabel?.text = "Turn Off"
  } else {
    button.titleLabel?.text = "Turn On"
  }
}
```

And remove the observer when you're done.

``` swift
all.removeObserver(observer)
```

## Core Concepts

LIFXHTTPKit has been built with Mac OS X and iOS apps in mind. We encourage you
to use these high level APIs which make it easy to consume the LIFX HTTP API
without worrying about the specifics of HTTP and managing state.

Keep these concepts in the back of your mind when using LIFXHTTPKit:

1. Everything is a collection. If you're dealing with one light, it's just a
   collection with one element. If you're dealing with many lights, it's a
   collection with many elements. Collections can be sliced into smaller collections.
   Each collection is a new instance and they're known as a `LightTarget`.
2. Everything is asynchronous and optimistic. If you tell a light target to power on
   then the cached property is updated and observers are notified. In the
   instance of failure the property reverts back to its original value.
   Requests are queued and handled in-order.
3. Observers use a closure based interface. It's fast, light weight and non-magical.
4. Core state is immutable and shared between all instances of `LightTarget`.
   If you power on one light target than all light targets which share the same
   underlying light are notified of the change.
5. LIFXHTTPKit wraps the messiness of HTTP and JSON giving you type safety and
   idiomatic APIs for interacting with the LIFX HTTP API. The library itself has
   no external dependencies and wraps `NSURLSession`.

## Client Usage

Keep these assumptions in the back of your mind reading reading client usage:

* All operations are asynchronous and these examples demonstrate how to
  use the completion handler. The completion handler is completely optional
  and can be safely omitted.
* Closures use verbose syntax for clarity when reading. We encourage you to
  use the shorthand syntax in Xcode where you'll get inline errors and type
  inferencing.
* `Client` and `LightTarget` are the bread and butter of using LIFXHTTPKit.
  All examples assume a configured client and light target.
* Only a subset of the LIFX HTTP API is implemented. We've built this to
  scratch our own itch and we don't need effects. Patches are welcome.

### Setup

Configure the client and seed it with lights.

``` swift
let client = Client(accessToken: "c87c73a896b554367fac61f71dd3656af8d93a525a4e87df5952c6078a89d192")
client.fetch(completionHandler: { (error: NSError?) in -> Void
  // Error is nil if everything is A-OK.
})
```

Then get a light target using a selector. Selectors are identifiers for
addressing lights and are a first class concept in LIFXHTTPKit. By default
you get a `LightTarget` which addresses all the lights associated with
the account.

``` swift
let all = client.allLightTarget()
```

This is the most efficient way to quickly perform operations on an entire
collection of lights. In fact, a selector which addresses a collection of lights
will always be more efficient than addressing individual lights yourself.

Don't worry, you can still get fine grained control over individual lights by
slicing a big light target into lots of little light targets. Here's how to get
a light target for all the lights associated with the account.

``` swift
let lightTarget = all.toLightTargets()
for lightTarget in lightTarget {
  lightTarget.powerOn(true)
}
```

### Light

TODO: Document

### Result

TODO: Document

### Observers

TODO: Document

### Set Power

Turn lights on or off. `true` to turn on, `false` to turn off. The `duration`
is optional and defaults to `0.5`.

``` swift
lightTarget.setPower(true, duration: 0.5, completionHandler: { (results: [Result], error: NSError?) -> Void
  // println(results)
})
```

Toggle power based on the cached state of the light.

``` swift
lightTarget.setPower(!light.power)
```

### Set Brightness

TODO: Document

### Set Color

TODO: Document

### Set Color and Brightness

TODO: Document

## Testing

First, copy the example configuration file.

    $ cp Tests/Secrets.example.plist Tests/Secrets.plist

Then, paste a personal access token into the copied configuration file. The
access token must belong to an account that has at least one connected light.
You can generate a personal access tokens at https://cloud.lifx.com/settings.

Finally, run tests by selecting "Product > Tests" from the menu bar, or use the
"⌘ + U" shortcut.

## Contributing

All patches and feedback welcome.

1. Fork it (https://github.com/tatey/LIFXHTTPKit/fork)
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Copyright

Copyright (c) 2015 Tate Johnson. All rights reserved. Licensed under the MIT license.
