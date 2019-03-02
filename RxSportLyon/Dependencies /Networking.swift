//
//  Networking.swift
//  RxSportLyon
//
//  Created by Anthony Roani on 25/02/2019.
//  Copyright © 2019 Anthony Roani. All rights reserved.
//

import Foundation
import RxSwift

enum NetworkingError: Error {
    case invalidURL
}

protocol Networking {
    func getJSON(from: Endpoint) -> Single<Any>?
}

struct HTTPNetworking: Networking {
    func getJSON(from: Endpoint) -> Single<Any>? {
        guard let url = URL(string: from.path) else { return nil }
        return URLSession.shared.rx.json(request: URLRequest(url: url))
        .retry(3)
        .asSingle()
    }
}
