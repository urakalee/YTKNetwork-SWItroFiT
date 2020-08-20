//
// Created by liqiang on 2020/8/20.
//

import Foundation

public class SwitrofitConfig {
    public static let instance = SwitrofitConfig()
    private(set) var ignoredPathArgument = [String]()

    private init() {}

    public func setIgnoredPathArguments(keys: [String]) {
        ignoredPathArgument = keys
    }
}
