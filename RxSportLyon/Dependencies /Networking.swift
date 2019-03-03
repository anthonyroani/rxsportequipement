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
    func getJSON(from: Endpoint, parameters: [Parameter]) -> Single<Any>?
}

private protocol NetworkingHelper {
    func buildURL(from: Endpoint, with parameters: [Parameter]) -> URL?
}

struct HTTPNetworking: Networking, NetworkingHelper {
    
    fileprivate func buildURL(from: Endpoint, with parameters: [Parameter]) -> URL? {
        let url = parameters.reduce(from.path, { url, parameter in
            return url + parameter.name.identifier + parameter.value
        })
        return URL(string: url)
    }
    
    func getJSON(from: Endpoint, parameters: [Parameter]) -> Single<Any>? {
        guard let url = buildURL(from: from, with: parameters) else { return nil }
        return URLSession.shared.rx
            .json(request: URLRequest(url: url))
            .retry(3)
            .asSingle()
    }
    
}
