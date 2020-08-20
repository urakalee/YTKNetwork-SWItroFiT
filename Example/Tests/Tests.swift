// https://github.com/Quick/Quick

import Quick
import Nimble
import Mantle
@testable import YTKNetwork_SWItroFiT

@objcMembers
public class TestClass: MTLModel {
    var a: Int = 0 // NOTE: optional can not be used when @objc
    var b: Int64 = 0
    var c: Bool = false
    var d: String = ""
    var e: String = ""
}

extension TestClass: MTLJSONSerializing {
    public static func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any]! {
        return nil
    }
}

class PlaygroundSpec: QuickSpec {
    override func spec() {
        it("split") {
            var origin = "a:b:".components(separatedBy: ":")
            expect(origin.count) == 3
            expect(origin[2]) == ""
            origin = "".components(separatedBy: ":")
            expect(origin.count) == 1
        }
        it("regular expression") {
            let result = matches(string: "path/to/argument/{_argument1}", regex: "\\{([0-9a-zA-Z_]+)\\}")
            expect(result.count) == 1
            expect(result[0]) == "_argument1"
        }
        it("json to ns-object") {
            let jsonString = """
            {
               "a": 1,
               "b": 1024,
               "c": true,
               "d": "string"
            }
            """
            let result: TestClass? = jsonString.result()
            expect(result?.a) == 1
            expect(result?.b) == 1024
            expect(result?.c) == true
            expect(result?.d) == "string"
            expect(result?.e) == ""
        }
    }
}
