//
//  RegularExpressionUtils.swift
//  YTKNetwork-SWItroFiT
//
//  Created by liqiang on 2020/8/14.
//

import Foundation

/// get re-matched substrings
///
/// - Parameters:
///   - string: original string
///   - regex: re
/// - Returns: matched substrings
func matches(string: String, regex: String) -> [String] {
    do {
        let regex: NSRegularExpression = try NSRegularExpression(pattern: regex)
        let matches = regex.matches(in: string, range: NSMakeRange(0, string.count))

        var result = [String]()
        for match in matches {
            if match.numberOfRanges == 1 {
                // no group
                result.append((string as NSString).substring(with: match.range))
            } else if match.numberOfRanges == 2 {
                // with only 1 group
                result.append((string as NSString).substring(with: match.range(at: 1)))
            } // TODO: more than 1 groups
        }
        return result
    } catch {
        return []
    }
}
