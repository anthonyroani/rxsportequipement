//
//  EquipementFetcher.swift
//  RxSportLyon
//
//  Created by Anthony Roani on 25/02/2019.
//  Copyright © 2019 Anthony Roani. All rights reserved.
//

import Foundation
import Swinject
import RxSwift

// EquipementFetcher - single-responsibility : request and parse data from OpenDataSoft API.

enum FetcherError: Error {
    case dataEmpty
    case failDecoding
    case networkError(Error)
}

protocol Fetcher {
    func fetch() -> Observable<EquipementResponse>
}

struct EquipementFetcher  {
    let networking: Networking
    let parser: Parser
    init(networking: Networking, parser : Parser) {
        self.networking = networking
        self.parser = parser
    }
}

extension EquipementFetcher : Fetcher {
    func fetch() -> Observable<EquipementResponse> {
        return Observable.create { observer in
            self.networking.request(from: OpenDataSoft.sportEquipement) { data, error in
                if let error = error {
                    observer.onError(FetcherError.networkError(error))
                } else {
                    let decodeResult = self.parser.decodeJSON(type: EquipementResponse.self, from: data)
                    if let error = decodeResult.1 {
                        observer.onError(error)
                    }
                    if let response = decodeResult.0 {
                        observer.onNext(response)
                        observer.onCompleted()
                    }
                }
            }
            return Disposables.create()
        }
    }
}

// MARK : Assembly

class EquipementFetcherAssembly : Assembly {
    func assemble(container: Container) {
        container.register(EquipementFetcher.self, factory: { r in
            let networking = HTTPNetworking()
            let parser = r.resolve(Parser.self)
            return EquipementFetcher(networking: networking, parser : parser!)
        }).inObjectScope(.weak)
    }
}
