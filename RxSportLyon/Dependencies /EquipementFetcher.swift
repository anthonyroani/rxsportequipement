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

    func fetch() -> Observable<EquipementResponse> {

        return Observable.create { observer in

            guard let jsonObservable = self.networking.getJSON(from: OpenDataSoft.sportEquipement) else {
                observer.onError(NetworkingError.invalidURL)
                return Disposables.create()
            }

            jsonObservable
                .subscribe(
                    onNext: { json in
                        do {
                            let data = try JSONSerialization.data(withJSONObject: json)
                            if let decoded = try self.parser.decodeJSON(type: EquipementResponse.self, from: data) {
                                observer.onNext(decoded)
                                observer.onCompleted()
                            }
                        } catch let error {
                            observer.onError(error)
                        }
                    }, onError: { error in
                        observer.onError(error)
                    })
                .disposed(by: self.disposeBag)

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
