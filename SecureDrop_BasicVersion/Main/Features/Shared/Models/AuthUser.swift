//
//  AuthUser.swift
//  SecureDrop_BasicVersion
//
//  Created by Norris Wise Jr on 11/11/22.
//

import Foundation

struct AuthUser: Codable {
		var fullName: String?
		var emailAddress: String
		var password: String
	
	func isValid(prop: UserPropType) -> Bool {
		return prop.isValid
	}
	func validationErrMsg(for prop: UserPropType) -> String {
		return prop.validationError
	}
	
}

enum UserPropType {
	
	case fullName(String?)
	case emailAddress(String)
	case password(String)
	
	var description: String {
		switch self {
		case .emailAddress(let email): return email
		case .fullName(let fullName): return fullName ?? ""
		case .password(let password): return password
		}
	}
	var isValid: Bool {
		validate(self)
	}
	private func validate(_ field: Self) -> Bool {
		switch self {
			case .fullName:
			return true
			case .emailAddress:
			return CustomUtilities.isEmailValid(field.description)
			case .password:
			return CustomUtilities.isPasswordValid(field.description)
		}
	}
	
	var validationError: String {
		switch self {
			case .emailAddress(_): return "Please enter a valid email address"
			case .password(_): return "Please enter a valid password"
			case .fullName(_): return "Please enter your full name"
		}
	}
	
	
	
	
}
