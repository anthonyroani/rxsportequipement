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

private protocol MapViewModeling {
    func reloadMap()
    func setup()
    func sliderValueFormatted(from value: Float) -> String?
}

// MARK: MapViewModel and MapViewUI

class MapViewModel: MapViewUI {

    var sliderValue: Variable<Float> = Variable(0.0)
    var sliderFormattedValue: Variable<String?> = Variable(nil)
    var errorMessageValue: Variable<String?> = Variable(nil)
    var isLoadingValue: Variable<Bool> = Variable(false)
    var modelValue: Variable<[Equipement]?> = Variable(nil)

    private let disposeBag: DisposeBag
    private let fetcher: EquipementFetcher
    private let numberFormatter: NumberFormatter
    public let mapConfigurator: MapConfigurator

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

// MARK: MapViewModeling

extension MapViewModel: MapViewModeling {

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

    /// When slider value change, set formatted value into `sliderFormattedValue` and notify controller.
    fileprivate func setup() {
        sliderValue.asObservable().subscribe(onNext: { [weak self] value in
            self?.sliderFormattedValue.value = self?.sliderValueFormatted(from: value)
        }).disposed(by: disposeBag)
    }
    
    /// Converts a `Float` value into a readable `String` for the `UISlider` of the controller.
    ///
    /// - Parameter value: `Float` representation of the slider value
    /// - Returns: `String` representation of the slider title `UILabel`
    fileprivate func sliderValueFormatted(from value: Float) -> String? {
        guard let formattedValue = numberFormatter.string(from: NSNumber(value: value)) else {
            return nil
        }
        return "\(formattedValue) \(NSLocalizedString("aroundKilometers", comment: "Distance description"))"
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
