//
//  EmptyResult.swift
//  YTKNetwork-SWItroFiT
//
//  Created by liqiang on 2020/8/14.
//

import Foundation

public protocol IResult {
    associatedtype Result
}

public struct EmptyResult: Codable {}
