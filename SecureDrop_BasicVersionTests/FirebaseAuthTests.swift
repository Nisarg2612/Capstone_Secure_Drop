//
//  FirebaseAuthTests.swift
//  SecureDrop_BasicVersionTests
//
//  Created by Suman Chatla on 10/25/22.
//

import Foundation
import XCTest
import Firebase

enum TestableFirebaseConst {
    case username
    var description: String {
        switch self {
            case .username: return "tester1@gmail.com"
        }
    }
}

@testable import SecureDrop_BasicVersion

class FirebaseAuthTests: XCTestCase {
//    static let shared = FirebaseAuthTests()
    
    func signIn() {
        
        let signInExpectation = XCTestExpectation(description: "Sign-In to Firebase")
        signInExpectation.expectedFulfillmentCount = 1
        signInExpectation.assertForOverFulfill = true
        FirebaseApp.configure()
        Auth.auth().signIn(withEmail: "tester1@gmail.com", password: "123456") { result, err in
            
            if let err = err {
                Log(err.localizedDescription, .testing)
                XCTFail("Failed to login to firebase")
            }
            signInExpectation.fulfill()
        }
        wait(for: [signInExpectation], timeout: TimeInterval(5.0))
    
    }
    func test_setup_Firebase_And_SignIn() {
        signIn()
    }
}
