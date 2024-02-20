//
//  ViewController.swift
//  SimpleProject
//
//  Created by Peter Shih on 2024/2/20.
//

import Combine
import CombineCocoa // To allow publisher extensions such as button.tapPublisher
import UIKit

class SimpleViewController: UIViewController {
  private let viewModel = SimpleViewModel()
  private var cancellables: [AnyCancellable] = []

  private let button = UIButton()
  override func viewDidLoad() {
    super.viewDidLoad()

    // Install the button
    view.addSubview(button)
    button.frame = UIScreen.main.bounds

    // Bind the inputs to the view model
    let inputs = SimpleViewModel.Inputs(
      buttonTap: button.tapPublisher
    )
    let outputs = viewModel.bind(inputs)

    // Bind the outputs from the view model
    outputs.backgroundColor
      .map { $0.uiColor }
      .subscribe(on: DispatchQueue.main)
      .sink(receiveValue: { [view] in view?.backgroundColor = $0 })
      .store(in: &cancellables)

    outputs.buttonTitle
      .subscribe(on: DispatchQueue.main)
      .sink(receiveValue: { [button] in button.setTitle($0, for: .normal) })
      .store(in: &cancellables)

    outputs.cancellable
      .store(in: &cancellables)
  }
}

extension SimpleViewModel.Color {
  var uiColor: UIColor {
    switch self {
    case .red: return .red
    case .blue: return .blue
    case .purple: return .purple
    }
  }
}
