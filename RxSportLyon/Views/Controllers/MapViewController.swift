//
//  MapViewController.swift
//  RxSportLyon
//
//  Created by Anthony Roani on 20/02/2019.
//  Copyright © 2019 Anthony Roani. All rights reserved.
//

import UIKit
import MapKit
import RxCocoa
import RxSwift
import RxMapKit
import Swinject
import SwinjectStoryboard

class MapViewController: BaseViewController<MapViewModel> {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var kilometersLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.mapConfigurator.configure(mapView: mapView)
    }
    
    // MARK: Binding
    
    override func configureBindings(_ viewModel: MapViewModel) {
        // Update `UISlider` value in `MapViewModel`
        slider.rx.value
            .bind(to: viewModel.sliderValue)
            .disposed(by: disposeBag)
    }
    
    // MARK: Callbacks
    
    override func configureCallbacks(_ viewModel: MapViewModel) {
        
        // Handle received equipements
        viewModel.modelValue
        .asObservable()
        .observeOn(MainScheduler.instance)
        .subscribe(
            onNext: { [weak self] annotations in
                if let old = self?.mapView.annotations {
                    self?.mapView.removeAnnotations(old)
                    self?.mapView.addAnnotations(annotations)
                }
            }, onError: { [weak self] error in
                self?.showAlert(title: "Error", message: error.localizedDescription)
            }
        )
        .disposed(by: disposeBag)
        
        // Handle `UIActivityIndicator` during fetching
        viewModel.isLoadingValue
            .asObservable()
            .bind(to: activityIndicator.rx.isAnimating)
            .disposed(by: disposeBag)
        
        // Handle a eventual error message after fetching by presenting an `UIAlertController`
        viewModel.errorMessageValue
            .asObservable()
            .bind { [weak self] errorDescription in
                guard let description = errorDescription else { return }
                self?.showAlert(title: "Error", message: description)
            }
            .disposed(by: disposeBag)
        
        // Handle `UISlider` title when user change its value
        viewModel.sliderFormattedValue
            .asObservable()
            .subscribe(onNext: { formattedValue in
                self.kilometersLabel.text = formattedValue
            })
            .disposed(by: disposeBag)
        
        viewModel.mapConfigurator.locationValue
            .asObservable()
            .subscribe(onNext: { [weak self] location in
                if let mapCentered = self?.viewModel.mapCentered {
                    if !mapCentered {
                        if let location = location {
                            let region = MKCoordinateRegion(
                                center: location,
                                latitudinalMeters: viewModel.mapConfigurator.regionRadius,
                                longitudinalMeters: viewModel.mapConfigurator.regionRadius
                            )
                            self?.mapView.setRegion(region, animated: true)
                            self?.viewModel.mapCentered = true
                        }
                    }
                }
            }).disposed(by: disposeBag)
        
    }
    
}

// MARK: Assembly

class MapViewControllerAssembly: Assembly {
    func assemble(container: Container) {
        container.storyboardInitCompleted(MapViewController.self, initCompleted: { (resolver, controller) in
            controller.viewModel = resolver.resolve(MapViewModel.self)!
            controller.disposeBag = DisposeBag()
        })
    }
}
