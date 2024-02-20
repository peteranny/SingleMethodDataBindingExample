//
//  ViewController.swift
//  SimpleProject
//
//  Created by Peter Shih on 2024/2/20.
//

import RxCocoa // To allow Reactive extensions such as button.rx.tap
import RxSwift
import UIKit

class SimpleViewController: UIViewController {
  private let viewModel = SimpleViewModel()
  private var disposeBag = DisposeBag()

  private let button = UIButton()
  override func viewDidLoad() {
    super.viewDidLoad()

    // Install the button
    view.addSubview(button)
    button.frame = UIScreen.main.bounds

    // Bind the inputs to the view model
    let inputs = SimpleViewModel.Inputs(
      buttonTap: button.rx.tap.asObservable()
    )
    let outputs = viewModel.bind(inputs)

    // Bind the outputs from the view model
    outputs.backgroundColor
      .map { $0.uiColor }
      .drive(with: view, onNext: { view, bgColor in view.backgroundColor = bgColor }) // or simply .drive(view.rx.backgroundColor)
      .disposed(by: disposeBag)

    outputs.buttonTitle
      .drive(with: button, onNext: { button, btnTitle in button.setTitle(btnTitle, for: .normal) }) // or simply .drive(button.rx.title(for: .normal))
      .disposed(by: disposeBag)

    outputs.disposable
      .disposed(by: disposeBag)
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
