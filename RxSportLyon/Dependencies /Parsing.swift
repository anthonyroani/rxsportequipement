//
//  Parsing.swift
//  RxSportLyon
//
//  Created by Anthony Roani on 26/02/2019.
//  Copyright © 2019 Anthony Roani. All rights reserved.
//

import Foundation
import Swinject

// Parser - single-responsibility : Decode JSON Data to a type object

protocol Parsing {
    func decodeJSON<T: Decodable>(type: T.Type, from: Data?) throws -> (T?)
}

struct Parser {
    let decoder: JSONDecoder
    init(decoder: JSONDecoder) {
        self.decoder = decoder
    }
}

extension Parser: Parsing {
    func decodeJSON<T: Decodable>(type: T.Type, from: Data?) throws -> (T?) {
        guard let data = from else {
            throw FetcherError.dataEmpty
        }
        do {
            return try decoder.decode(type.self, from: data)
        } catch let error {
            throw error
        }
    }
}

class ParserAssembly: Assembly {
    func assemble(container: Container) {
        container.register(Parser.self, factory: { _ in
            let jsonDecoder = JSONDecoder()
            return Parser(decoder: jsonDecoder)
        }).inObjectScope(.weak)
    }
}
