# LIFXHTTPKit [![GitHub release](https://img.shields.io/github/release/tatey/LIFXHTTPKit.svg)](https://github.com/tatey/LIFXHTTPKit/releases/latest) [![GitHub license](https://img.shields.io/github/license/tatey/LIFXHTTPKit.svg)](https://raw.githubusercontent.com/tatey/LIFXHTTPKit/master/LICENSE.txt) [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

A nice iOS/watchOS/macOS framework for interacting with the [LIFX HTTP API](http://api.developer.lifx.com/docs)
that has no external dependencies. Suitable for use inside extensions.

Used by the [official LIFX iOS](https://itunes.apple.com/us/app/lifx/id657758311?mt=8) app and an open source Mac app, [Lighting](https://github.com/tatey/Lighting).

*NOTE: This is not an official LIFX project.*

## Build Dependencies

* Swift 3.0 (Xcode 8.3+)
* iOS 8.2+
* macOS 10.10+
* watchOS 2+

Looking for an earlier version of Swift?

* Use [2.0.0](https://github.com/tatey/LIFXHTTPKit/releases/tag/2.0.0) for Swift 2.3
* Use [1.0.0](https://github.com/tatey/LIFXHTTPKit/releases/tag/1.0.0) for Swift 2.2
* Use [0.0.2](https://github.com/tatey/LIFXHTTPKit/releases/tag/0.0.2) for Swift 1.3

## Installation

### [Carthage](https://github.com/Carthage/Carthage)

Add the following to your Cartfile:

```
github "tatey/LIFXHTTPKit"
```

Then run `$ carthage update`.

Follow the current instructions in [Carthage's README](https://github.com/Carthage/Carthage)
for up to date installation instructions.

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
  lightTarget.setPower(!lightTarget.power)
}
```

Restore a scene.

``` swift
if let scene = client.scenes.first {
  let lightTarget = client.lightTargetWithSelector(scene.toSelector())
  lightTarget.restoreState()
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

...and remove the observer when you're done.

``` swift
all.removeObserver(observer)
```

Get the light's state.

``` swift
lightTarget.selector // => <LightTargetSelector type: "id", value: "d3b2f2d97452">
lightTarget.power // => true
lightTarget.brightness // => 0.5
lightTarget.color // => <Color hue: 180.0, saturation: 1.0, kelvin: 3500>
lightTarget.label // => "Lamp 1"
```

## Concepts

LIFXHTTPKit has been built with macOS and iOS apps in mind. These APIs
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
   targets which share the same underlying light are notified of the change.

## Detailed Usage

`Client` and `LightTarget` are the core classes of LIFXHTTPKit. Clients are
configured with an access token and light targets represent one or many addressable
lights.

``` swift
let client = Client(accessToken: "c87c73a896b554367fac61f71dd3656af8d93a525a4e87df5952c6078a89d192")
client.fetch(completionHandler: { (error: NSError?) in -> Void
  // Error is nil if everything is A-OK.
})
```

Light targets are instantiated using selectors which are identifiers for
addressing lights. They are a first class concept in LIFXHTTPKit and several
convenience methods offer quick access.

The default light target is known as "all" and it addresses all of the
lights associated with the client.

``` swift
let all = client.allLightTarget()
all.setPower(true)
```

Light targets can be sliced into smaller light targets. The all light target
can be turned into many individual light targets for fine-grained control.

``` swift
let lightTargets = all.toLightTargets()
for lightTarget in lightTarget {
  lightTarget.setPower(true)
}
```

Light targets can be inspected at any time based on in-memory cache.

``` swift
lightTarget.selector // => <LightTargetSelector type: "all", value: "">
lightTarget.power // => true
lightTarget.brightness // => 0.5
lightTarget.color // => <Color hue: 180.0, saturation: 1.0, kelvin: 3500>
lightTarget.label // => "Lamp 1"
lightTarget.connected // => true
lightTarget.count // => 5
lightTarget.lights.first?.group // => <Group id: "1c8de82b81f445e7cfaafae49b259c71", name: "Lounge">
lightTarget.lights.first?.location // => <Location id: "1d6fe8ef0fde4c6d77b0012dc736662c", name: "Home">
lightTarget.touchedAt // => 2015-12-09 04:02:41 +0000
```

The in-memory cache is updated when the client fetches, or an operation is
performed. The results of the operation are inspected and lights which
have become disconnected are marked appropriately.

### Selectors

Any light target can be sliced into a light, group or location light target
using these convenience methods.

``` swift
// Get all lights associated with the account
let all = client.allLightTarget()

// Lights
let lights = all.toLightTargets()
for light in lights {
  light.setBrightness(0.5)
}

// Groups
let groups = all.toGroupTargets()
for group in groups {
  group.setBrightness(0.5)
}

// Locations
let locations = all.toLocationTargets()
for location in locations {
  location.setBrightness(0.5)
}
```

Alternatively instantiate a light target using a custom selector.

``` swift
let selector = LightTargetSelector(type: .GroupID, value: "1c8de82b81f445e7cfaafae49b259c71")
let lights = client.lightTargetWithSelector(selector)
lights.setBrightness(0.5)
```

Supported types are `.All`, `.ID`, `.GroupID`, `.LocationID`, and `.SceneID`.

### Scenes

Scenes are like a virtual group with a preset. Users create scenes with the official
suite of LIFX apps.

When used as a virtual group scenes let you address an arbitrary collection of lights.
This works great for creating nested groups or combining groups beyond their physical
location. You use them like normal light targets.

``` swift
if let scene = client.scenes.first {
  let lightTarget = client.lightTargetWithSelector(scene.toSelector())
  lightTarget.setPower(true)
}
```

When used as a preset you can restore the state of the virtual group as intended by
the creator of the scene. There is a special method called `restoreState` which
optimistically updates the local in-memory cache as well as making the appropriate
request to the LIFX HTTP API. All of this happens in a single operation.

``` swift
if let scene = client.scenes.first {
  let lightTarget = client.lightTargetWithSelector(scene.toSelector())
  lightTarget.restoreState()
}
```

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
      DispatchQueue.main.async {
        self.layer?.backgroundColor = self.lightTarget.color
      }
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
  `DispatchQueue` to jump to a different queue.
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

You can inspect an individual light's brightness instead of using the average in
mixed groups. See [Get Lights](#get-lights).

### Set Brightness

Set the brightness of the lights. A brightness of 75% is `0.75`. The `duration`
is optional and defaults to `0.5`. 

``` swift
lightTarget.setBrightness(1.0, duration: 0.5, completionHandler: { (results: [Result], error: NSError?) -> Void
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

You can inspect an individual light's color instead of using the average in mixed
groups. See [Get Lights](#get-lights).

### Set Color

Sets the color of the lights. The `duration` is optional and defaults to `0.5`.

``` swift
let color = Color.color(hue: 180.0, saturation: 1.0)
lightTarget.setColor(color, duration: 0.5, completionHandler: { (results: [Result], error: NSError?) -> Void
  // println(results)
})

let white = Color.white(kelvin: 3500)
lightTarget.setColor(color, duration: 0.5, completionHandler: { (results: [Result], error: NSError?) -> Void
  // println(results)
})
```

### Set State (Color, Brightness, and Power Simultaneously)

Sets the color, brightness, and power of the lights in one operation. The `duration` is optional and defaults to `0.5`.
All other arguments except are optional and default to `nil`. A `nil` value is the equivalent to leaving the
value unchanged.

``` swift
let color = Color.color(hue: 180.0, saturation: 1.0)
lightTarget.setState(color, brightness: 0.75, duration: 0.5, power: true, completionHandler: { (results: [Result], error: NSError?) -> Void
  // println(results)
})
```

### Restore State

**Scenes Only**: Sets the state of the lights as defined by the backing scene. The `duration` is optional and
defaults to `0.5`.

Calling this method on a non-scene based light target will set the error argument in the `completionHandler`
callback.

``` swift
lightTarget.restoreState(0.5, completionHandler: { (results: [Result], error: NSError?) -> Void
  // println(results)
})
```

### Get Label

Returns the label for the light target. If the light target is a group or
location then the label will be derived from the group or location.

``` swift
lightTarget.label // => "Lamp 1"
```

The "all" light target will always return `"All"` as the label.

### Get Connected

Determines if the lights are connected and reachable over the internet.
`true` if at least one light addressed by the light target is reachable.
`false` if all of the lights are unreachable.

``` swift
lightTarget.connected // => true
```

The connected property is updated each time an operation is performed
using the results returned in the response.

### Get Count

Returns the number of known lights addressable by the light target.

``` swift
lightTarget.count // => 5
```

### Get Lights

Inspect the lights addressable by the light target. If you're dealing
with a mixed group you can inspect each light individually.

``` swift
for light in lightTarget.lights {
  println(light.id)
}
```

A light has the following properties:

``` swift
light.id // => "d3b2f2d97452"
light.power // => true
light.brightness // => 0.5
light.color // => <Color hue: 180.0, saturation: 1.0, kelvin: 3500>
light.label // => "Lamp 1"
light.connected // => true
light.group // => <Group id: "1c8de82b81f445e7cfaafae49b259c71", name: "Lounge">
light.location // => <Location id: "1d6fe8ef0fde4c6d77b0012dc736662c", name: "Home">
light.productInfo // => <ProductInformation productName: "LIFX Color 1000", manufacturer: "LIFX", capabilities: <Capabilities hasColor: true, hasIR: false, hasMultiZone: false>>
```

The `group` and `location` properties are optional as they are not required by
the LIFX protocol. In practice these properties are always set.

## Testing

First, copy the example configuration file.

    $ cp Tests/Secrets.example.plist Tests/Secrets.plist

Then, paste a personal access token into the copied configuration file. The
access token must belong to an account that has at least one connected light.
You can generate a personal access tokens at https://cloud.lifx.com/settings.

Finally, run tests by selecting "Product > Tests" from the menu bar, or use the
"⌘ + U" shortcut.

## Copyright

Copyright (c) 2015-2016 Tate Johnson. All rights reserved. Licensed under the MIT license.
