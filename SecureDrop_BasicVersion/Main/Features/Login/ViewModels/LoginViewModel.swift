//
//  LoginViewModel.swift
//  SecureDrop_BasicVersion
//
//  Created by Norris Wise Jr on 11/12/22.
//

import Foundation
import Firebase

protocol LoginBusinessLogic {
	var coordinator: NavigationResponderDelegate { get }
	func signIn(authUser: AuthUser)
}

class LoginViewModel {
	var coordinator: NavigationResponderDelegate = Coordinator.shared
	let auth: AuthBusinessLogic
	let delivery: DeliveryBusinessLogic
	var delegate: LoginViewResponder?
	init(authViewModel: AuthBusinessLogic, deliveryViewModel: DeliveryBusinessLogic) {
		self.auth = authViewModel
		self.delivery = deliveryViewModel
	}
}
extension LoginViewModel: LoginBusinessLogic {
	func signIn(authUser: AuthUser) {
		DispatchQueue.global(qos: .userInteractive).async {
				let semaphore = DispatchSemaphore(value: 0)
				let timeout: Double = 10.0
				var firUser: User!
				var deliveryOwner: DeliveryOwner!
				var isAuthenticated = false
					//sign-in
				self.auth.signIn(user: authUser) { authResult in
					switch authResult {
						case .success(let firUserFromFirebase):
							Log("login succes for user: \(String(describing: firUserFromFirebase.user.email ?? "N/A"))", .debug)
							isAuthenticated = true
							firUser = firUserFromFirebase.user
							semaphore.signal()
							break
						case .failure(let err):
							isAuthenticated = false
							DispatchQueue.main.async {
								self.delegate?.showErrorLabel(with: err.localizedDescription)
							}
							semaphore.signal()
							break
					}
				}
				let _ = semaphore.wait(timeout: .now() + timeout)
				
					//if user is authenticated continue else exit
				guard isAuthenticated else { return }
				
					//user is authenticated, now get delivery owner
				self.delivery.getDeliveryOwner(for: firUser) { deliveryOwnerFromDB in
					deliveryOwner = deliveryOwnerFromDB
					semaphore.signal()
				}
				let _ = semaphore.wait(timeout: .now() + timeout)
				
					//check for deliveryOwner
					//get deliveryOwner, else exit
				guard deliveryOwner != nil else { return }
				
					//if success, check MPIN. if not present..
				guard let mPin = deliveryOwner.pinAuthInfo?.mPin else {
						//...set mPin to 0
					deliveryOwner.pinAuthInfo?.mPin = "0000"
					self.delivery.updateMPin(deliveryOwner: deliveryOwner) { result in
						DispatchQueue.main.async {
							let didUpdate = (try? result.get()) ?? false
								//if updated to 0, show SetMPinVC
							if didUpdate {
								self.delegate?.showSetMPinViewController()
							} else {
								let errMsg = "There is an error with your account. Please contact an customer support."
								self.delegate?.showErrorLabel(with: errMsg)
							}
						}
					}
					return
				}
				
					//if MPIN is == 0 show SetMPinViewController
				if mPin == "0000" || mPin == "0" {
					DispatchQueue.main.async {
						self.delegate?.showSetMPinViewController()
					}
				} else {
						// else show SetDeliveryPinViewController
					DispatchQueue.main.async {
						self.delegate?.showSetDeliveryPinViewController()
					}
				}
			
		}
	}
	
	
}
