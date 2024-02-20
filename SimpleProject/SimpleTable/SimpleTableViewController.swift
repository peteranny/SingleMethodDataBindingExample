//
//  SimpleTableViewController.swift
//  SimpleProject
//
//  Created by Peter Shih on 2024/2/20.
//

import Combine
import CombineCocoa // To allow publisher extensions such as button.tapPublisher
import CombineDataSources // To allow the event-driven data source of the table view
import CombineExt // To enable the Combine extension Publishers.withLatestFrom. Ref: https://github.com/CombineCommunity/CombineExt
import UIKit

class SimpleTableViewController: UITableViewController {
  private let viewModel = SimpleTableViewModel()
  private var cancellables: [AnyCancellable] = []

  override func viewDidLoad() {
    super.viewDidLoad()

    // Create table data source
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    let itemsController = TableViewItemsController<[[Int]]> { controller, tableView, indexPath, item in
      let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
      cell.textLabel?.text = "Item \(item)"
      return cell
    }

    tableView.delegate = nil
    tableView.dataSource = nil

    let itemsSubject = ReplaySubject<[Int], Never>(bufferSize: 1)
    itemsSubject.subscribe(tableView.rowsSubscriber(itemsController))

    let didSelectItemPublisher = tableView.didSelectRowPublisher
      .withLatestFrom(itemsSubject, resultSelector: { indexPath, items in items[indexPath.row] })

    // Bind the inputs to the view model
    let inputs = SimpleTableViewModel.Inputs(
        fetchItems: Just(()).eraseToAnyPublisher(),
        selectItem: didSelectItemPublisher.eraseToAnyPublisher()
    )
    let outputs = viewModel.bind(inputs)

    // Bind the outputs from the view model
    outputs.items
      .sink(receiveValue: { itemsSubject.send($0) })
      .store(in: &cancellables)

    outputs.showItemContent
      .map { content in UIAlertController(content: content) }
      .sink(receiveValue: { [weak self] alert in self?.present(alert, animated: true) })
      .store(in: &cancellables)

    cancellables.append(contentsOf: outputs.cancellables)
  }
}

extension UIAlertController {
  convenience init(content: String) {
    self.init(title: content, message: nil, preferredStyle: .alert)

    addAction(UIAlertAction(title: "OK", style: .default))
  }
}
