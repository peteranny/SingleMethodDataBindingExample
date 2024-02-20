//
//  SimpleTableViewController.swift
//  SimpleProject
//
//  Created by Peter Shih on 2024/2/20.
//

import RxCocoa // To allow Reactive extensions such as button.rx.tap
import RxDataSources // To allow the event-driven data source of the table view
import RxSwift
import UIKit

class SimpleTableViewController: UITableViewController {
  private let viewModel = SimpleTableViewModel()
  private var disposeBag = DisposeBag()

  typealias Section = SectionModel<String, Int>
  override func viewDidLoad() {
    super.viewDidLoad()

    // Create table data source
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    let tableDataSource = RxTableViewSectionedReloadDataSource<Section> { dataSource, tableView, indexPath, item in
      let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
      cell.textLabel?.text = "Item \(item)"
      return cell
    }

    tableView.delegate = nil
    tableView.dataSource = nil

    // Bind the inputs to the view model
    let inputs = SimpleTableViewModel.Inputs(
        fetchItems: .just(()),
        selectItem: tableView.rx.modelSelected(Int.self).asObservable()
    )
    let outputs = viewModel.bind(inputs)

    // Bind the outputs from the view model
    outputs.items
      .map { [Section(model: "items", items: $0)] }
      .drive(tableView.rx.items(dataSource: tableDataSource))
      .disposed(by: disposeBag)

    outputs.showItemContent
      .map { content in UIAlertController(content: content) }
      .emit(with: self, onNext: { vc, alert in vc.present(alert, animated: true) })
      .disposed(by: disposeBag)

    outputs.disposable
      .disposed(by: disposeBag)
  }
}

extension UIAlertController {
  convenience init(content: String) {
    self.init(title: content, message: nil, preferredStyle: .alert)

    addAction(UIAlertAction(title: "OK", style: .default))
  }
}
