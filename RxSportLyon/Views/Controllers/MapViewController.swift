//
//  MapViewController.swift
//  RxSportLyon
//
//  Created by Anthony Roani on 20/02/2019.
//  Copyright © 2019 Anthony Roani. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import MapKit
import Swinject
import SwinjectStoryboard
import RxMKMapView

class MapViewController: BaseViewController<MapViewModel> {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var reloadButton: RoundedButton!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var kilometersLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: Binding

    override func configureBindings(_ viewModel: MapViewModel) {
        
        // Fetch data according selected distance when taping `reloadButton`
        reloadButton.rx.tap
            .subscribe({ [weak self] _ in
                self?.viewModel.reloadMap()
            })
            .disposed(by: disposeBag)

        // Update `UISlider` value in `MapViewModel`
        slider.rx.value
            .bind(to: viewModel.sliderValue)
            .disposed(by: disposeBag)
        
    }
    
    // MARK: Callbacks

    override func configureCallbacks(_ viewModel: MapViewModel) {
        
        viewModel.modelValue
            .asDriver(onErrorJustReturn: [])
            .drive(mapView.rx.annotations)
            .disposed(by: disposeBag)
        
//        .subscribe(
//            onSuccess: { annotations in
//                let m = mapView.rx.annotation
//            },
//            onError: { error in
//                viewModel.errorMessageValue.value = error.localizedDescription
//            }
//        ).disposed(by: disposeBag)
        
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

        // Center the `MKMapView` to the `locationValue` of the viewModel that is the current user location
        viewModel.mapConfigurator.locationValue
            .asObservable()
            .subscribe(onNext: { location in
                guard let location = location else { return }
                let coordinateRegion = MKCoordinateRegion(
                    center: location,
                    latitudinalMeters: viewModel.mapConfigurator.regionRadius,
                    longitudinalMeters: viewModel.mapConfigurator.regionRadius
                )
                self.mapView.setRegion(coordinateRegion, animated: true)
            })
            .disposed(by: disposeBag)

        // Handle `UISlider` title when user change its value
        viewModel.sliderFormattedValue
            .asObservable()
            .subscribe(onNext: { formattedValue in
                self.kilometersLabel.text = formattedValue
            })
            .disposed(by: disposeBag)
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
