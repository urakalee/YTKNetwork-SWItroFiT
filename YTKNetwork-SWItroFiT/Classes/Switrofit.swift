//
//  Switrofit.swift
//  YTKNetwork-SWItroFiT
//
//  Created by liqiang on 2020/8/14.
//

import Foundation
import YTKNetwork

public class RequestMethodWrapper<Model: Codable> {
    let url: String

    public init(_ url: String) {
        self.url = url
    }
}

@propertyWrapper
public class GET<Model: Codable>: RequestMethodWrapper<Model> {
    public var wrappedValue: YTKNetworkApiBuilder<Model> {
        return YTKNetworkApiBuilder<Model>().method(.GET).url(url)
    }
}

@propertyWrapper
public class POST<Model: Codable>: RequestMethodWrapper<Model> {
    private let contentType: YTKRequestSerializerType

    public init(_ url: String, contentType: YTKRequestSerializerType = .HTTP) {
        self.contentType = contentType
        super.init(url)
    }

    public var wrappedValue: YTKNetworkApiBuilder<Model> {
        return YTKNetworkApiBuilder<Model>().method(.POST).url(url).contentType(contentType)
    }
}
