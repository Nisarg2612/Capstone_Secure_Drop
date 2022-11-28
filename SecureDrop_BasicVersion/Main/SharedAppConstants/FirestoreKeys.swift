//
//  FirestoreKeys.swift
//  SecureDrop_BasicVersion
//
//  Created by Norris Wise Jr on 11/10/22.
//

import Foundation

enum FirestoreKeys {
	case users
	case pastOrders
	case currentOrders
	case mPinInfo
	case userInfo
	
	var description: String {
		switch self {
		case .users: return "users"
		case .pastOrders: return "pastOrders"
		case .currentOrders: return "currentOrders"
		case . mPinInfo: return "pinAuthInfo"
		case .userInfo: return "userInfo"
		}
	}
}
