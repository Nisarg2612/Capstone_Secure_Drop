//
//  HistoryCellViewModel.swift
//  SecureDrop_BasicVersion
//
//  Created by Norris Wise Jr on 11/11/22.
//

import Foundation
import UIKit

protocol HistoryCellBusinessLogic {
	var cellStyle: CellStyle { get }
	func configure(with deliveryOrder: DeliveryOrder)
	func getDeliveryPin() -> Int
	func getOrderID() -> String
	func getOrderDetails() -> String
	func getOrderStatus() -> String
	func getVendorDetails()  -> String
}

enum CellStyle: Int {
	case past = 0
	case current
	
	var color: UIColor {
		switch self {
			case .current: return UIColor.init(displayP3Red: 0, green: 102/255, blue: 0, alpha: 1)
			case .past: return .red
		}
	}
}
class HistoryCellViewModel {
	private var deliveryOrder: DeliveryOrder
	var cellStyle: CellStyle
	init(deliveryOrder: DeliveryOrder, cellStyle: CellStyle = .current) {
		self.deliveryOrder = deliveryOrder
		self.cellStyle = cellStyle
	}
}

extension HistoryCellViewModel: HistoryCellBusinessLogic {
	func getOrderStatus() -> String {
		"NO STATUS"
	}
	
	func getDeliveryPin() -> Int {
		self.deliveryOrder.deliveryPin ?? -1
	}
	
	func getOrderID() -> String {
		self.deliveryOrder.orderID ?? "MISSING ID"
	}
	
	func getOrderDetails() -> String {
		self.deliveryOrder.orderDetails ?? "NO ORDER DETAILS"
	}
	
	func getVendorDetails() -> String {
		self.deliveryOrder.vendorDetails ?? "No VENDOR DETAILS"
	}
	
	
	func configure(with deliveryOrder: DeliveryOrder) {
		self.deliveryOrder = deliveryOrder
	}
}
