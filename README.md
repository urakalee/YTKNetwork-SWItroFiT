# YTKNetwork-SWItroFiT
- A retrofit-like YTKNetwork Wrapper

[![License](https://img.shields.io/cocoapods/l/YTKNetwork-SWItroFiT.svg?style=flat)](https://cocoapods.org/pods/YTKNetwork-SWItroFiT)
[![CI Status](https://img.shields.io/travis/urakalee/YTKNetwork-SWItroFiT.svg?style=flat)](https://travis-ci.org/urakalee/YTKNetwork-SWItroFiT)
[![Version](https://img.shields.io/cocoapods/v/YTKNetwork-SWItroFiT.svg?style=flat)](https://cocoapods.org/pods/YTKNetwork-SWItroFiT)

## Usage
```swift
class DataService {
    @GET("data/items")
    private var listApiBuilder: YTKNetworkApiBuilder<ItemList>

    func listApi(startCursor: String, limit: Int = 20, arguments: [String: Any?]) -> YTKNetworkApi<ItemList> {
        return listApiBuilder.build(with: #function, startCursor, limit, arguments)
    }

    @GET("data/items/{itemId}")
    private var itemApiBuilder: YTKNetworkApiBuilder<Item>

    func itemApi(itemId: Int) -> YTKNetworkApi<Item> {
        return itemApiBuilder.build(with: #function, itemId)
    }
}

let service = DataService()
// request "data/items?startCursor=0&limit=20&key1=value1&key2=value2
let listApi = service.listApi(startCursor: "0", arguments: ["key1": 1, "key2": "value2", "key3": nil])
// request "data/items/123456
let itemApi = service.itemApi(itemId: 123456)

```
### Note
- Build function's parameters should consist in api function's, quantity and order
- DON'T use _ to omit api function's parameter name
- 'arguments' is reserved for batch adding queries, which type should be [String: Any?], and nil value will be ignored

## Requirements
- Swift 5.1+
- YTKNetwork 3.0+

## Installation

YTKNetwork-SWItroFiT is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'YTKNetwork-SWItroFiT'
```

## Author

liqiang, uraka.lee(at)gmail.com

## Todo
- [] POST
- [] Check #function in release build
- [] PUT
- [] DELETE
- [] Easy mock for unit test

## License

YTKNetwork-SWItroFiT is available under the MIT license. See the LICENSE file for more info.
