//
//  YTKNetworkApi.swift
//  YTKNetwork-SWItroFiT
//
//  Created by liqiang on 2020/8/14.
//

import Foundation
import YTKNetwork

class ApiComponent: WithScope {
    var method: YTKRequestMethod!
    var url: String!
    var contentType: YTKRequestSerializerType = .HTTP
    var arguments: [String: String]?
}

public class YTKNetworkApi<Model: Codable>: YTKRequest {
    private let component: ApiComponent

    fileprivate init(_ component: ApiComponent) {
        self.component = component
    }

    override public func requestMethod() -> YTKRequestMethod {
        return component.method
    }

    override public func requestUrl() -> String {
        return component.url
    }

    override public func requestSerializerType() -> YTKRequestSerializerType {
        return component.contentType
    }

    override public func requestArgument() -> Any? {
        return component.arguments
    }

    public func result() -> Model? {
        return responseDecodable()
    }
}

public class YTKNetworkApiBuilder<Model: Codable> {
    private var component: ApiComponent?

    func method(_ method: YTKRequestMethod) -> YTKNetworkApiBuilder<Model> {
        component = (component ?? ApiComponent()).also {
            $0.method = method
        }
        return self
    }

    func url(_ url: String) -> YTKNetworkApiBuilder<Model> {
        component = (component ?? ApiComponent()).also {
            $0.url = url
        }
        return self
    }

    func contentType(_ contentType: YTKRequestSerializerType) -> YTKNetworkApiBuilder<Model> {
        component = (component ?? ApiComponent()).also {
            $0.contentType = contentType
        }
        return self
    }

    public func build() -> YTKNetworkApi<Model> {
        return build(with: "ignored()")
    }

    private var emptyApi: YTKNetworkApi<Model> {
        return YTKNetworkApi<Model>(ApiComponent())
    }

    private func reset() {
        component = nil
    }

    public func build(with signature: String, _ values: Any?...) -> YTKNetworkApi<Model> {
        guard
            let component = component,
            let _ = component.method, let _ = component.url else {
            assert(false, "method or url is not set")
            return emptyApi
        }
        guard let keys = getKeys(from: signature) else {
            return emptyApi
        }
        guard let result = build(with: component, keys: keys, values: values) else {
            return emptyApi
        }
        reset() // no need to reset when return emptyApi since it's not valid build
        return result
    }

    /// - returns: nil if no arguments
    private func getKeys(from signature: String) -> [String]? {
        guard let leftBracket = signature.firstIndex(of: "(") else {
            assert(false, "invalid signature: \(signature)")
            return nil
        }
        guard let rightBracket = signature.lastIndex(of: ")") else {
            assert(false, "invalid signature: \(signature)")
            return nil
        }
        let keyString = signature[signature.index(leftBracket, offsetBy: 1)..<rightBracket]
        let split = String(keyString).components(separatedBy: ":")
        if split.count == 1 {
            return [] // no arguments
        }
        // trim the last blank
        guard split[split.count - 1].count == 0 else {
            assert(false, "invalid signature: \(signature)")
            return nil
        }
        let result = Array(split[0..<split.count - 1])

        for key in result {
            guard key != "_" else {
                assert(false, "do not use _ in signature: \(signature)")
                return nil
            }
        }
        return result
    }

    private func build(with component: ApiComponent, keys: [String], values: [Any?]) -> YTKNetworkApi<Model>? {
        guard keys.count == values.count else {
            assert(false, "key-values not match: \(keys) <=> \(values)")
            return nil
        }
        let url = component.url!
        // path
        var resultUrl = ""
        var keyInPathSet = Set<String>()
        let pathItems = url.components(separatedBy: "/")
        for (index, item) in pathItems.enumerated() {
            if index > 0 {
                resultUrl.append("/")
            }
            if let leftBrace = item.lastIndex(of: "{") {
                // argument in path
                guard leftBrace == item.startIndex else {
                    assert(false, "invalid \(item).leftBrace in path: \(url)")
                    return nil
                }
                guard let rightBrace = item.firstIndex(of: "}") else {
                    assert(false, "invalid \(item).noRightBrace in path: \(url)")
                    return nil
                }
                guard rightBrace == item.index(item.endIndex, offsetBy: -1) else {
                    assert(false, "invalid \(item).rightBrace in path: \(url)")
                    return nil
                }
                let key = String(item[item.index(leftBrace, offsetBy: 1)..<rightBrace])
                keyInPathSet.insert(key)
                guard let index = keys.firstIndex(of: key) else {
                    assert(false, "\(key) of \(url) not found in signature keys: \(keys)")
                    return nil
                }
                guard let value = values[index] else {
                    assert(false, "value of \(key) in \(url) is nil: \(keys) <=> \(values)")
                    return nil
                }
                let mirrorDisplayStyle = Mirror(reflecting: value).displayStyle
                guard !(
                    mirrorDisplayStyle == .struct
                        || mirrorDisplayStyle == .class
                        || mirrorDisplayStyle == .dictionary
                ) else {
                    assert(false, "value of \(key) should be primitive type: \(value)")
                    return nil
                }
                resultUrl.append("\(value)")
            } else {
                guard item.firstIndex(of: "}") == nil else {
                    assert(false, "invalid \(item).noLeftBrace in path: \(url)")
                    return nil
                }
                let match = matches(string: item, regex: "^[0-9a-zA-Z]*$")
                guard match.count == 1, match[0] == item else {
                    assert(false, "invalid '\(item)' in path: '\(url)'")
                    return nil
                }
                resultUrl.append(item)
            }
        }
        let resultComponent = ApiComponent()
        resultComponent.method = component.method
        resultComponent.url = resultUrl
        resultComponent.contentType = component.contentType
        // query
        var arguments: [String: String] = [String: String]()
        for (index, key) in keys.enumerated() {
            // pass keys in path
            if keyInPathSet.contains(key) {
                continue
            }
            // pass nil value in query
            guard let value = values[index] else {
                continue
            }
            if key == "arguments" {
                guard let args = value as? [String: Any?] else {
                    assert(false, "value of arguments should be [String:Any?]: \(value)")
                    return nil
                }
                // filter nil value in arguments
                for (k, v) in args {
                    guard let v = v else {
                        continue
                    }
                    guard arguments[k] == nil else {
                        assert(false, "found duplicated \(k) in arguments")
                        return nil
                    }
                    arguments[k] = "\(v)"
                }
            } else {
                guard arguments[key] == nil else {
                    assert(false, "found duplicated \(key) in signature")
                    return nil
                }
                arguments[key] = "\(value)"
            }
        }
        resultComponent.arguments = arguments
        // body
        // TODO:
        return YTKNetworkApi<Model>(resultComponent)
    }
}
