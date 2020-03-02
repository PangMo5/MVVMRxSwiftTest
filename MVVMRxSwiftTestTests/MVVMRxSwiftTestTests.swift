//
//  MVVMRxSwiftTestTests.swift
//  MVVMRxSwiftTestTests
//
//  Created by Shirou on 2020/03/01.
//  Copyright © 2020 Shirou. All rights reserved.
//

import Foundation
import XCTest
import Nimble
import RxSwift
import RxNimble
import RxTest
import Moya

@testable
import MVVMRxSwiftTest

extension Endpoint {
    class func succeedEndpointClosure<T: TargetType, E: Encodable>(_ targetType: T.Type, with object: E) -> (T) -> Endpoint {
        return { (target: T) -> Endpoint in
            let data = try! JSONEncoder().encode(object)
            return Endpoint(url: URL(target: target).absoluteString,
                            sampleResponseClosure: {.networkResponse(200, data)},
                            method: target.method,
                            task: target.task,
                            httpHeaderFields: target.headers)
        }
    }
}

class CounterTests: XCTestCase {
    
    var viewModel: CounterViewModel!
    var output: CounterViewModel.Output!
    var scheduler: TestScheduler!
    var disposeBag: DisposeBag!
    
    var refreshSubject: PublishSubject<Void>!
    var plusSubject: PublishSubject<Void>!
    var subtractSubject: PublishSubject<Void>!
    
    override func setUp() {
        scheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()
        refreshSubject = PublishSubject<Void>()
        plusSubject = PublishSubject<Void>()
        subtractSubject = PublishSubject<Void>()
        viewModel = CounterViewModel()
        viewModel.provider = MoyaProvider<CounterAPI>(endpointClosure: Endpoint.succeedEndpointClosure(CounterAPI.self, with: CounterDataModel(counterDefaultValue: 5)),
                                                      stubClosure: MoyaProvider.immediatelyStub)
        output = viewModel.transform(input: .init(refresh: .just(()),
                                                  plusAction: plusSubject.asObservable(),
                                                  subtractAction: subtractSubject.asObservable()))
    }
    
    func testCountedValue() {
        scheduler.createColdObservable(
            [
                .next(0, ())
            ]
        ).bind(to: refreshSubject).disposed(by: disposeBag)
        
        scheduler.createColdObservable(
            [
                .next(10, ()),
                .next(20, ()),
                .next(30, ())
            ]
        ).bind(to: plusSubject).disposed(by: disposeBag)
        
        scheduler.createColdObservable(
            [
                .next(25, ())
            ]
        ).bind(to: subtractSubject).disposed(by: disposeBag)

        expect(self.output.countedValue).events(scheduler: scheduler, disposeBag: disposeBag).to(equal(
                [
                    .next(0, 5),
                    .next(10, 6),
                    .next(20, 7),
                    .next(25, 6),
                    .next(30, 7)
                ]
        ))
    }
}
