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
    let mapConfigurator : MapConfigurator

    let sliderValue : Variable<Float> = Variable(0)
    let isLoadingValue : Variable<Bool> = Variable(false)
    let errorMessageValue : Variable<String?> = Variable(nil)
    let equipementsValue : Variable<[Equipement]> = Variable([Equipement]())
    
    public required init() {
        fatalError("init() has not been implemented")
    }
    
    init(fetcher : EquipementFetcher, mapConfigurator : MapConfigurator) {
        self.fetcher = fetcher
        self.mapConfigurator = mapConfigurator
    }
}

extension MapViewModel : MapViewModeling {
    
    func reloadMap(){
        isLoadingValue.value = true
        _ = fetcher.fetch().subscribe(onNext: { [weak self] response in
            self?.equipementsValue.value = response.data
        }, onError: { [weak self] error in
            self?.isLoadingValue.value = false
            self?.errorMessageValue.value = error.localizedDescription
        }, onCompleted: { [weak self] in
            self?.isLoadingValue.value = false
            print("completed")
        }, onDisposed: {
            print("disposed")
        })
    }
    
    
}

// MARK : Assembly

class MapViewModelAssembly : Assembly {
    func assemble(container: Container) {
        container.register(MapViewModel.self, factory: { r in
            let fetcher = r.resolve(EquipementFetcher.self)!
            let mapConfigurator = r.resolve(MapConfigurator.self)!
            return MapViewModel(fetcher: fetcher, mapConfigurator : mapConfigurator)
        }).inObjectScope(.weak) 
    }
}
