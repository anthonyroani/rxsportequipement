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

class MapViewController: BaseViewController<MapViewModel> {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var reloadButton: RoundedButton!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var kilometersLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.mapConfigurator.getCurrentLocation()
    }

    // MARK: Bindings & Callbacks

    override func configureBindings(_ viewModel: MapViewModel) {
        reloadButton.rx.tap
            .subscribe({ [weak self] _ in
                self?.viewModel.reloadMap()
            })
            .disposed(by: disposeBag)

        slider.rx.value
            .bind(to: viewModel.sliderValue)
            .disposed(by: disposeBag)
    }

    override func configureCallbacks(_ viewModel: MapViewModel) {

        viewModel.isLoadingValue
            .asObservable()
            .bind(to: activityIndicator.rx.isAnimating)
            .disposed(by: disposeBag)

        viewModel.errorMessageValue
            .asObservable()
            .bind { [weak self] errorDescription in
                guard let description = errorDescription else { return }
                self?.showAlert(title: "Error", message: description)
            }
            .disposed(by: disposeBag)

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
