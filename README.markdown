# LIFXHTTPKit

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

A nice Mac OS X framework for the [LIFX HTTP API](http://api.developer.lifx.com/docs)
that has no external dependencies. Generate a personal access token at https://cloud.lifx.com/settings.

*Note: This is not an official LIFX project and the API may continue to change*

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

## Concepts

LIFXHTTPKit has been built with Mac OS X and iOS apps in mind. These APIs
make it easy to consume the LIFX HTTP API without worrying about the specifics
of HTTP or maintaining state.

Keep these concepts in the back of your mind when using LIFXHTTPKit:

1. Everything is a collection. If you're dealing with one light, it's just a
   collection with one element. If you're dealing with many lights, it's a
   collection with many elements. Collections can be sliced into smaller collections.
   Each collection is a new instance and they're known as a `LightTarget`.
2. Everything is asynchronous and optimistic. If you tell a light target to power on,
   then the cached property is immediately updated and observers are notified.
   If there is a failure the property reverts back to is original value. Operations
   are handled serially, in-order, and in a background queue.
3. Observers are closure based and notify listeners when state changes. Binding views
   to state using observers means you can consolidate your view logic into discrete
   methods that respond to network and local changes.
4. Light state is maintained by an instance of `Client` and shared between all
   instances of `LightTarget`. If you power on one light target then all light
   targets which share the same underline light are notified of the change.

## Detailed Usage

`Client` and `LightTarget` are the core classes of LIFXHTTPKit. Clients are
configured with an access token and light targets represent addressable lights.

``` swift
let client = Client(accessToken: "c87c73a896b554367fac61f71dd3656af8d93a525a4e87df5952c6078a89d192")
client.fetch(completionHandler: { (error: NSError?) in -> Void
  // Error is nil if everything is A-OK.
})
```

Light targets are instantiated using selectors. Selectors are identifiers
for addressing one or many lights. They are a first class concept in
LIFXHTTPKit and several convenience methods offer quick access.

The default light target is known as "all" and it addresses all of the
lights associated with the client.

``` swift
let all = client.allLightTarget()
all.powerOn(true)
```

Light targets can be sliced into smaller light targets. The all light target
can be turned into many individual light targets for fine-grained control.

``` swift
let lightTargets = all.toLightTargets()
for lightTarget in lightTarget {
  lightTarget.powerOn(true)
}
```

Light targets can be inspected at any time based on in-memory cache.

``` swift
lightTarget.power # => true
lightTarget.brightness # => 0.5
lightTarget.color # => <Color hue: 180.0, saturation: 1.0, kelvin: 3500>
lightTarget.label # => "Lamp 1"
lightTarget.connected # => true
lightTarget.count # => 5
```

Cache is updated when the client fetches, or an operation is performed.
The results of the operation are inspected and lights which have become
disconnected are marked appropriately.

### Observers

Use observers to opt-in to light target state changes. State may change
as the result of a network response, or a locally initiated operation.
Either way, you're less likely to have bugs if you place your logic
for updating views here.

``` swift
class LightView: NSView {
  // ...

  var observer: LightTargetObserver?
  var lightTarget: LightTarget

  func setupObserver()
    observer = lightTarget.addObserver({ () -> Void
      dispatch_async(dispatch_get_main_queue(), { () -> Void in
        self.layer?.backgroundColor = self.lightTarget.color
      })
    })
  }

  deinit {
    if let observer = self.observer {
      lightTarget.removeObserver(observer)
    }
  }

  // ...
}
```

Keep these things in the back of your mind when using observers:

* Observers may be notified in the background queue of the client. You can use
  `dispatch_async` to jump to a different queue.
* Observers must be explicitly removed to prevent memory leaks. The destructor
  is a good place to remove an observer in the object lifecycle. You can
  add as many observers as you want as long as you remove them when you're done.

### Get Power

Determine if the light target is powered on. `true` if any of the `connected`
lights in the light target are powered on.

``` swift
lightTarget.power // => true
```

### Set Power

Turn lights on or off. `true` to turn on, `false` to turn off. The `duration`
is optional and defaults to `0.5`. The duration controls the length of time
it takes for the light to change from on to off, or vise versa.

``` swift
lightTarget.setPower(true, duration: 0.5, completionHandler: { (results: [Result], error: NSError?) -> Void
  // println(results)
})
```

### Get Brightness

Returns the average of the brightness for connected lights if the light target
contains mixed brightnesses. A brightness of 0% is `0.0` and a brightness of
100% is `1.0`.

``` swift
lightTarget.brightness // => 0.5
```

### Set Brightness

Set the brightness of the lights. A brightness of 75% is `0.75`. The `duration`
is optional and defaults to `0.5`. `powerOn` is optional and defaults to
`true`. If `powerOn` is false then the operation has no physical effect
on the lights until it is powered on.

``` swift
lightTarget.setBrightness(1.0, duration: 0.5, powerOn: true, completionHandler: { (results: [Result], error: NSError?) -> Void
  // println(results)
})
```

### Get Color

Returns the average of the colors for connected lights if the light target
contains mixed colors.

``` swift
lightTarget.color // => <Color hue: 180.0, saturation: 1.0, kelvin: 3500>
```

LIFX lights represent color using hue/saturation and whites using kelvin.
Determine if a light is white or color using these predicates.

``` swift
let color = lightTarget.color
color.isWhite // => false
color.isColor // => true
```

### Set Color

Sets the color of the lights. The `duration` is optional and defaults to `0.5`.
`powerOn` is optional and defaults to `true`. If `powerOn` is false then the
operation has no physical effect on the lights until it is powered on.

``` swift
let color = Color.color(hue: 180.0, saturation: 1.0)
lightTarget.setColor(color, duration: 0.5, powerOn: true, completionHandler: { (results: [Result], error: NSError?) -> Void
  // println(results)
})

let white = Color.white(kelvin: 3500)
lightTarget.setColor(color, duration: 0.5, powerOn: true, completionHandler: { (results: [Result], error: NSError?) -> Void
  // println(results)
})
```

### Set Color and Brightness Simultaneously

Sets the color and brightness of the lights in one operation. The `duration` is
optional and defaults to `0.5`.  `powerOn` is optional and defaults to `true`.
If `powerOn` is false then the operation has no physical effect on the lights
until it is powered on.

``` swift
let color = Color.color(hue: 180.0, saturation: 1.0)
lightTarget.setColor(color, brightness: 0.75, duration: 0.5, powerOn: true, completionHandler: { (results: [Result], error: NSError?) -> Void
  // println(results)
})
```

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
