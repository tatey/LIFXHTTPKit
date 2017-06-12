# Changelog

## 3.0.0 / 2017-06-12

* **(Breaking)** Add support for Swift 3.0.
* Expose `productInfo` on `Light` for determining product features.

## 2.0.0 / 2016-07-08

* **(Breaking)** Add support for watchOS 2.0. Minimum iOS target raised to 8.2.
* Expose `lastTouched` to `Light` and `LightTarget` for determining the freshness of remotely fetched data.

## 1.0.0 / 2015-10-28

* Migrate from v1beta to v1 of the LIFX HTTP API.
* Add support for iOS 8.0+.
* **(Breaking)** Add support for Swift 2. You must build with Xcode 7.0+.
* Add support for light target based scenes.
* Add codified errors for various HTTP status codes.
* Changed `Client` initializers to optionally take cached lights and scenes for faster restore.
* Changed `HTTPSession` initializer to take `delegateQueue` and `timeout` arguments.
* Changed `HTTPSession` to guarantee requests are performed serially, in-order.
* **(Breaking)** Changed the completion handler in `Client -fetch:` to pass an array of aggregated errors instead of a single optional error.
* **(Breaking)** Renamed `Selector` to `LightTargetSelector` for better interoperability in Xcode 7. Unfortunately a breaking change was unavoidable.
* Publicly exposed `session` on `Client` to easily get a configured session from the client.
* Publicly exposed `lights` and `scenes` as read-only on `Client` making it possible to inspect the state of the client.
* Publicly exposed `lights` as read-only on `LightTarget` in favour of calling `toLights()` to be consistent with `Client`.
* Publicly exposed `baseURL`, `delegateQueue`, and `URLSession` as read-only on `HTTPSession`.
* Deprecated constructing selectors with `.Label` type.
* Deprecated `HTTPSession -setLightsPower:power:duration:completionHandler:` and `HTTPSession -setLightsColor:color:duration:powerOn:completionHandler:`. Use `HTTPSession -setLightsState:power:color:brightness:duration:completionHandler:` instead.
* Deprecated `LightTarget -setColor:brightness:power:duration:completionHandler:`. Use `LightTarget -setState:brightness:power:duration:completionHandler:` instead.
* Deprecated `LightTarget -toLights`. Use the `lights` property instead.

## 0.0.2 / 2015-09-02

* `LightTarget -setBrightness:duration:completionHandler:`, `LightTarget -setColor:duration:completionHandler:`, and `LightTarget -setColor:brightness:duration:power:completionHandler:` respects `power` parameter by optimistically updating in-memory cache.

## 0.0.1 / 2015-07-22

* Initial release
