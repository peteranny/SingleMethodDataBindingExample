//
//  SimpleViewModel.swift
//  SimpleProject
//
//  Created by Peter Shih on 2024/2/20.
//

import Combine
import CombineExt // To enable the Combine extension Publishers.withLatestFrom. Ref: https://github.com/CombineCommunity/CombineExt

class SimpleViewModel: ViewModelBinding {
  enum Color: CaseIterable {
    case red, blue, purple
  }

  struct Inputs {
    let buttonTap: AnyPublisher<Void, Never>
  }

  struct Outputs {
    let backgroundColor: AnyPublisher<Color, Never>
    let buttonTitle: AnyPublisher<String, Never>
    let cancellable: AnyCancellable
  }

  func bind(_ inputs: Inputs) -> Outputs {
    let colors = Just(Color.allCases)
    let currentColorIndexSubject = CurrentValueSubject<Int, Never>(0)

    let currentColor = Publishers
        .CombineLatest(colors, currentColorIndexSubject)
        .map { colors, currentColorIndex in colors[currentColorIndex] }

    let nextColorIndex = Publishers
        .CombineLatest(colors, currentColorIndexSubject)
        .map { colors, currentColorIndex in (currentColorIndex + 1) % colors.count }

    let nextColor = Publishers
        .CombineLatest(colors, nextColorIndex)
        .map { colors, nextColorIndex in colors[nextColorIndex] }

    // Form the output event streams for the binder to subscribe
    return Outputs(
      backgroundColor: currentColor.eraseToAnyPublisher(),
      buttonTitle: nextColor.map { "Change to \($0)" }.eraseToAnyPublisher(),
      cancellable: inputs.buttonTap.withLatestFrom(nextColorIndex).sink(receiveValue: { currentColorIndexSubject.send($0) })
    )
  }
}
