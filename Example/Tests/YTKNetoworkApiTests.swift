//
//  YTKNetoworkApiTests.swift
//  YTKNetwork-SWItroFiT_Tests
//
//  Created by liqiang on 2020/8/14.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Quick
import Nimble
@testable import YTKNetwork_SWItroFiT

class YTKNetworkApiTests: QuickSpec {
    override func spec() {
        describe("Test GET") {
            context("no argument") {
                class NoArgumentService {
                    @GET("path/with/no/argument")
                    private var apiBuilder: YTKNetworkApiBuilder<EmptyResult>

                    func api() -> YTKNetworkApi<EmptyResult> {
                        return apiBuilder.build()
                    }
                }

                let api = NoArgumentService().api()
                it("get with no argument") {
                    expect(api.requestMethod()) == .GET
                    expect(api.requestUrl()) == "path/with/no/argument"
                }
            }
            context("argument in path") {
                class PathArgumentService {
                    @GET("path/with/arg1/{arg1}/arg2/{arg2}")
                    private var apiBuilder: YTKNetworkApiBuilder<EmptyResult>

                    func api(arg1: Int, arg2: String) -> YTKNetworkApi<EmptyResult> {
                        return apiBuilder.build(with: #function, arg1, arg2)
                    }

                    func api() -> YTKNetworkApi<EmptyResult> {
                        return apiBuilder.build()
                    }

                    func api(arg2: Int) -> YTKNetworkApi<EmptyResult> {
                        return apiBuilder.build(with: #function, arg2)
                    }
                }

                it("valid argument") {
                    let api = PathArgumentService().api(arg1: 666, arg2: "xyz")
                    expect(api.requestMethod()) == .GET
                    expect(api.requestUrl()) == "path/with/arg1/666/arg2/xyz"
                }
                it("no argument") {
                    expect { PathArgumentService().api() }.to(throwAssertion())
                }
                it("less argument") {
                    expect { PathArgumentService().api(arg2: 666) }.to(throwAssertion())
                }
            }
            context("argument in query") {
                class QueryArgumentService {
                    @GET("url")
                    private var apiBuilder: YTKNetworkApiBuilder<EmptyResult>

                    func api(arg1: Int, arg2: String) -> YTKNetworkApi<EmptyResult> {
                        return apiBuilder.build(with: #function, arg1, arg2)
                    }

                    func api(arg1: Int, arguments: [String: Any?]) -> YTKNetworkApi<EmptyResult> {
                        return apiBuilder.build(with: #function, arg1, arguments)
                    }
                }

                it("arguments") {
                    let api = QueryArgumentService().api(arg1: 666, arg2: "xyz")
                    let arguments = api.requestArgument() as? [String: String]
                    expect(arguments?.count) == 2
                    expect(arguments?["arg1"]) == "666"
                    expect(arguments?["arg2"]) == "xyz"
                }
                it("dict arguments") {
                    let args: [String: Any?] = ["key1": 1, "key2": "s2", "key3": nil]
                    let api = QueryArgumentService().api(arg1: 666, arguments: args)
                    let arguments = api.requestArgument() as? [String: String]
                    expect(arguments?.count) == 3
                    expect(arguments?["arg1"]) == "666"
                    expect(arguments?["key1"]) == "1"
                    expect(arguments?["key2"]) == "s2"
                }
            }
            context("argument in path and query") {
                class ArgumentService {
                    @GET("path/with/arg1/{arg1}")
                    private var apiBuilder: YTKNetworkApiBuilder<EmptyResult>

                    func api(arg1: Int, arg2: String, arguments: [String: Any?]) -> YTKNetworkApi<EmptyResult> {
                        return apiBuilder.build(with: #function, arg1, arg2, arguments)
                    }
                }

                it("valid arguments") {
                    let args: [String: Any?] = ["key1": 1, "key2": "s2"]
                    let api = ArgumentService().api(arg1: 666, arg2: "xyz", arguments: args)
                    expect(api.requestUrl()) == "path/with/arg1/666"
                    let arguments = api.requestArgument() as? [String: String]
                    expect(arguments?.count) == 3
                    expect(arguments?["arg2"]) == "xyz"
                    expect(arguments?["key1"]) == "1"
                    expect(arguments?["key2"]) == "s2"
                }
            }
        }
        describe("Test POST") {}
        describe("Test PUT") {}
        describe("Test DELETE") {}
    }
}
