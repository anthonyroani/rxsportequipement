//
//  RxSportLyonTests.swift
//  RxSportLyonTests
//
//  Created by Anthony Roani on 20/02/2019.
//  Copyright © 2019 Anthony Roani. All rights reserved.
//

import XCTest
import Swinject
@testable import RxSportLyon

class BasicTests: XCTestCase {

    private let container = Container()

    // MARK: - Boilerplate methods

    override func setUp() {

        container.register([Equipement].self) { _ in
            return [
                Equipement(name: "Salle multisports", coordinate: [45.75696, 4.82158]),
                Equipement(name: "Terrain de basket-ball", coordinate: [45.76757, 4.83038]),
                Equipement(name: "Terrain de volley-ball", coordinate: [45.76781, 4.8303])
            ]
        }

        container.register(EquipementResponse.self) { resolver in
            let equipements = resolver.resolve([Equipement].self)!
            return EquipementResponse(data: equipements)
        }
    }

    // MARK: - Tests

    func testEquipementsCount() {
        let response = container.resolve(EquipementResponse.self)!
        XCTAssertEqual(response.data.count, 3)
    }

    override func tearDown() {
        container.removeAll()
    }

}
