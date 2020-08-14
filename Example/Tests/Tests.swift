// https://github.com/Quick/Quick

import Quick
import Nimble
@testable import YTKNetwork_SWItroFiT

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
    }
}
