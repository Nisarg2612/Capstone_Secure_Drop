//
//  HistoryViewModel.swift
//  SecureDrop_BasicVersion
//
//  Created by Norris Wise Jr on 11/11/22.
//

import Foundation
import UIKit

protocol HistoryBusinessLogic {
	var coordinator: NavigationResponderDelegate { get }
	func getDeliveryOrder(at indexPath: IndexPath) -> DeliveryOrder?
	func getNumberOfDeliveryOrders(in section: Int) -> Int
	func getNumberOfDeliveryTypes() -> Int
	func getTitleForSection(at sectionIndex: Int) -> String
	func downloadDeliveryOrders()
}

class HistoryViewModel {
	enum SectionTitles: Int {
		case pastOrders = 0, currentOrders
		var description: String {
			switch self {
				case .currentOrders: return "Current Orders"
				case .pastOrders: return "Past Orders"
			}
		}
	}
	
	var coordinator: NavigationResponderDelegate = Coordinator.shared
	var deliveryOrders: [[DeliveryOrder]] = [[]]
	var delegate: HistoryViewResponder?
	private let deliveryOwner: DeliveryOwner
	init(deliveryOwner: DeliveryOwner) {
		self.deliveryOwner = deliveryOwner
	}
}
extension HistoryViewModel: HistoryBusinessLogic {
	func getTitleForSection(at sectionIndex: Int) -> String {
		return SectionTitles(rawValue: sectionIndex)?.description ?? ""
	}
	

	func downloadDeliveryOrders() {
		var orders = [deliveryOwner.pastOrders ?? []]
		orders.append(deliveryOwner.currentOrders ?? [])
		self.deliveryOrders = orders
		self.delegate?.reloadDeliveryOrders()
	}
	
	func getDeliveryOrder(at indexPath: IndexPath) -> DeliveryOrder? {
		guard indexPath.section < self.deliveryOrders.count else { return nil }
		guard indexPath.row < self.deliveryOrders[indexPath.section].count else {return nil }
		return self.deliveryOrders[indexPath.section][indexPath.row]
	}
	
	func getNumberOfDeliveryOrders(in section: Int) -> Int {
		guard self.deliveryOrders.count > section else { return 0 }
		return self.deliveryOrders[section].count
	}
	
	func getNumberOfDeliveryTypes() -> Int {
		self.deliveryOrders.count
	}
}
