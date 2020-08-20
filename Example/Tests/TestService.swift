//
//  TestService.swift
//  YTKNetwork-SWItroFiT_Tests
//
//  Created by liqiang on 2020/8/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import YTKNetwork
import YTKNetwork_SWItroFiT
import Mantle

public extension String {
    func result<Model: MTLModel>() -> Model? {
        guard let data = self.data(using: .utf8) else { return nil }
        do {
            guard let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
            else { return nil }
            return try MTLJSONAdapter.model(of: Model.self, fromJSONDictionary: json, error: ()) as? Model
        } catch {
            debugPrint("\(self), \(Model.self), Decode Error: \(error)")
            assert(false)
            return nil
        }
    }
}

public extension YTKRequest {
    func result<Model: MTLModel>() -> Model? {
        guard let json = self.responseJSONObject as? [String: Any] else { return nil }
        do {
            return try MTLJSONAdapter.model(of: Model.self, fromJSONDictionary: json, error: ()) as? Model
        } catch {
            debugPrint("\(self), \(Model.self), Decode Error: \(error)")
            assert(false)
            return nil
        }
    }
}

@objc
public extension YTKRequest {
    func parseTestClass() -> TestClass? {
        return self.result()
    }
}

@objcMembers
public class TestService: NSObject {
    @GET("test-service/{device}/path/{a}/{b}")
    private var testApiBuilder: YTKNetworkApiBuilder<TestClass>

    public func testApi(a: Int, b: Int64, c: Bool, d: String, e: String? = nil) -> YTKRequest {
        return testApiBuilder.build(with: #function, a, b, c, d, e).asRequest()
    }
}
