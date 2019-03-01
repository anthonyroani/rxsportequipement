//
//  BaseViewController.swift
//  RxSportLyon
//
//  Created by Anthony Roani on 25/02/2019.
//  Copyright © 2019 Anthony Roani. All rights reserved.
//

import UIKit
import RxSwift

class BaseViewController<T>: UIViewController {

    var viewModel: T! = nil
    var disposeBag: DisposeBag! = nil

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureBindings(viewModel)
        configureCallbacks(viewModel)
    }

    open func configureBindings(_ viewModel: T) {}
    open func configureCallbacks(_ viewModel: T) {}

}
