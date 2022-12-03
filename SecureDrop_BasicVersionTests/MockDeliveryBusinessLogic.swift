//
//  MockDeliveryBusinessLogic.swift
//  SecureDrop_BasicVersionTests
//
//  Created by Suman Chatla on 10/25/22.
//

import Foundation
import Firebase

@testable import SecureDrop_BasicVersion


//class MockDeliveryBusinessLogic: DeliveryBusinessLogic {
//    func updateMPin(deliveryOwner: SecureDrop_BasicVersion.DeliveryOwner, completion: @escaping (Result<Bool, Error>) -> Void) {
//        
//        let result: Result<Bool, Error>
//        guard let username = deliveryOwner.user else {
//            result = .failure(DeliveryLogicNetworkError.missingUsername)
//            return completion(result)
//        }
//        guard let mPinAuthInfo = deliveryOwner.pinAuthInfo else {
//            result = .failure(DeliveryLogicNetworkError.missingMPIN)
//            return completion(result)
//        }
//        let db = Firestore.firestore()
//        db.collection(FirestoreKeys.users.description).document(username).updateData([FirestoreKeys.mPinInfo.description: mPinAuthInfo]) { err in
//            guard err != nil else { return }
//            print("ERROR FROM FIREBASE: \(err?.localizedDescription ?? "")")
//        }
//    
//    }
//    
//    func addNewOrderToDatabase(deliveryOwner: SecureDrop_BasicVersion.DeliveryOwner, completion: @escaping (Result<Bool, Error>) -> Void) {
//        
//        let result: Result<Bool, Error>
//        guard let username = deliveryOwner.user else {
//            result = .failure(DeliveryLogicNetworkError.missingUsername)
//            completion(result)
//            return
//        }
//        guard let encodedOwner = try? JSONEncoder().encode(deliveryOwner),
//              let ownerDict = try? JSONSerialization.jsonObject(with: encodedOwner) as? [String: Any] else {
//            completion(.failure(DeliveryLogicNetworkError.encodingError))
//            return
//        }
//        Log("Mock Log: created encodedOwner", .debug)
//        Thread.sleep(until: .now + 3.0)
//// -- Skip firebase call --
////        let db = Firestore.firestore()
////        db.collection(FirestoreKeys.users.description).document(username).setData([
////            FirestoreKeys.userInfo.description: FieldValue.arrayUnion([ownerDict])
////        ]) { err in
////            if let err = err {
////                Log(err.localizedDescription, .error)
////                completion(.failure(err))
////            } else {
////                completion(.success(true))
////                Log("Added new delivery. New Object: \(ownerDict)", .debug)
////            }
////        }
//            completion(.success(true))
//    
//    }
//    
//    
//}
