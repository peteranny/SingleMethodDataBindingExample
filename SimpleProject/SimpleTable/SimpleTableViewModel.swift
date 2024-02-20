//
//  SimpleTableViewModel.swift
//  SimpleProject
//
//  Created by Peter Shih on 2024/2/20.
//

import Combine

class SimpleTableViewModel: ViewModelBinding {
  struct Inputs {
    let fetchItems: AnyPublisher<Void, Never>
    let selectItem: AnyPublisher<Int, Never>
  }

  struct Outputs {
    let items: AnyPublisher<[Int], Never>
    let showItemContent: AnyPublisher<String, Never>
    let cancellables: [AnyCancellable]
  }

  func bind(_ inputs: Inputs) -> Outputs {
    let itemsSubject = CurrentValueSubject<[Int], Never>([])

    let bindFetchItems = inputs.fetchItems
      .flatMap { [itemService] in itemService.fetchItems() }
      .sink(receiveCompletion: { _ in }, receiveValue: { itemsSubject.send($0) })

    let showItemContentSubject = PassthroughSubject<String, Never>()

    let bindSelectItem = inputs.selectItem
      .flatMap { [itemService] item in itemService.fetchItemContent(item) }
      .sink(receiveCompletion: { _ in }, receiveValue: { showItemContentSubject.send($0) })

    // Form the output event streams for the binder to subscribe
    return Outputs(
      items: itemsSubject.eraseToAnyPublisher(),
      showItemContent: showItemContentSubject.eraseToAnyPublisher(),
      cancellables: [bindFetchItems, bindSelectItem]
    )
  }

  private let itemService = ItemService()
}

class ItemService {
  func fetchItems() -> Future<[Int], Never> {
    Future { promise in promise(.success(Array(0...10))) }
  }

  func fetchItemContent(_ item: Int) -> Future<String, Never> {
    Future { promise in promise(.success("Content of \(item)")) }
  }
}
