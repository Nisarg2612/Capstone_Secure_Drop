//
//  DeliveryBusinessLogicTest.swift
//  SecureDrop_BasicVersionTests
//
//  Created by Suman Chatla on 10/25/22.
//

import Foundation
import XCTest
import Firebase


@testable import SecureDrop_BasicVersion


class DeliveryBusinessLogicTest: XCTestCase {
    
    override func setUpWithError() throws {
       FirebaseApp.configure()
    }
    let sut = MockDeliveryBusinessLogic()
    func test_addNewOrder_To_Firestore_Database() {
        //build delivery order for currentOrders array
		let deliveryOrder = DeliveryOrder(deliveryPin: "5678", orderID: "AIDJRF8F6DHDIFF4", orderDetails: "Custom order details for this order", vendorDetails: "wekdklewmdlwekd")
        //build delivery order for addOrder call, add, modify or update orderes
        let username = TestableFirebaseConst.username.description
        let deliveryOwner = DeliveryOwner(user: username, pinAuthInfo: PinAuthInfo(mPin: "1234"), pastOrders: [], currentOrders: [deliveryOrder])
        
        let deliveryExpectation = XCTestExpectation(description: "Should add a new order to the firebase database, and return with acknowledgement")
        deliveryExpectation.expectedFulfillmentCount = 1
        deliveryExpectation.assertForOverFulfill = true
        sut.addNewOrderToDatabase(deliveryOwner: deliveryOwner) { result in
            guard let didAdd = try? result.get(), didAdd  else {
                var assertDescription = "Failed To add item to Firestore Database"
                switch result {
                case .failure(let err):
                    assertDescription += "Error: \(err.localizedDescription)"
                default: break
                }
                XCTFail(assertDescription)
                return
            }
            deliveryExpectation.fulfill()
        }
        wait(for: [deliveryExpectation], timeout: TimeInterval(5.0))
    }
    func test_update_MPIN() {
        
    }
    
}




