//
//  ShowDeliveryPinViewModel.swift
//  SecureDrop_BasicVersion
//
//  Created by Norris Wise Jr on 11/12/22.
//

import Foundation
import FirebaseAuth
import Firebase

protocol ShowDeliveryOrderBusinessLogic {
	var coordinator: NavigationResponderDelegate { get }
	var delivery: DeliveryBusinessLogic { get }
	func addNewOrderToDatabase(deliveryOrder: DeliveryOrder, for firUser: User)
}
class ShowDeliveryOrderViewModel {
	var coordinator: NavigationResponderDelegate = Coordinator.shared
	var delivery: DeliveryBusinessLogic
	weak var delegate: ShowDeliveryOrderResponder?
	
	init(deliveryViewModel: DeliveryBusinessLogic) {
		self.delivery = deliveryViewModel
	}
}

extension ShowDeliveryOrderViewModel: ShowDeliveryOrderBusinessLogic {
	func addNewOrderToDatabase(deliveryOrder: DeliveryOrder, for firUser: User) {
		DispatchQueue.global(qos: .userInteractive).async {
			
			let semaphore = DispatchSemaphore(value: 0)
			let timeout = 10.0
			var deliveryOwner: DeliveryOwner?
			//get delivery owner
			self.delivery.getDeliveryOwner(for: firUser) { deliveryOwnerFromDB in
				deliveryOwner = deliveryOwnerFromDB
			}
			
			let _ = semaphore.wait(timeout: .now() + timeout)
			//if success...
			guard let deliveryOwner = deliveryOwner else {
				//else return with error
				DispatchQueue.main.async {
					self.delegate?.showError(title: "Error", message: DeliveryLogicNetworkError.missingDeliveryOwner.description)
				}
				return
			}
			//...add new order to delivery owner
			self.delivery.addNewOrderToDatabase(deliveryOrder: deliveryOrder, for: deliveryOwner) { result in
				DispatchQueue.main.async {
					switch result {
						case .success(let didAdd):
							if didAdd {
								self.delegate?.didAddDeliveryOrder(title: "Success", message: "Added New Order\nOrderID: \(deliveryOrder.orderID ?? "field not used")")
							} else {
								self.delegate?.didAddDeliveryOrder(title: "Uh Oh", message: "Sorry, we could not add a new order at this time")
							}
							break
						case .failure(let err):
							self.delegate?.showError(title: "Error", message: err.localizedDescription)
							break
					}
				}
			}
		}
	}
}


