//
//  StoryboardProtocol.swift
//  SecureDrop_BasicVersion
//
//  Created by Norris Wise Jr on 11/11/22.
//

import Foundation
import UIKit

protocol Storyboarded: UIViewController {
}

extension Storyboarded {
	static func instantiate<Type>() -> Type {
		let identifier = String(describing: Type.self)
		guard let vc = UIStoryboard(name: "Main", bundle: .main)
			.instantiateViewController(withIdentifier: identifier) as? Type else {
			fatalError("Please instantiate the `Storyboarded` viewController with the same name as the Type of the View Controller")
		}
		return vc
	}
}
