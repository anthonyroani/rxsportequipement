//
//  EquipementFetcher.swift
//  RxSportLyon
//
//  Created by Anthony Roani on 25/02/2019.
//  Copyright © 2019 Anthony Roani. All rights reserved.
//

import Foundation
import Swinject

protocol Fetcher {
    typealias ResponseCompletion = (EquipementResponse?) -> Void
    func fetch(response: @escaping ResponseCompletion)
}

struct EquipementFetcher  {
    let networking: Networking
    init(networking: Networking) {
        self.networking = networking
    }
}

extension EquipementFetcher : Fetcher {
    
    func fetch(response: @escaping ResponseCompletion) {
        networking.request(from: OpenDataSoft.sportEquipement) { data, error in
            if let error = error {
                print(error.localizedDescription)
                response(nil)
            }
            let decoded = self.decodeJSON(type: EquipementResponse.self, from: data)
            if let decoded = decoded {
                print("Equipements returned : \(decoded.data)")
            }
            response(decoded)
        }
    }
    
    private func decodeJSON<T: Decodable>(type: T.Type, from: Data?) -> T? {
        let decoder = JSONDecoder()
        guard let data = from, let response = try? decoder.decode(type.self, from: data) else { return nil }
        return response
    }
    
}

class EquipementFetcherAssembly : Assembly {
    func assemble(container: Container) {
        container.register(EquipementFetcher.self, factory: { r in
            let networking = HTTPNetworking()
            return EquipementFetcher(networking: networking)
        }).inObjectScope(.weak) // weak : when not being used, kill networking.
    }
}
