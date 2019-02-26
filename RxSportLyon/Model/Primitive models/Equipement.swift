//
//  Equipement.swift
//  RxSportLyon
//
//  Created by Anthony Roani on 20/02/2019.
//  Copyright © 2019 Anthony Roani. All rights reserved.
//

import Foundation

class Equipement : Codable {
    
    fileprivate let name : String
    fileprivate let coordinate : [Double]!
    
    init(name : String, coordinate : [Double]) {
        self.name = name
        self.coordinate = coordinate
    }
    
    enum CodingKeys: String, CodingKey {
        case name = "equipementtypelib"
        case coordinate = "coordonnees"
    }
    
}
