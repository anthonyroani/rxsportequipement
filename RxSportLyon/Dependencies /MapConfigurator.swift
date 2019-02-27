//
//  MapConfigurator.swift
//  RxSportLyon
//
//  Created by Anthony Roani on 27/02/2019.
//  Copyright © 2019 Anthony Roani. All rights reserved.
//

import UIKit
import Swinject
import MapKit
import RxSwift

protocol MapConfiguring {
    func getCurrentLocation()
}

class MapConfigurator : NSObject {
    
    let locationManager : CLLocationManager
    let disposeBag : DisposeBag
    
    let regionRadius: CLLocationDistance = 1000
    let locationValue : Variable<CLLocationCoordinate2D?> = Variable(nil)

    init(locationManager : CLLocationManager, disposeBag : DisposeBag) {
        self.locationManager = locationManager
        self.disposeBag = disposeBag
        super.init()
    }
    
}

// MARK : MapConfiguring protocol

extension MapConfigurator : MapConfiguring {
    
    func getCurrentLocation(){
        self.locationManager.requestAlwaysAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
}

// MARK : CLLocationManagerDelegate

extension MapConfigurator : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location : CLLocationCoordinate2D = manager.location?.coordinate else { return }
        self.locationValue.value = location
    }
}

// MARK : Assembly

class MapConfiguratorAssembly : Assembly {
    func assemble(container: Container) {
        container.register(MapConfigurator.self, factory: { r in
            let locationManager = CLLocationManager()
            let disposeBag = DisposeBag()
            return MapConfigurator(locationManager: locationManager, disposeBag: disposeBag)
        }).inObjectScope(.weak)
    }
}