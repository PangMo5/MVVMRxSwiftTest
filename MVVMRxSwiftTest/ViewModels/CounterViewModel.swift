//
//  CounterViewModel.swift
//  MVVMRxSwiftTest
//
//  Created by Shirou on 2020/03/01.
//  Copyright © 2020 Shirou. All rights reserved.
//

import Foundation
import Moya
import RxSwift
import RxCocoa

struct CounterDataModel: Codable {
    var counterDefaultValue: Int
}

struct CounterAPI: TargetType {
    var baseURL: URL {
        URL(string: "https://apple.com")!
    }
    
    var path: String {
        ""
    }
    
    var method: Moya.Method {
        .get
    }
    
    var sampleData: Data {
        "}".data(using: .utf8)!
    }
    
    var task: Task {
        .requestPlain
    }
    
    var headers: [String : String]? {
        nil
    }
}

final class CounterViewModel: ViewModelType {
    
    let disposeBag = DisposeBag()
    var provider = MoyaProvider<CounterAPI>()
    
    struct Input {
        var refresh: Observable<Void>
        var plusAction: Observable<Void>
        var subtractAction: Observable<Void>
    }
    
    struct Output {
        var countedValue: Driver<Int>
    }
    
    func transform(input: Input) -> Output {
        let countedValue = BehaviorRelay(value: 0)
        
        let counterObservable = input.refresh
            .flatMapLatest { [provider] _ in
                return provider.rx.request(.init())
                    .map(CounterDataModel.self)
        }.share()
        
        counterObservable.map { $0.counterDefaultValue }
            .subscribe(onNext: { defaultValue in
                countedValue.accept(defaultValue)
            }).disposed(by: disposeBag)
        
        input.plusAction
            .skipUntil(counterObservable)
            .subscribe(onNext: { _ in
                countedValue.accept(countedValue.value + 1)
            }).disposed(by: disposeBag)
        
        input.subtractAction
            .skipUntil(counterObservable)
            .subscribe(onNext: { _ in
                countedValue.accept(countedValue.value - 1)
            }).disposed(by: disposeBag)
        
        return Output(countedValue: countedValue.asDriver(onErrorJustReturn: 0))
    }
}
