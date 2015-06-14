# LIFXHTTPKit

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

A nice Mac OS X framework for the LIFX HTTP API that has no external dependencies.
Generate a personal access token at https://cloud.lifx.com/settings.

This is *not* an official LIFX project and exists only to scratch my own itch.

``` swift
let client = Client(accessToken: "c87c73a896b554367fac61f71dd3656af8d93a525a4e87df5952c6078a89d192")
client.fetch()
let lights = client.allLights()
lights.setPower(true, duration: 1.0)
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
