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

protocol MapViewUI {
    var sliderFormattedValue: Variable<String?> { get }
    var sliderValue: Variable<Float> { get }
    var isLoadingValue: Variable<Bool> { get }
    var errorMessageValue: Variable<String?> { get }
    var modelValue: Variable<[Equipement]?> { get }
}

protocol MapViewModeling {
    func reloadMap()
    func setup()
    func sliderValueFormatted(from value: Float) -> String?
}

class MapViewModel: MapViewUI {

    var sliderValue: Variable<Float> = Variable(0.0)
    var sliderFormattedValue: Variable<String?> = Variable(nil)
    var errorMessageValue: Variable<String?> = Variable(nil)
    var isLoadingValue: Variable<Bool> = Variable(false)
    var modelValue: Variable<[Equipement]?> = Variable(nil)

    let disposeBag: DisposeBag
    let fetcher: EquipementFetcher
    let mapConfigurator: MapConfigurator
    let numberFormatter: NumberFormatter

    init(fetcher: EquipementFetcher,
         mapConfigurator: MapConfigurator,
         numberFormatter: NumberFormatter,
         disposeBag: DisposeBag
    ) {
        self.disposeBag = disposeBag
        self.fetcher = fetcher
        self.mapConfigurator = mapConfigurator
        self.numberFormatter = numberFormatter
        setup()
    }

}

extension MapViewModel: MapViewModeling {

    internal func setup() {
        sliderValue.asObservable().subscribe(onNext: { [weak self] value in
            self?.sliderFormattedValue.value = self?.sliderValueFormatted(from: value)
        }).disposed(by: disposeBag)
    }

    open func reloadMap() {
        isLoadingValue.value = true
        fetcher.fetch().subscribe(
            onNext: { [weak self] response in
                self?.modelValue.value = response.data
            },
            onError: { [weak self] error in
                self?.isLoadingValue.value = false
                self?.errorMessageValue.value = error.localizedDescription
            },
            onCompleted: { [weak self] in
                self?.isLoadingValue.value = false
            }
        ).disposed(by: disposeBag)
    }

    internal func sliderValueFormatted(from value: Float) -> String? {
        guard let formattedValue = numberFormatter.string(from: NSNumber(value: value)) else {
            return nil
        }
        return formattedValue
    }

}

// MARK: Assembly

class MapViewModelAssembly: Assembly {
    func assemble(container: Container) {
        container.register(MapViewModel.self, factory: { resolver in
            let fetcher = resolver.resolve(EquipementFetcher.self)!
            let mapConfigurator = resolver.resolve(MapConfigurator.self)!
            let disposeBag = DisposeBag()
            let numberFormatter = NumberFormatter()
            numberFormatter.maximumFractionDigits = 1
            return MapViewModel(
                fetcher: fetcher,
                mapConfigurator: mapConfigurator,
                numberFormatter: numberFormatter,
                disposeBag: disposeBag
            )

        }).inObjectScope(.weak)
    }
}
