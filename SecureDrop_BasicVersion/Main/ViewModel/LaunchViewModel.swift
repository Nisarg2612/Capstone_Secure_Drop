//
//  LaunchViewModel.swift
//  SecureDrop_BasicVersion
//
//  Created by Norris Wise Jr on 11/11/22.
//

import Foundation
import UIKit

protocol LaunchViewBusinessLogic {
	var coordinator: NavigationResponderDelegate { get }
}

class LaunchViewModel {
	var coordinator: NavigationResponderDelegate = Coordinator.shared
}
extension LaunchViewModel: LaunchViewBusinessLogic {}
