//
//  SimpleProjectTests.swift
//  SimpleProjectTests
//
//  Created by Peter Shih on 2024/2/20.
//

@testable import SimpleProject
import RxSwift
import RxTest
import XCTest

class SimpleProjectTests: XCTestCase {
  func test_binding() {
    let scheduler = TestScheduler(initialClock: .zero)

    // Create inputs
    let buttonTap = scheduler.createColdObservable([
        .next(1, ()), .next(2, ()), .next(3, ()),
    ]).asObservable()

    // Create output observers
    let backgroundColorObserver = scheduler.createObserver(SimpleViewModel.Color.self)
    let buttonTitleObserver = scheduler.createObserver(String.self)

    // Bind the inputs to the view model
    let viewModel = SimpleViewModel()
    let inputs = SimpleViewModel.Inputs(
       buttonTap: buttonTap
    )
    let outputs = viewModel.bind(inputs)

    // Bind the outputs from the view model
    let disposeBag = DisposeBag()
    outputs.backgroundColor.drive(backgroundColorObserver).disposed(by: disposeBag)
    outputs.buttonTitle.drive(buttonTitleObserver).disposed(by: disposeBag)
    outputs.disposable.disposed(by: disposeBag)

    // Start testing
    scheduler.start()
    XCTAssertEqual(backgroundColorObserver.events, [
      .next(0, .red),
      .next(1, .blue),
      .next(2, .purple),
      .next(3, .red),
    ])
    XCTAssertEqual(buttonTitleObserver.events, [
      .next(0, "Change to blue"),
      .next(1, "Change to purple"),
      .next(2, "Change to red"),
      .next(3, "Change to blue"),
    ])
  }
}
