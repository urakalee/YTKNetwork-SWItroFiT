//
//  Switrofit.swift
//  YTKNetwork-SWItroFiT
//
//  Created by liqiang on 2020/8/14.
//

import Foundation
import YTKNetwork

@propertyWrapper
public struct GET<Model: Codable> {
    private let url: String

    public init(_ url: String) {
        self.url = url
    }

    public var wrappedValue: YTKNetworkApiBuilder<Model> {
        return YTKNetworkApiBuilder<Model>().method(.GET).url(url)
    }
}
