//
//  HistoryTableViewCell.swift
//  SecureDrop_BasicVersion
//
//  Created by Norris Wise Jr on 11/11/22.
//

import Foundation
import UIKit

//protocol HistoryCellBusinessLogic {
//	func configure(with deliveryOrder: DeliveryOrder)
//	func deliveryPin() -> Int
//	func orderID() -> String
//	func orderDetails() -> String
//	func vendorDetails()  -> String
//	func status() -> Int
//}


class HistoryTableViewCell: UITableViewCell {
	static let reuseID = String(describing: HistoryTableViewCell.self)
	private let historyView = HistoryCollectionViewCell(viewModel: HistoryCellViewModel(deliveryOrder: DeliveryOrder()))
	
	//configure
	public func configure(with viewModel: HistoryCellViewModel) {
		self.historyView.configure(with: viewModel, fontType: .body)
	}
	
	//buildView
	private func addConstraints() {
		self.historyView.anchor(top: self.contentView.topAnchor, right: self.contentView.trailingAnchor, bottom: self.contentView.bottomAnchor, left: self.contentView.leadingAnchor, padding: .zero, size: .zero)
	}
	private func addSubviews() {
		self.contentView.addSubview(historyView)
	}
	
	private func buildView() {
		addSubviews()
		addConstraints()
	}
	
	//lifecycle
	override func didMoveToSuperview() {
		super.didMoveToSuperview()
		buildView()
	}
}


