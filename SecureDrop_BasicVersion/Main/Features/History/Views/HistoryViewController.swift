//
//  HistoryViewController.swift
//  SecureDrop_BasicVersion
//
//  Created by Norris Wise Jr on 11/11/22.
//

import Foundation
import UIKit


protocol HistoryViewResponder {
	func reloadDeliveryOrders()
	func showError(with title: String, and message: String)
}
class HistoryViewController: UIViewController {
	var historyTableView = UITableView(frame: .zero)
	var viewModel: HistoryBusinessLogic!
	
	//configure
	public func configure(historyViewModel: HistoryBusinessLogic) {
		self.viewModel = historyViewModel
		self.viewModel.downloadDeliveryOrders()
	}
	
	//lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()
		buildView()
		setup()
	}
	func setupView() {
		(self.viewModel as! HistoryViewModel).delegate = self
	}
	//setup
	func setupHistoryTableView() {
		self.historyTableView.delegate = self
		self.historyTableView.dataSource = self
		self.historyTableView.register(HistoryTableViewCell.self, forCellReuseIdentifier: HistoryTableViewCell.reuseID)
	}
	func setup() {
		setupHistoryTableView()
		setupView()
	}
	
	//buildView
	func addSubviews() {
		self.view?.addSubview(historyTableView)
	}
	func addConstraints() {
		historyTableView.anchor(top: self.view.topAnchor, right: self.view.trailingAnchor, bottom: self.view.bottomAnchor, left: self.view.leadingAnchor, padding: .zero, size: .zero)
	}
	func buildView() {
		addSubviews()
		addConstraints()
	}
	
	init() {
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}




//datasource+tableView
extension HistoryViewController: UITableViewDataSource {
	func numberOfSections(in tableView: UITableView) -> Int {
		return self.viewModel.getNumberOfDeliveryTypes()
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.viewModel.getNumberOfDeliveryOrders(in: section)
	}
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: HistoryTableViewCell.reuseID, for: indexPath) as! HistoryTableViewCell
		let deliveryOrder = self.viewModel.getDeliveryOrder(at: indexPath)!
		cell.configure(with: HistoryCellViewModel(deliveryOrder: deliveryOrder, cellStyle: CellStyle.init(rawValue: indexPath.section)!))
		return cell
	}
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return self.viewModel.getTitleForSection(at: section)
	}
}

//delegate+tableView
extension HistoryViewController: UITableViewDelegate {}


//DeliveryViewResponder
extension HistoryViewController: HistoryViewResponder {
	func reloadDeliveryOrders() {
		self.historyTableView.reloadData()
	}
	
	func showError(with title: String, and message: String) {
		let alertVC = self.makeAlertVC(title: title, message: message)
		self.present(alertVC, animated: true)
	}
	
	
}




