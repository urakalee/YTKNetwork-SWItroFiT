//
//  YTKNetworkExtension.swift
//  YTKNetwork-SWItroFiT
//
//  Created by liqiang on 2020/8/14.
//

import Foundation
import YTKNetwork

public extension YTKNetworkApi {
    func asRequest() -> YTKRequest {
        return self as YTKRequest
    }
}

public extension YTKNetworkApi where Result: Codable {
    func result() -> Result? {
        guard let data = self.responseData else { return nil }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .millisecondsSince1970
        do {
            return try decoder.decode(Result.self, from: data)
        } catch {
            debugPrint("\(self), \(Result.self), Decode Error: \(error)")
            assert(false)
            return nil
        }
    }
}

protocol WithScope {}

extension WithScope {
    @inline(__always) func `let`<Type>(block: (Self) -> Type) -> Type {
        return block(self)
    }

    @inline(__always) func also(block: (Self) -> Void) -> Self {
        block(self)
        return self
    }
}

extension NSObject: WithScope {}
