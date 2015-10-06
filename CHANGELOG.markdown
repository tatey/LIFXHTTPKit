# Changelog

## Current

* Migrate from v1beta to v1 of the LIFX HTTP API.
* Deprecated `HTTPSession -setLightsPower:power:duration:completionHandler:` and `HTTPSession -setLightsColor:color:duration:powerOn:completionHandler:`. Use `HTTPSession -setLightsState:power:color:brightness:duration:completionHandler:` instead.
* Deprecated `LightTarget -setColor:brightness:power:duration:completionHandler:`. Use `LightTarget -setState:brightness:power:duration:completionHandler:` instead.
* Add support for iOS 8.0+.
* Add support for Swift 2/Xcode 7.0.

## 0.0.2 / 2015-09-02

* `LightTarget -setBrightness:duration:completionHandler:`, `LightTarget -setColor:duration:completionHandler:`, and `LightTarget -setColor:brightness:duration:power:completionHandler:` respects `power` parameter by optimistically updating in-memory cache.

## 0.0.1 / 2015-07-22

* Initial release
