//
//  DeliveryPinViewModel.swift
//  SecureDrop_BasicVersion
//
//  Created by Norris Wise Jr on 12/1/22.
//

import Foundation
import Firebase
import FirebaseAuth

protocol DeliveryPinViewModelProtocol {
	var delivery: DeliveryBusinessLogic { get }
	var coordinator: Coordinator { get } 
	func updateMPin(firUser: User, newMPIN: String, completion: @escaping (Result<Bool, Error>) -> Void)
	func updatePassword(with newPassword: String, completion: @escaping (Bool) -> Void)
}

class DeliveryPinViewModel {
	var coordinator: Coordinator = Coordinator.shared
	var auth: AuthBusinessLogic = AuthViewModel()
	var delivery: DeliveryBusinessLogic = DeliveryViewModel()
}

extension DeliveryPinViewModel: DeliveryPinViewModelProtocol {
	
	func updateMPin(firUser: User, newMPIN: String, completion: @escaping (Result<Bool, Error>) -> Void) {
		
		DispatchQueue.global(qos: .userInteractive).async {
			var currentDeliveryOwner: DeliveryOwner?
			let semaphore = DispatchSemaphore(value: 0)
			self.delivery.getDeliveryOwner(for: firUser) { fetchedDeliveryOwner in
				guard let deliveryOwner = fetchedDeliveryOwner else {
					return
				}
				currentDeliveryOwner = deliveryOwner
				semaphore.signal()
			}
			_ = semaphore.wait(timeout: .now() + 30)
			guard let deliveryOwner = currentDeliveryOwner else {
				//TODO: Write Error flow
				DispatchQueue.main.async {
					completion(.failure(DeliveryLogicNetworkError.missingDeliveryOwner))
				}
				return
			}
			var mutableDeliveryOwner = deliveryOwner
			mutableDeliveryOwner.pinAuthInfo?.mPin = newMPIN
			self.delivery.updateMPin(deliveryOwner: mutableDeliveryOwner) { result in
				DispatchQueue.main.async {
					completion(result)
				}
			}
		}
		
	}
	func updatePassword(with newPassword: String, completion: @escaping (Bool) -> Void) {
		self.auth.updatePassword(with: newPassword, completion: completion)
	}
}
