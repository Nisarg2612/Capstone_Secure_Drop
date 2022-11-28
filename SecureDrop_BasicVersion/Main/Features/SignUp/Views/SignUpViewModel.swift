//
//  SignUpViewModel.swift
//  SecureDrop_BasicVersion
//
//  Created by Norris Wise Jr on 11/10/22.
//

import Foundation
import FirebaseAuth
import Firebase
protocol SignUpBusinessLogic {
	var coordinator: NavigationResponderDelegate { get }
	var delivery: DeliveryBusinessLogic { get }
	var auth: AuthBusinessLogic { get }
	func signUp(authUser: AuthUser, callback: @escaping (Result<Bool, Error>) -> Void)
}
class SignUpViewModel {
	var coordinator: NavigationResponderDelegate = Coordinator.shared
	let delivery: DeliveryBusinessLogic
	let auth: AuthBusinessLogic
	
	func signUp(authUser: AuthUser, callback: @escaping (Result<Bool, Error>) -> Void) {
		let semaphore = DispatchSemaphore(value: 0)
		let timeout = 60.0
		var completionResult: Result<Bool, Error> = .failure(SignUpError.clientRequestError)
		var newFirUser: User!
		//launch request
		DispatchQueue.global(qos: .userInteractive).async {
			self.auth.signUp(user: authUser) { (result: Result<AuthDataResult, Error>) in
				switch result {
					case .success(let firResult):
						newFirUser = firResult.user
						semaphore.signal()
						break
					case .failure(let err):
						completionResult = .failure(err)
						callback(completionResult)
						return
				}
			}
				//wait for request to finish with timeout 5.0
				//			let _ = semaphore.wait(timeout: .now() + timeout)
			semaphore.wait()
				//launch second request
			let pinAuthInfo = PinAuthInfo(mPin: 0)
			let newDeliveryOwner = self.delivery.makeNewDeliveryOwner(firebaseUser: newFirUser, pinAuthInfo: pinAuthInfo)
			
			self.delivery.addNewDeliveryOwnerToDatabase(newDeliveryOwner) { result in
				switch result {
					case .success(let didAddDelievryOwner):
						if didAddDelievryOwner {
							completionResult = .success(true)
						} else {
							completionResult = .success(false)
						}
					case .failure(let err):
						completionResult = .failure(err)
				}
				semaphore.signal()
			}
				//wait for request to finish with timout 5.0
			let _ = semaphore.wait()
				//respond with completion handler Result<Bool, Error> type
			DispatchQueue.main.async {
				callback(completionResult)
			}
			
		}
		
//		DispatchQueue.global(qos: .userInteractive).async {}
	}
	
	init(authBusinessLogic: AuthBusinessLogic, deliveryBusinessLogic: DeliveryBusinessLogic) {
		self.auth = authBusinessLogic
		self.delivery = deliveryBusinessLogic
	}
}

enum SignUpError: Error {
	case clientRequestError
	var description: String {
		switch self {
			case .clientRequestError: return "Client-Side error making request"
		}
	}
}
