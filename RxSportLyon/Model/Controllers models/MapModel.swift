//
//  MapModel.swift
//  RxSportLyon
//
//  Created by Anthony Roani on 20/02/2019.
//  Copyright © 2019 Anthony Roani. All rights reserved.
//

import Foundation

class MapModel {
    
    var equipements = [Equipement]()
    
    convenience init(equipements : [Equipement]) {
        self.init()
        self.equipements = equipements
    }
    
}
