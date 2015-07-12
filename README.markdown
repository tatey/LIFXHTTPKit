# LIFXHTTPKit

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

A nice Mac OS X framework for the LIFX HTTP API that has no external dependencies.
Generate a personal access token at https://cloud.lifx.com/settings.

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
if let one = all.toLightTargets().first() {
  one.setPower(!one.power)
}
```

Use a closure to find out when the request completes.

``` swift
one.setPower(true) { (results, error) in
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

1. Everything is a collection. If you're dealing with one light, it's just a
   collection with one element. If you're dealing with many lights, it's a
   collection with many elements. Collections can be sliced into smaller collections.
   Each collection is a new instance and they're known as a `LightTarget`
2. Everything is asynchronous and optimistic. If you tell a light target to power on
   then the cached property is updated and observers are notified. In the
   instance of failure the property reverts back to its original value.
   Requests are handled in order.
3. Observers use a closure based interface. It's light weight and non-magical.
4. Core state is immutable and shared between all instances of `LightTarget`.
   If you power on one light target than all light targets which share the same
   underlying light are notified of the change.
5. Low-level API is available. If you're not interested in `LightTarget` then
   you can use `HTTPSession` for interacting directly with the HTTP API while
   still benefiting from type safety.

## Testing

First, copy the example configuration file.

    $ copy Tests/Secrets.example.plist Tests/Secrets.plist

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
