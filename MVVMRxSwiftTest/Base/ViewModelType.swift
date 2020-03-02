//
//  ViewModelType.swift
//  MVVMRxSwiftTest
//
//  Created by Shirou on 2020/03/01.
//  Copyright © 2020 Shirou. All rights reserved.
//

import Foundation

protocol ViewModelType: class {
    associatedtype Input
    associatedtype Output

    func transform(input: Input) -> Output
}
