//
//  Endpoint.swift
//  RxSportLyon
//
//  Created by Anthony Roani on 25/02/2019.
//  Copyright © 2019 Anthony Roani. All rights reserved.
//

import Foundation

// MARK: OpenDataSoft

protocol Endpoint {
    var path: String { get }
}

enum OpenDataSoft {
    case sportEquipement
}

extension OpenDataSoft: Endpoint {
    var path: String {
        switch self {
        case .sportEquipement: return "https://public.opendatasoft.com/api/records/1.0/search/?dataset=res_equipements_2017&sort=equdatecreation&facet=comlib&facet=equipementtypelib&facet=gestiontypeproprietaireprinclib&facet=naturesollib&facet=naturelibelle&facet=equacceshandimaire&facet=caracteristiques&refine.comlib=Lyon"
        }
    }
}

// MARK: OpenDataSoftParameters

private protocol ParameterIdentifier {
    var identifier: String { get }
}

enum OpenDataSoftParameterIdentifier: ParameterIdentifier {
    case geofilterDistance
    var identifier: String {
        switch self {
        case .geofilterDistance:
            return "&geofilter.distance="
        }
    }
}

protocol Parameterable {
    var name: OpenDataSoftParameterIdentifier { get }
    var value: String { get }
}

struct Parameter: Parameterable {
    var name: OpenDataSoftParameterIdentifier
    var value: String
}
