//
//  MPinViewModel.swift
//  SecureDrop_BasicVersion
//
//  Created by Norris Wise Jr on 11/11/22.
//

import Foundation
import Firebase
import FirebaseAuth

protocol MPinBusinessLogic {
	var coordinator: NavigationResponderDelegate { get }
	func setMasterPin(firUser: User, mPin: String)
}

class MPinViewModel {
	let delivery: DeliveryBusinessLogic
	var delegate: SetMPinViewResponder?
	var coordinator: NavigationResponderDelegate = Coordinator.shared
	
	init(deliveryViewModel: DeliveryBusinessLogic) {
		self.delivery = deliveryViewModel
	}
}
extension MPinViewModel: MPinBusinessLogic {
	func setMasterPin(firUser: User, mPin: String) {
		DispatchQueue.global(qos: .userInteractive).async {
			
			let semaphore = DispatchSemaphore(value: 0)
			let timeout = 20.0
			var deliveryOwner: DeliveryOwner?
			//get delivery owner
			self.delivery.getDeliveryOwner(for: firUser) { deliveryOwnerFromDB in
				deliveryOwner = deliveryOwnerFromDB
				semaphore.signal()
			}
			
			let _ = semaphore.wait(timeout: .now() + timeout)
			//if success...
			guard var deliveryOwner = deliveryOwner else {
					//else return with error
				DispatchQueue.main.async {
					self.delegate?.showError(title: "Error", message: DeliveryLogicNetworkError.missingDeliveryOwner.description)
				}
				return
			}
			//...updateMPIN
			deliveryOwner.pinAuthInfo?.mPin = mPin
			self.delivery.updateMPin(deliveryOwner: deliveryOwner) { result in
				DispatchQueue.main.async {
					switch result {
						case .success(let didUpdate):
							if didUpdate {
								self.delegate?.didSetMPin(update: "Success", message: "Updated MPIN")
							} else {
								self.delegate?.showError(title: "Uh Oh", message: "Could Not Update MPin")
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

//viewModel?.getDeliveryOwner(for: firUser) { [unowned self]
//	deliveryOwner in
//	self.removeLoadingIndicator()
//	guard var deliveryOwner = deliveryOwner
//			else {
//		let alertVC = self.makeAlertVC(title: "Error", message: "Corrupted SecureDrop Account. Please Contact Administator")
//		self.present(alertVC, animated: true)
//		return
//	}
//	deliveryOwner.pinAuthInfo?.mPin = mPin
//	self.viewModel?.updateMPin(deliveryOwner: deliveryOwner) {
//		result in
//		if let hasSuccess = try? result.get(), hasSuccess {
//			let alertVC = self.makeAlertVC(title: "Success", message: "Successfully Updated MPin") { [unowned self] in
//				DispatchQueue.main.async {
//					let deliveryPinVC = DeliveryPinViewController.instantiate() as DeliveryPinViewController
//					deliveryPinVC.viewModel = DeliveryViewModel()
//					self.viewModel?.coordinator?.pushView(deliveryPinVC)
//				}
//			}
//			self.viewModel?.coordinator?.presentView(alertVC)
//		}
//	}
//}
