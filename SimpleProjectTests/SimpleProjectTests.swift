//
//  SimpleProjectTests.swift
//  SimpleProjectTests
//
//  Created by Peter Shih on 2024/2/20.
//

@testable import SimpleProject
import Combine
import Entwine
import EntwineTest
import XCTest

class SimpleProjectTests: XCTestCase {
  func test_binding() {
    let scheduler = TestScheduler(initialClock: .zero)

    // Create inputs
    let buttonTap = scheduler.createAbsoluteTestablePublisher(TestSequence<Void, Never>([
        (1, .input(())), (2, .input(())), (3, .input(())),
    ])).eraseToAnyPublisher()

    // Create output observers
    let backgroundColorSubscriber = scheduler.createTestableSubscriber(SimpleViewModel.Color.self, Never.self)
    let buttonTitleSubscriber = scheduler.createTestableSubscriber(String.self, Never.self)

    // Bind the inputs to the view model
    let viewModel = SimpleViewModel()
    let inputs = SimpleViewModel.Inputs(
       buttonTap: buttonTap
    )
    let outputs = viewModel.bind(inputs)

    // Bind the outputs from the view model
    var cancellables: [AnyCancellable] = []
    outputs.backgroundColor.receive(subscriber: backgroundColorSubscriber)
    outputs.buttonTitle.receive(subscriber: buttonTitleSubscriber)
    outputs.cancellable.store(in: &cancellables)

    // Start testing
    scheduler.resume()
    XCTAssertEqual(backgroundColorSubscriber.recordedOutput, [
      (0, .subscription),
      (0, .input(.red)),
      (1, .input(.blue)),
      (2, .input(.purple)),
      (3, .input(.red)),
    ])
    XCTAssertEqual(buttonTitleSubscriber.recordedOutput, [
      (0, .subscription),
      (0, .input("Change to blue")),
      (1, .input("Change to purple")),
      (2, .input("Change to red")),
      (3, .input("Change to blue")),
    ])
  }
}
