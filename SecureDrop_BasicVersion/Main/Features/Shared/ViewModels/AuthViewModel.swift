//
//  AuthViewModel.swift
//  SecureDrop_BasicVersion
//
//  Created by Norris Wise Jr on 11/10/22.
//

import Foundation
import FirebaseAuth
import Firebase

protocol AuthBusinessLogic: AnyObject {
	var coordinator: NavigationResponderDelegate { get }
	func signIn(user: AuthUser, completion: @escaping (Result<AuthDataResult, Error>) -> Void)
	func signOut(user: AuthUser, completion: @escaping (Result<Bool, Error>) -> Void)
	func signUp(user: AuthUser, completion: @escaping (Result<AuthDataResult, Error>) -> Void)
	func updatePassword(with newPassword: String, completion: @escaping (Bool) -> Void)
}


class AuthViewModel {
	var coordinator: NavigationResponderDelegate = Coordinator.shared
}

extension AuthViewModel: AuthBusinessLogic {
	
	

	
	
	func signIn(user: AuthUser, completion: @escaping (Result<AuthDataResult, Error>) -> Void) {
		Auth.auth().signIn(withEmail: user.emailAddress, password: user.password) { result, err in
							if let err = err {
								completion(.failure(err))
							}
							
							if let result = result {
								completion(.success(result))
							//                completion
							//                //proceed with home screen navigation
							//                let homePageVC = self.storyboard?.instantiateViewController(withIdentifier: "HomePageViewController")
							//                if let homepageVC = homePageVC {
							//                    self.navigationController?.pushViewController(homepageVC, animated: true)
							//                }
								
							}
							
						}
	}
	
	func signOut(user: AuthUser, completion: @escaping (Result<Bool, Error>) -> Void) {
		do {
				try Auth.auth().signOut()
				completion(.success(true))
			} catch (let err) {
				completion(.failure(err))
			}
	}
	
	func signUp(user: AuthUser, completion: @escaping (Result<AuthDataResult, Error>) -> Void) {
		Auth.auth().createUser(withEmail: user.emailAddress,
							   password: user.password) { authResult, err in
			
							if let err = err {
								completion(.failure(err))
								return
							}
							if let authResult = authResult {
								completion(.success(authResult))
								return
							}
					}
		
	}
	
	func updatePassword(with newPassword: String, completion: @escaping (Bool) -> Void) {
			if let firUser = Auth.auth().currentUser {
				firUser.updatePassword(to: newPassword) { err in
					if let err = err {
						Log(err.localizedDescription, .error)
						completion(false)
					} else {
						Log("updated password", .debug)
						completion(true)
					}
				}
			} else {
				completion(false)
			}
		
	}

}



