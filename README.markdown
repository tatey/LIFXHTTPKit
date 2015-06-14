# LIFXHTTPKit

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

A nice Mac OS X framework for the LIFX HTTP API that has no external dependencies.
Generate a personal access token at https://cloud.lifx.com/settings.

``` swift
// Power on all the lights
let client = Client(accessToken: "c87c73a896b554367fac61f71dd3656af8d93a525a4e87df5952c6078a89d192")
client.fetch()
let all = client.allLightTarget()
all.setPower(true)

// Toggle power on one light
if let one = all.toLightTargets().first() {
  one.setPower(!one.power)
}

// Observe changes to one, many, or all lights
let observer = all.addObserver {
  if all.power {
    button.titleLabel?.text = "Turn Off"
  } else {
    button.titleLabel?.text = "Turn On"
  }
}

// ...and remove the observer when you're done
all.removeObserver(observer)
```

## Contributing

All patches and feedback welcome.

1. Fork it (https://github.com/tatey/LIFXHTTPKit/fork)
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Copyright

Copyright (c) 2015 Tate Johnson. All rights reserved. Licensed under the MIT license.
