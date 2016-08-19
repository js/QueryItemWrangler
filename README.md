# QueryItemWrangler

A type-safe and friendly Swift API for query items.

`NSURLComponents` has easy access to query items, the problem is they're stored in an optional array of objects. QueryItemWrangler makes it easy to query for query item values in a type-safe manner.

Instead of jumping through these hoops:

```swift
let url = NSURL(string: "https://example.com/things?id=42")!
let components = NSURLComponents(URL: url, resolvingAgainstBaseURL: true)!

if let item =  components.queryItems?.filter({ $0.name == "id" }).first {
    if let value = item.value, let intValue = Int(value) {
        print("Finally, we got that int: \(intValue)") // intValue is 42
    }
}
```

You can easily get the same value like this:

```swift
let wrangler = QueryItemWrangler(items: components.queryItems)
let value = wrangler[QueryItemKey<Int>("id")] // => Optional(42)
print("That was too easy to get \(value)")
```

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
let key = QueryItemKey<Int>("num") // The type of the value of the item named "num" is `Int?`
wrangler[key] // => Optional(42)
wrangler[key] = 84
wrangler[key] // => Optional(84)

wrangler[QueryItemKey<Int>("num")] // => Optional(88)
// Non-optional Int's default to 0 if the value is nil
wrangler[QueryItemKey<Int>("num")] = nil
wrangler[QueryItemKey<Int>("num")] // => nil
```

Boolean values are either true or false (nil is false):

```swift
wrangler[QueryItemKey<Bool>("flag")] // => true
wrangler[QueryItemKey<Bool>("flag")] = false
wrangler[QueryItemKey<Bool>("flag")] // => false
wrangler[QueryItemKey<Bool>("flag2")] // => true
````

If a the item is not present, `false` will still be returned

To update the originating NSURLComponents, simply assign to the queryItems property:
```swift
components.queryItems = wrangler.queryItems
```

### Supported types

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