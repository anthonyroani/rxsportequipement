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
    func fetch() -> Single<EquipementResponse>
}

struct EquipementFetcher {

    let networking: Networking
    let parser: Parser
    let disposeBag: DisposeBag

    init(networking: Networking, parser: Parser, disposeBag: DisposeBag) {
        self.networking = networking
        self.parser = parser
        self.disposeBag = disposeBag
    }

}

extension EquipementFetcher: Fetcher {

    func fetch() -> Single<EquipementResponse> {

        return Single.create { single in

            // Request JSON.
            guard let jsonSingle = self.networking.getJSON(from: OpenDataSoft.sportEquipement) else {
                single(.error(NetworkingError.invalidURL))
                return Disposables.create()
            }

            // Decode results and handle errors.
            jsonSingle.subscribe(
                onSuccess: { json in
                    do {
                        let data = try JSONSerialization.data(withJSONObject: json)
                        if let decoded = try self.parser.decodeJSON(type: EquipementResponse.self, from: data) {
                            print(decoded.data)
                            single(.success(decoded))
                        }
                    } catch let error {
                        single(.error(error))
                    }
                },
                onError: { error in
                    single(.error(error))
                }
            ).disposed(by: self.disposeBag)

            return Disposables.create()
        }
    }
}

// MARK: Assembly

class EquipementFetcherAssembly: Assembly {
    func assemble(container: Container) {
        container.register(EquipementFetcher.self, factory: { resolver in
            let networking = HTTPNetworking()
            let parser = resolver.resolve(Parser.self)
            let disposeBag = DisposeBag()
            return EquipementFetcher(networking: networking, parser: parser!, disposeBag: disposeBag)
        }).inObjectScope(.weak)
    }
}
