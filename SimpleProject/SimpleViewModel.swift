//
//  SimpleViewModel.swift
//  SimpleProject
//
//  Created by Peter Shih on 2024/2/20.
//

import RxCocoa // To allow Driver and Signal
import RxSwift

class SimpleViewModel: ViewModelBinding {
  enum Color: CaseIterable {
    case red, blue, purple
  }

  struct Inputs {
    let buttonTap: Observable<Void>
  }

  struct Outputs {
    let backgroundColor: Driver<Color>
    let buttonTitle: Driver<String>
    let disposable: Disposable
  }

  func bind(_ inputs: Inputs) -> Outputs {
    let colors: Driver<[Color]> = .just(Color.allCases)
    let currentColorIndexRelay = BehaviorRelay<Int>(value: 0)

    let currentColor: Driver<Color> = Driver
        .combineLatest(colors, currentColorIndexRelay.asDriver())
        .map { colors, currentColorIndex in colors[currentColorIndex] }

    let nextColorIndex: Driver<Int> = Driver
        .combineLatest(colors, currentColorIndexRelay.asDriver())
        .map { colors, currentColorIndex in (currentColorIndex + 1) % colors.count }

    let nextColor: Driver<Color> = Driver
        .combineLatest(colors, nextColorIndex)
        .map { colors, nextColorIndex in colors[nextColorIndex] }

    // Form the output event streams for the binder to subscribe
    return Outputs(
      backgroundColor: currentColor,
      buttonTitle: nextColor.map { "Change to \($0)" },
      disposable: inputs.buttonTap.withLatestFrom(nextColorIndex).bind(to: currentColorIndexRelay)
    )
  }
}
