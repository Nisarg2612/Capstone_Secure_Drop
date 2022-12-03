//
//  DeliveryViewModel.swift
//  SecureDrop_BasicVersion
//
//  Created by Suman Chatla on 10/19/22.
//

import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import Firebase


protocol DeliveryBusinessLogic: AnyObject {
	var coordinator: NavigationResponderDelegate { get }
	func getDeliveryOwner(for firbaseUser: User, completion: @escaping (DeliveryOwner?) -> Void)
	func makeNewDeliveryOrder(deliveryPin: String, orderID: String, orderDetails: String, vendorDetails: String) -> DeliveryOrder
	func makeNewDeliveryOwner(firebaseUser: User, pinAuthInfo: PinAuthInfo) -> DeliveryOwner
	func addNewDeliveryOwnerToDatabase(_ deliveryOwner: DeliveryOwner, completion: @escaping (Result<Bool, Error>)->Void)
	func updateDeliveryOrder(_ deliveryOrder: DeliveryOrder, for deliveryOwner: DeliveryOwner, skipModification: Bool, completion: @escaping (Result<Bool, Error>) -> Void)
	func moveToPastDeliveryOrders(_ deliveryOrder: DeliveryOrder, for deliveryOwner: DeliveryOwner, completion: @escaping (Result<Bool, Error>) -> Void )
	func updateMPin(deliveryOwner: DeliveryOwner, completion: @escaping (Result<Bool, Error>) -> Void)
	func addNewOrderToDatabase(deliveryOrder: DeliveryOrder, for deliveryOwner: DeliveryOwner, completion: @escaping (Result<Bool, Error>) -> Void)
	//TODO: Add delete order wrapper function for currentOrders and pastOrders
}


class DeliveryViewModel {
	var coordinator: NavigationResponderDelegate = Coordinator.shared	
}

extension DeliveryViewModel: DeliveryBusinessLogic {
    

	func makeNewDeliveryOrder(deliveryPin: String, orderID: String, orderDetails: String, vendorDetails: String) -> DeliveryOrder {
		return DeliveryOrder(deliveryPin: deliveryPin, orderID: orderID, orderDetails: orderDetails, vendorDetails: vendorDetails)
	}
    
    func addNewDeliveryOwnerToDatabase(_ deliveryOwner: DeliveryOwner, completion: @escaping (Result<Bool, Error>) -> Void) {
        let result: Result<Bool, Error>
        guard let username = deliveryOwner.user else {
                    result = .failure(DeliveryLogicNetworkError.missingUsername)
                    completion(result)
                    return
                }
        guard let encodedOwner = try? JSONEncoder().encode(deliveryOwner),
                     let ownerDict = try? JSONSerialization.jsonObject(with: encodedOwner) as? [String: Any] else {
                   completion(.failure(DeliveryLogicNetworkError.encodingError))
                   return
               }
               Log(ownerDict, .debug)
               
               let db = Firestore.firestore()
               db.collection(FirestoreKeys.users.description).document(username).setData([
                   FirestoreKeys.userInfo.description: ownerDict
               ]) { err in
                   if let err = err {
                       Log(err.localizedDescription, .error)
                       completion(.failure(err))
                   } else {
                       completion(.success(true))
                       Log("Added new delivery. New Object: \(ownerDict)", .debug)
                   }
               }
    }
	
	func getDeliveryOwner(for firbaseUser: User, completion: @escaping (DeliveryOwner?) -> Void) {
		guard let email = firbaseUser.email else {
			completion(nil)
			return
		}
		let db = Firestore.firestore()
		let docRef = db.collection(FirestoreKeys.users.description).document(email)
		docRef.getDocument { docSnapshot, err in
			
			if let dataDict = docSnapshot?.data(),
			   let deliveryOwnerDict = dataDict[FirestoreKeys.userInfo.description] as? [String: Any],
			   let data = try? JSONSerialization.data(withJSONObject: deliveryOwnerDict),
			   let deliveryOwner = try? JSONDecoder().decode(DeliveryOwner.self, from: data) {
				completion(deliveryOwner)
			} else {
				completion(nil)
			}
		}
	}
    func makeNewDeliveryOwner(firebaseUser: User, pinAuthInfo: PinAuthInfo) -> DeliveryOwner {
        let email = firebaseUser.email
		let deliveryOwner = DeliveryOwner(user: email, pinAuthInfo: pinAuthInfo, pastOrders: [], currentOrders: [])
		return deliveryOwner
	}
    func addNewOrderToDatabase(deliveryOrder: DeliveryOrder, for deliveryOwner: DeliveryOwner, completion: @escaping (Result<Bool, Error>) -> Void) {
        let result: Result<Bool, Error>
        var deliveryOwner = deliveryOwner
        deliveryOwner.currentOrders?.append(deliveryOrder)
        guard let username = deliveryOwner.user else {
            result = .failure(DeliveryLogicNetworkError.missingUsername)
            completion(result)
            return
        }
        guard let encodedOwner = try? JSONEncoder().encode(deliveryOwner),
              let ownerDict = try? JSONSerialization.jsonObject(with: encodedOwner) as? [String: Any] else {
            completion(.failure(DeliveryLogicNetworkError.encodingError))
            return
        }
        Log(ownerDict, .debug)
        
        let db = Firestore.firestore()
        db.collection(FirestoreKeys.users.description).document(username).setData([
            FirestoreKeys.userInfo.description: ownerDict
        ]) { err in
            if let err = err {
                Log(err.localizedDescription, .error)
                completion(.failure(err))
            } else {
                completion(.success(true))
                Log("Added new delivery. New Object: \(ownerDict)", .debug)
            }
        }
    }
    func updateMPin(deliveryOwner: DeliveryOwner, completion: @escaping (Result<Bool, Error>) -> Void) {
            let result: Result<Bool, Error>
            guard let username = deliveryOwner.user else {
                result = .failure(DeliveryLogicNetworkError.missingUsername)
				completion(result)
                return
            }
            guard let _ = deliveryOwner.pinAuthInfo,
                  let ownerData = try? JSONEncoder().encode(deliveryOwner),
            let ownerDict = try? JSONSerialization.jsonObject(with: ownerData) as? [String: Any] else {
                result = .failure(DeliveryLogicNetworkError.missingMPIN)
                return completion(result)
            }
            let db = Firestore.firestore()
            db.collection(FirestoreKeys.users.description).document(username).updateData([FirestoreKeys.userInfo.description: ownerDict]) { err in
                guard err == nil else {
					Log("ERROR FROM FIREBASE: \(err?.localizedDescription ?? "")", .error)
					return
				}
                
                completion(.success(true))
            }
        }
    func updateDeliveryOrder(_ deliveryOrder: DeliveryOrder, for deliveryOwner: DeliveryOwner, skipModification: Bool, completion: @escaping (Result<Bool, Error>) -> Void) {
        let db = Firestore.firestore()
        guard let username = deliveryOwner.user else {
            Log("Username is nil.")
            return
        }
        if !skipModification {
            var deliveryOwner = deliveryOwner
                    if var currentOrders = deliveryOwner.currentOrders, currentOrders.contains(where: { $0.orderID == deliveryOrder.orderID }) {
                        currentOrders.removeAll(where: { $0.orderID == deliveryOrder.orderID })
                        currentOrders.append(deliveryOrder)
                        deliveryOwner.currentOrders = currentOrders
                    } else if var pastOrders = deliveryOwner.pastOrders,  pastOrders.contains(where: { $0.orderID == deliveryOrder.orderID  }) {
                        pastOrders.removeAll(where: { $0.orderID == deliveryOrder.orderID })
                        pastOrders.append(deliveryOrder)
                        deliveryOwner.pastOrders = pastOrders
                    }
                    
                    
        }
        guard let encodedOwner = try? JSONEncoder().encode(deliveryOwner),
              let ownerDict = try? JSONSerialization.jsonObject(with: encodedOwner) as? [String: Any]
                else {
                        Log("Error: Cannot encode delivery owner")
                        return
                }
        db.collection(FirestoreKeys.users.description).document(username).updateData(
            [FirestoreKeys.userInfo.description: ownerDict]) { error in
                if let err = error {
                    Log("Error: cannot update Firestore -- \(err.localizedDescription)")
                }
            }
    }
    func moveToPastDeliveryOrders(_ deliveryOrder: DeliveryOrder, for deliveryOwner: DeliveryOwner, completion: @escaping (Result<Bool, Error>) -> Void ) {
        var deliveryOwner = deliveryOwner
        let deliveryOrder = deliveryOrder
        
        guard let user = deliveryOwner.user else {
            completion(.failure(DeliveryLogicNetworkError.missingUsername))
            return
        }
        guard var currentOrders = deliveryOwner.currentOrders else {
            //current Orders do not exist
            completion(.failure(DeliveryLogicNetworkError.missingOrder("Missing Current Orders Array for user: \(user)")))
            return
        }
        guard var pastOrders = deliveryOwner.pastOrders else {
            //past orders do not exist
            completion(.failure(DeliveryLogicNetworkError.missingOrder("Missing Current Orders Array for user: \(user)")))
            return
        }
        currentOrders.removeAll(where: { $0.orderID == deliveryOrder.orderID })
        pastOrders.append(deliveryOrder)
        deliveryOwner.currentOrders = currentOrders
        deliveryOwner.pastOrders = pastOrders
        self.updateDeliveryOrder(deliveryOrder, for: deliveryOwner, skipModification: true) {  result in
            switch result {
            case .success(let bool): completion(.success(bool))
            case .failure(let err): completion(.failure(err))
            }
        }
        
    }
}

enum DeliveryLogicNetworkError: Error {
    case encodingError
    case missingUsername
    case missingMPIN
	case missingDeliveryOwner
    case missingOrder(String)
    var description: String {
        switch self {
        case .missingUsername: return "Username is either missing or unparsable."
			case .missingDeliveryOwner: return "Missing Delivery Owner"
        case .missingMPIN: return "Missing MPIN auth info."
        case .encodingError: return "Error encoding object"
        case .missingOrder(let description): return "Missing order for update. Error: \(description)"
        }
    }
}
