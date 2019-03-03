//
//  MapViewModel.swift
//  RxSportLyon
//
//  Created by Anthony Roani on 20/02/2019.
//  Copyright © 2019 Anthony Roani. All rights reserved.
//

import Foundation
import MapKit
import RxSwift
import Swinject

enum MapError: Error {
    case invalidCoordinates
}

protocol MapViewUI {
    var sliderFormattedValue: Variable<String?> { get }
    var sliderValue: Variable<Float> { get }
    var isLoadingValue: Variable<Bool> { get }
    var errorMessageValue: Variable<String?> { get }
    var modelValue: Variable<[MKPointAnnotation]> { get }
    var mapCentered: Bool { get }
}

private protocol MapViewModeling {
    func annotationPointsSingle() -> Single<[MKPointAnnotation]>
    func searchEquipements()
    func setup()
    func sliderValueFormatted(from value: Float) -> String?
}

// MARK: MapViewModel and MapViewUI

class MapViewModel: MapViewUI {
    
    var mapCentered: Bool = false
    var sliderValue: Variable<Float> = Variable(0.0)
    var sliderFormattedValue: Variable<String?> = Variable(nil)
    var errorMessageValue: Variable<String?> = Variable(nil)
    var isLoadingValue: Variable<Bool> = Variable(false)
    var modelValue: Variable<[MKPointAnnotation]> = Variable([])

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

    /// Fetch equipements from server and convert them to an `Observable`
    ///
    /// - Returns: An `Single` array of `MKPointAnnotation`
    func annotationPointsSingle() -> Single<[MKPointAnnotation]> {
        
        guard let latitude = mapConfigurator.locationValue.value?.latitude,
              let longitude = mapConfigurator.locationValue.value?.longitude else {
                return Single.create { single in
                        single(.error(MapError.invalidCoordinates))
                        return Disposables.create()
                }
        }
        
        let searchRadius = Int(ceil(self.sliderValue.value * 1000))
        let geofilterParameterValue = "\(latitude)%2C+\(longitude)%2C+\(searchRadius)"
        let geofilterParameter = Parameter(name: .geofilterDistance, value: geofilterParameterValue)
        
        return fetcher.fetch(parameters: [geofilterParameter]).map ({ response in
            return response.data.map({ (equipement) -> MKPointAnnotation in
                let mapPoint = MKPointAnnotation()
                mapPoint.title = equipement.fields.name
                mapPoint.coordinate = CLLocationCoordinate2D(
                    latitude: equipement.fields.coordinates[0],
                    longitude: equipement.fields.coordinates[1]
                )
                return mapPoint
            })
        })
    }
    
    open func searchEquipements() {
        isLoadingValue.value = true
        annotationPointsSingle().subscribe(
            onSuccess: { [weak self] annotationPoints in
                self?.isLoadingValue.value = false
                self?.modelValue.value = annotationPoints
            },
            onError: { [weak self] error in
                self?.errorMessageValue.value = error.localizedDescription
                self?.isLoadingValue.value = false
                self?.modelValue.value = []
            }
        ).disposed(by: disposeBag)
    }

    /// Set observers and start getting position of the user
    fileprivate func setup() {
        
        mapConfigurator.getCurrentLocation()

        mapConfigurator.locationValue
        .asObservable()
        .throttle(5, scheduler: MainScheduler.instance)
        .subscribe(
            onNext: { [weak self] _ in
                self?.searchEquipements()
            })
        .disposed(by: disposeBag)
        
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
