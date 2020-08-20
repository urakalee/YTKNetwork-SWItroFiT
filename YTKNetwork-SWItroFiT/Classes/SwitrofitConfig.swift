//
// Created by liqiang on 2020/8/20.
//

import Foundation

@objc
public class SwitrofitConfig: NSObject {
    @objc public static let instance = SwitrofitConfig()
    private(set) var ignoredPathArgument = [String]()

    override private init() {}

    @objc public func setIgnoredPathArguments(keys: [String]) {
        ignoredPathArgument = keys
    }
}
