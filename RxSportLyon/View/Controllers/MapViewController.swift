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

class MapViewController : BaseViewController<MapViewModel> {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var reloadButton: RoundedButton!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var kilometersLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()   
    }
    
    // MARK : Bindings & Callbacks
    
    override func bindViewModel(_ viewModel: MapViewModel) {
        slider.rx.value
            .map { String(format: "%.2f", $0) }
            .bind(to: kilometersLabel.rx.text)
            .disposed(by: disposeBag)
        
        slider.rx.value
            .bind(to: viewModel.sliderValue)
            .disposed(by: disposeBag)
        
        _ = reloadButton.rx.tap.subscribe({ [weak self] _ in
            self?.viewModel.reloadMap()
        })
    }
    
    override func createCallbacks(_ viewModel: MapViewModel) {
        viewModel.loadingStateValue.asObservable()
            .bind { isLoading in
                if isLoading { self.activityIndicator.startAnimating() }
                self.activityIndicator.isHidden = !isLoading
            }.disposed(by: disposeBag)
    }

}

class MapViewControllerAssembly : Assembly {
    func assemble(container: Container) {
        container.storyboardInitCompleted(MapViewController.self, initCompleted: { (resolver, controller) in
            controller.disposeBag = DisposeBag()
            controller.viewModel = resolver.resolve(MapViewModel.self)!
        })
    }
}
