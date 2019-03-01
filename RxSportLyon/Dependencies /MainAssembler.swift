//
//  MainAssembler.swift
//  RxSportLyon
//
//  Created by Anthony Roani on 25/02/2019.
//  Copyright © 2019 Anthony Roani. All rights reserved.
//

import Foundation
import Swinject
import SwinjectStoryboard

class MainAssembler {
    var resolver: Resolver {
        return assembler.resolver
    }
    private let assembler = Assembler(container: SwinjectStoryboard.defaultContainer)

    init() {
        assembler.apply(assembly: ParserAssembly())
        assembler.apply(assembly: EquipementFetcherAssembly())
        assembler.apply(assembly: MapConfiguratorAssembly())
        assembler.apply(assembly: MapViewModelAssembly())
        assembler.apply(assembly: MapViewControllerAssembly())
    }
}
