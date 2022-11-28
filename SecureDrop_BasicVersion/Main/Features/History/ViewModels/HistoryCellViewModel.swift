//
//  HistoryCellViewModel.swift
//  SecureDrop_BasicVersion
//
//  Created by Norris Wise Jr on 11/11/22.
//

import Foundation

protocol HistoryCellBusinessLogic {
	func configure(with deliveryOrder: DeliveryOrder)
	func getDeliveryPin() -> Int
	func getOrderID() -> String
	func getOrderDetails() -> String
	func getOrderStatus() -> String
	func getVendorDetails()  -> String
}

class HistoryCellViewModel {
	private var deliveryOrder: DeliveryOrder
	
	init(deliveryOrder: DeliveryOrder) {
		self.deliveryOrder = deliveryOrder
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
