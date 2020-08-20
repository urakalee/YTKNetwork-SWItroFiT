//
//  YTKNetworkApiBuilderTests.swift
//  YTKNetwork-SWItroFiT_Tests
//
//  Created by liqiang on 2020/8/14.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Quick
import Nimble
@testable import YTKNetwork_SWItroFiT

class YTKNetworkApiBuilderTest: QuickSpec {
    override func spec() {
        var builder: YTKNetworkApiBuilder<EmptyResult>!
        beforeEach {
            builder = YTKNetworkApiBuilder<EmptyResult>()
        }
        describe("test build") {
            context("no method") {
                it("no url") {
                    expect { builder.build() }.to(throwAssertion())
                }
                it("with url") {
                    builder.url("url")
                    expect { builder.build() }.to(throwAssertion())
                }
            }
            context("with method") {
                beforeEach {
                    builder.method(.GET)
                }
                it("no url") {
                    expect { builder.build() }.to(throwAssertion())
                }
                it("with url") {
                    builder.url("url")
                    let api = builder.build()
                    expect(api.requestMethod()) == .GET
                    expect(api.requestUrl()) == "url"
                }
            }
        }
        describe("test build path") {
            it("valid path with no argument") {
                expect(builder.method(.GET).url("").build().requestUrl()) == ""
                expect(builder.method(.GET).url("/").build().requestUrl()) == "/"
                expect(builder.method(.GET).url("url/").build().requestUrl()) == "url/"
                expect(builder.method(.GET).url("/url").build().requestUrl()) == "/url"
                expect(builder.method(.GET).url("part1/part2").build().requestUrl()) == "part1/part2"
                expect(builder.method(.GET).url("part1/part2/").build().requestUrl()) == "part1/part2/"
                expect(builder.method(.GET).url("/part1/part2").build().requestUrl()) == "/part1/part2"
                expect(builder.method(.GET).url("/part1/part2/").build().requestUrl()) == "/part1/part2/"
                expect(builder.method(.GET).url("(arg)").build().requestUrl()) == "(arg)"
                expect(builder.method(.GET).url("_arg").build().requestUrl()) == "_arg"
            }
            it("invalid path with no argument") {
                expect { builder.method(.GET).url("path/with/no/a rg/").build() }.to(throwAssertion())
            }
            it("invalid path with argument") {
                expect { builder.method(.GET).url("{{arg}").build() }.to(throwAssertion())
                expect { builder.method(.GET).url("a{rg").build() }.to(throwAssertion())
                expect { builder.method(.GET).url("{arg").build() }.to(throwAssertion())
                expect { builder.method(.GET).url("arg}").build() }.to(throwAssertion())
                expect { builder.method(.GET).url("ar}g").build() }.to(throwAssertion())
                expect { builder.method(.GET).url("{arg}}").build() }.to(throwAssertion())
                expect { builder.method(.GET).url("{arg)").build() }.to(throwAssertion())
                expect { builder.method(.GET).url("(arg}").build() }.to(throwAssertion())
                expect { builder.method(.GET).url("path/with/{a rg}/").build() }.to(throwAssertion())
            }
            it("with ignored arguments") {
                SwitrofitConfig.instance.setIgnoredPathArguments(keys: ["device", "ignored"])
                expect(builder.method(.GET).url("{device}").build().requestUrl()) == "{device}"
                expect(builder.method(.GET).url("part1/{device}/part2").build().requestUrl()) == "part1/{device}/part2"
                expect(builder.method(.GET).url("{device}/{arg}").build(with: "f(arg:)", 1).requestUrl()) ==
                    "{device}/1"
                expect(builder.method(.GET).url("{device}/{ignored}").build().requestUrl()) == "{device}/{ignored}"
            }
        }
        describe("test build path with arguments") {
            beforeEach {
                builder.method(.GET).url("arg1/{arg1}/arg2/{arg2}")
            }
            it("no arguments") {
                expect { builder.build() }.to(throwAssertion())
            }
            it("invalid signature") {
                expect { builder.build(with: "f[arg1:arg2:)") }.to(throwAssertion())
                expect { builder.build(with: "f(arg1:arg2:]") }.to(throwAssertion())
                expect { builder.build(with: "f(arg1:arg2)") }.to(throwAssertion())
            }
            it("invalid values") {
                expect { builder.build(with: "f(arg1:arg2:)") }.to(throwAssertion())
                expect { builder.build(with: "f(arg1:arg2:)", 1) }.to(throwAssertion())
                expect { builder.build(with: "f(arg1:arg2:)", 1, 2, 3) }.to(throwAssertion())
            }
            it("less arguments") {
                expect { builder.build(with: "f(arg1:)", 1) }.to(throwAssertion())
                expect { builder.build(with: "f(arg2:)", 2) }.to(throwAssertion())
            }
            it("nil for path") {
                expect { builder.build(with: "f(arg1:arg2:)", 1, nil) }.to(throwAssertion())
                expect { builder.build(with: "f(arg1:arg2:)", nil, 2) }.to(throwAssertion())
                expect { builder.build(with: "f(arg1:arg2:)", nil, nil) }.to(throwAssertion())
            }
            it("do not use _") {
                expect { builder.build(with: "f(_:arg1:arg2:)", 1, 2, 3) }.to(throwAssertion())
            }
            it("only primitive arguments") {
                struct AStruct: Codable {}

                class AClass: Codable {}

                expect { builder.build(with: "f(arg1:arg2:)", 1, AStruct()) }.to(throwAssertion())
                expect { builder.build(with: "f(arg1:arg2:)", 1, AClass()) }.to(throwAssertion())
                expect { builder.build(with: "f(arg1:arg2:)", 1, ["a": 2]) }.to(throwAssertion())
            }
            it("valid arguments") {
                var api = builder.build(with: "f(arg1:arg2:)", 1, "s1")
                expect(api.requestUrl()) == "arg1/1/arg2/s1"
            }
            it("multiple build") {
                var api = builder.build(with: "f(arg1:arg2:)", 3.1415926, true)
                expect(api.requestUrl()) == "arg1/3.1415926/arg2/true"
                // each builder can only build 1 time
                expect { builder.build() }.to(throwAssertion())
            }
        }
        describe("test build query with arguments") {
            beforeEach {
                builder.method(.GET).url("url")
            }
            it("1 argument") {
                let api = builder.build(with: "f(arg1:)", 1)
                expect(api.requestUrl()) == "url"
                let arguments = api.requestArgument() as? [String: String]
                expect(arguments?.count) == 1
                expect(arguments?["arg1"]) == "1"
            }
            it("more arguments") {
                let api = builder.build(with: "f(arg1:arg2:arg3:)", 1, "s2", false)
                expect(api.requestUrl()) == "url"
                let arguments = api.requestArgument() as? [String: String]
                expect(arguments?.count) == 3
                expect(arguments?["arg1"]) == "1"
                expect(arguments?["arg2"]) == "s2"
                expect(arguments?["arg3"]) == "false"
            }
            it("duplicated arguments") {
                expect { builder.build(with: "f(arg1:arg1:)", 1, 2) }.to(throwAssertion())
                let args: [String: Any?] = ["arg1": 1]
                expect { builder.build(with: "f(arg1:arguments:)", 0, args) }.to(throwAssertion())
            }
            it("dict arguments") {
                let args: [String: Any?] = ["key1": 1, "key2": "s2", "key3": nil]
                let api = builder.build(with: "f(arg1:arguments:)", 0, args)
                let arguments = api.requestArgument() as? [String: String]
                expect(arguments?.count) == 3
                expect(arguments?["arg1"]) == "0"
                expect(arguments?["key1"]) == "1"
                expect(arguments?["key2"]) == "s2"
            }
            it("arguments is not dict") {
                expect { builder.build(with: "f(arguments:)", 1) }.to(throwAssertion())
            }
        }
        describe("test build path and query with arguments") {
            beforeEach {
                builder.method(.GET).url("arg1/{arg1}")
            }
            it("no path argument") {
                expect { builder.build(with: "f(arg2:)", 2) }.to(throwAssertion())
            }
            it("valid arguments") {
                let api = builder.build(with: "f(arg1:arg2:)", 1, 2)
                expect(api.requestUrl()) == "arg1/1"
                let arguments = api.requestArgument() as? [String: String]
                expect(arguments?.count) == 1
                expect(arguments?["arg2"]) == "2"
            }
        }
        describe("test build with contentType") {
            it("default type") {
                let api = builder.method(.POST).url("url").build()
                expect(api.requestSerializerType()) == .HTTP
            }
            it("json type") {
                let api = builder.method(.POST).url("url").contentType(.JSON).build()
                expect(api.requestSerializerType()) == .JSON
            }
        }
    }
}
