//
//  CounterViewController.swift
//  MVVMRxSwiftTest
//
//  Created by Shirou on 2020/03/01.
//  Copyright © 2020 Shirou. All rights reserved.
//

import UIKit
import RxSwift

final class CounterViewController: UIViewController {

    @IBOutlet var countLabel: UILabel!
    @IBOutlet var plusButton: UIButton!
    @IBOutlet var subtractButton: UIButton!
    
    var disposeBag = DisposeBag()
    var viewModel = CounterViewModel()
    
    private lazy var input = CounterViewModel.Input(refresh: .just(()),
                                                    plusAction: plusButton.rx.tap.asObservable(),
                                                    subtractAction: subtractButton.rx.tap.asObservable())
    private lazy var output = viewModel.transform(input: input)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
    }
    
    private func bindViewModel() {
        output.countedValue.map { String($0) }.drive(countLabel.rx.text).disposed(by: disposeBag)
    }
}
