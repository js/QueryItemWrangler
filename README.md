# QueryItemWrangler

A type-safe and friendly Swift API for query items

## NSURLComponent.queryItem

queryItems is defined as `[NSURLQueryItem]?`, which makes it slightly annoying to work with if you need to grab and modify items in the query string:

* The array of `NSURLQueryItem`s is an Optional, which makes sense since the querystring may not be present. But still a hinderance when you want to work it
* `NSURLQueryItem` is immutable (good), so need to replaced into `queryItems`
* The value of `NSURLQueryItem` can be exactly one type (String)

While querystrings by nature are typed as strings, in practice we often want to grab an integer or boolean value from a querystring parameter.

## Usage

You'll initialize the `QueryItemWrangler` with an optional array of `NSURLQueryItem`:

```swift
let url = NSURL(string: "https://example.com?str=foo%20bar&num=42&flag=1&flag2=true")!
let components = NSURLComponents(URL: url, resolvingAgainstBaseURL: true)!
var wrangler = QueryItemWrangler(items: components.queryItems)
```

The simplest API is for reading and writing strings:

```swift
wrangler["str"] // => Optional("foo bar"))
wrangler["str"] = "baz"
wrangler["str"] // => Optional("baz"))
```

To work with other types, the `QueryItemKey` struct can be used to represent the item key/name and the type of its value:

```swift
let key = QueryItemKey<Int?>("num") // The type of "num" item is `Int?`
wrangler[key] // => Optional(42)
wrangler[key] = 84
wrangler[key] // => Optional(84)

wrangler[QueryItemKey<Int>("num")] // => 88
// Non-optional Int's default to 0 if the value is nil
wrangler[QueryItemKey<Int?>("num")] = nil
wrangler[QueryItemKey<Int>("num")] // => 0
wrangler[QueryItemKey<Int?>("num")] // => nil
```

Boolean values are either true or false (nil is false):

```swift
wrangler[QueryItemKey<Bool>("flag")] // => true
wrangler[QueryItemKey<Bool>("flag")] = false
wrangler[QueryItemKey<Bool>("flag")] // => false
wrangler[QueryItemKey<Bool>("flag2")] // => true
````

To update the originating NSURLComponents, simply assign to the queryItems property:
```swift
components.queryItems = wranger.queryItems
```


`QueryItemKey` can be used as subscripting in `QueryItemWrangler` for the following types:

* `String`
* `String?`
* `Int`
* `Int?`
* `Bool`

## Author

QueryItemWrangler was created by [Johan Sørensen](http://johansorensen.com)

## License

MIT, see LICENSE