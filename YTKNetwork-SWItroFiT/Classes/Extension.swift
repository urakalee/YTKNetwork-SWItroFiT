//
//  YTKNetworkExtension.swift
//  YTKNetwork-SWItroFiT
//
//  Created by liqiang on 2020/8/14.
//

import Foundation
import YTKNetwork

public extension YTKRequest {
    func responseDecodable<Model: Decodable>() -> Model? {
        return responseDecodable(with: self.responseData)
    }

    func responseDecodable<Model: Decodable>(with data: Data?) -> Model? {
        guard let data = data else { return nil }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .millisecondsSince1970
        do {
            return try decoder.decode(Model.self, from: data)
        } catch {
            debugPrint("\(self), \(Model.self), Decode Error: \(error)")
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
