//
//  MapViewModel.swift
//  RxSportLyon
//
//  Created by Anthony Roani on 20/02/2019.
//  Copyright © 2019 Anthony Roani. All rights reserved.
//

import Foundation
import RxSwift
import Swinject

protocol MapViewModeling {
    func reloadMap()
}

class MapViewModel : BaseViewModel {
    
    let model = MapModel()
    let fetcher : EquipementFetcher
    let sliderValue : Variable<Float> = Variable(0)
    let loadingStateValue : Variable<Bool> = Variable(false)
    
    public required init() {
        fatalError("init() has not been implemented")
    }
    
    init(fetcher : EquipementFetcher) {
        self.fetcher = fetcher
    }
}

extension MapViewModel : MapViewModeling {
    func reloadMap(){
        loadingStateValue.value = true
        fetcher.fetch { response in
            guard let response = response else { return }
        }
    }
}

// MARK : Swinject

class MapViewModelAssembly : Assembly {
    func assemble(container: Container) {
        container.register(MapViewModel.self, factory: { r in
            let fetcher = r.resolve(EquipementFetcher.self)
            return MapViewModel(fetcher: fetcher!) // Non-optional : crash if unregistered yet.
        }).inObjectScope(.weak) // weak : when not being used, kill networking.
    }
}
