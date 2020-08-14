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

    public func build() -> YTKNetworkApi<Model> {
        return build(with: "ignored()")
    }

    public func build(with signature: String, _ values: Any?...) -> YTKNetworkApi<Model> {
        guard
            let component = component,
            let _ = component.method, let _ = component.url else {
            assert(false, "method or url is not set")
        }
        let keys = getKeys(from: signature)
        return build(with: component, keys: keys, values: values)
    }

    /// - returns: nil if no arguments
    private func getKeys(from signature: String) -> [String] {
        guard let leftBracket = signature.firstIndex(of: "(") else {
            assert(false, "invalid signature: \(signature)")
        }
        guard let rightBracket = signature.lastIndex(of: ")") else {
            assert(false, "invalid signature: \(signature)")
        }
        let keyString = signature[signature.index(leftBracket, offsetBy: 1)..<rightBracket]
        let split = String(keyString).components(separatedBy: ":")
        guard split.count > 1 else {
            return [] // no arguments
        }
        // trim the last blank
        guard split[split.count - 1].count == 0 else {
            assert(false, "invalid signature: \(signature)")
        }
        let result = Array(split[0..<split.count - 1])

        for key in result {
            guard key != "_" else {
                assert(false, "do not use _ in signature: \(signature)")
            }
        }
        return result
    }

    private func build(with component: ApiComponent, keys: [String], values: [Any?]) -> YTKNetworkApi<Model> {
        guard keys.count == values.count else {
            assert(false, "key-values not match: \(keys) <=> \(values)")
        }
        let url = component.url!
        let pattern = "\\{([0-9a-zA-Z_]+)\\}"
        let keysInPath = matches(string: url, regex: pattern)
        // path
        var resultUrl = url
        var keyInPathSet = Set<String>()
        for key in keysInPath {
            keyInPathSet.insert(key)
            guard let index = keys.firstIndex(of: key) else {
                assert(false, "\(key) of \(url) not found in signature keys: \(keys)")
            }
            guard let value = values[index] else {
                assert(false, "value of \(key) in \(url) is nil: \(keys) <=> \(values)")
            }
            let mirrorDisplayStyle = Mirror(reflecting: value).displayStyle
            guard !(
                mirrorDisplayStyle == .struct
                    || mirrorDisplayStyle == .class
                    || mirrorDisplayStyle == .dictionary
            ) else {
                assert(false, "value of \(key) should be primitive type: \(value)")
            }
            resultUrl = resultUrl.replacingOccurrences(of: "{\(key)}", with: "\(value)")
        }
        let resultComponent = ApiComponent()
        resultComponent.method = component.method
        resultComponent.url = resultUrl
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
                }
                // filter nil value in arguments
                for (k, v) in args {
                    guard let v = v else {
                        continue
                    }
                    guard arguments[k] == nil else {
                        assert(false, "found duplicated \(k) in arguments")
                    }
                    arguments[k] = "\(v)"
                }
            } else {
                guard arguments[key] == nil else {
                    assert(false, "found duplicated \(key) in signature")
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
