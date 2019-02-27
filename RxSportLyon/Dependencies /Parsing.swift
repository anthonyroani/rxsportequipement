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
    func decodeJSON<T: Decodable>(type: T.Type, from: Data?) -> (T?, Error?)
}

struct Parser {
    let decoder : JSONDecoder
    init(decoder : JSONDecoder) {
        self.decoder = decoder
    }
}

extension Parser : Parsing {
    func decodeJSON<T: Decodable>(type: T.Type, from: Data?) -> (T?, Error?) {
        guard let data = from else {
            return (nil, FetcherError.dataEmpty)
        }
        do {
            let response = try decoder.decode(type.self, from: data)
            return (response, nil)
        } catch let error {
            return (nil, error)
        }
    }
}

class ParserAssembly : Assembly {
    func assemble(container: Container) {
        container.register(Parser.self, factory: { r in
            let jsonDecoder = JSONDecoder()
            return Parser(decoder: jsonDecoder)
        }).inObjectScope(.weak) 
    }
}
