//
//  SimpleTableViewModel.swift
//  SimpleProject
//
//  Created by Peter Shih on 2024/2/20.
//

import RxCocoa
import RxSwift

class SimpleTableViewModel: ViewModelBinding {
  struct Inputs {
    let fetchItems: Observable<Void>
    let selectItem: Observable<Int>
  }

  struct Outputs {
    let items: Driver<[Int]>
    let showItemContent: Signal<String>
    let disposable: Disposable
  }

  func bind(_ inputs: Inputs) -> Outputs {
    let itemsRelay = BehaviorRelay<[Int]>(value: [])

    let bindFetchItems = inputs.fetchItems
      .flatMap { [itemService] in itemService.fetchItems() }
      .bind(to: itemsRelay)

    let showItemContentRelay = PublishRelay<String>()

    let bindSelectItem = inputs.selectItem
      .flatMap { [itemService] item in itemService.fetchItemContent(item) }
      .bind(to: showItemContentRelay)

    // Form the output event streams for the binder to subscribe
    return Outputs(
      items: itemsRelay.asDriver(),
      showItemContent: showItemContentRelay.asSignal(),
      disposable: Disposables.create(bindFetchItems, bindSelectItem)
    )
  }

  private let itemService = ItemService()
}

class ItemService {
  func fetchItems() -> Single<[Int]> {
    Single.just(Array(0...10))
  }

  func fetchItemContent(_ item: Int) -> Single<String> {
    Single.just("Content of \(item)")
  }
}
