//
//  EquipementReponse.swift
//  RxSportLyon
//
//  Created by Anthony Roani on 25/02/2019.
//  Copyright © 2019 Anthony Roani. All rights reserved.
//

import Foundation

struct EquipementResponse: Codable {

    let data: [Equipement]

    enum CodingKeys: String, CodingKey {
        case data = "records"
    }
}
