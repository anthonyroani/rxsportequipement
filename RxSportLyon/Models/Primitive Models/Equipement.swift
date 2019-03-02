//
//  Equipement.swift
//  RxSportLyon
//
//  Created by Anthony Roani on 20/02/2019.
//  Copyright © 2019 Anthony Roani. All rights reserved.
//

import Foundation

struct Equipement: Codable {
    let fields: EquipementFields
}

struct EquipementFields: Codable {

    let name: String
    let coordinates: [Double]

    enum CodingKeys: String, CodingKey {
        case name = "equipementtypelib"
        case coordinates = "coordonnees"
    }
}
