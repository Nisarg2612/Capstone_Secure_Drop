//
//  SetDeliveryPinViewController.swift
//  SecureDrop_BasicVersion
//
//  Created by Suman Chatla on 10/14/22.
//

import Foundation
import UIKit
import Firebase

protocol SetDeliveryPinViewResponder {
	func showError(title: String, message: String)
	func showLaunchViewController()
	func showHistoryViewController(for deliveryOwner: DeliveryOwner)
}
class SetDeliveryPinViewController: UIViewController, Storyboarded {
	var viewModel: DeliveryBusinessLogic!
    @IBOutlet weak var generateDeliveryPinBtn: UIButton!
    @IBOutlet weak var mpinLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
	func didTapPasswordChangeBarButtonItem() {
		Log("didTap: \(#function)", .debug)
		//TODO: - Create & Launch PasswordChangeViewController()
		
	}
	func didTapMPINChangeBarButtonItem() {
		Log("didTap: \(#function)", .debug)
		//TODO: - Create & Launch MPINChangeViewController()
	}
	func didTapHistoryBarButtonItem() {
		Log("didTap: \(#function)", .debug)
		
			//check for firAuthUser
			guard let firUser = Auth.auth().currentUser else {
				let alertVC = self.makeAlertVC(title: "Error", message: "It looks like your session has timed out. Please log back in.\nThanks!")
				self.viewModel.coordinator.presentView(alertVC) {
					self.showLaunchViewController()
				}
				return
			}
		
			//get delivery owner
			self.viewModel.getDeliveryOwner(for: firUser) { [weak self] deliveryOwner in
				guard let deliveryOwner = deliveryOwner else {
					DispatchQueue.main.async {
						//if deliveryOwner missing, show error
						self?.showError(title: "Error", message: "Missing Delivery Owner")
					}
					return
				}
				DispatchQueue.main.async {
					//if deliveryOwner retreived, move to historyVC
					self?.showHistoryViewController(for: deliveryOwner)
				}
			}
	}
	
	func setupHistoryNavigationItem() {
		let historyAction = UIAction(
			title: NSLocalizedString("History", comment:""),
			image: UIImage(systemName:"arrow.up.square")) { historyAction in
			//TODO: Launch history view controller
				print("Launch history view controller")
		}
		let mpinChangeAction = UIAction(
			title: NSLocalizedString("MPIN Change", comment:""),
			image: UIImage(systemName: "arrow.down.square")) { historyAction in
			//TODO: Launch MPINChange ViewController
				print("Launch MPINChange ViewController")
		}
		let passwordChangeAction = UIAction(
			title: NSLocalizedString("Password Change", comment:""),
			image: UIImage(systemName: "arrow.up.square")) { historyAction in
			//TODO: Launch Password Change View Controller
				print("Launch Password Change View Controller")
		}
		let logoutAction = UIAction(
			title: NSLocalizedString("Log Out", comment:""),
			image: UIImage(systemName: "arrow.down.square")) { historyAction in
			//TODO: Launch LogOut View Controller
				print("Launch LogOut View Controller")
		}
		let contextMenu = UIMenu(title: "Menu", children: [historyAction, mpinChangeAction, passwordChangeAction, logoutAction])
		let rightNavBarBtn =  UIBarButtonItem(title: "Menu", menu: contextMenu)
		self.navigationItem.rightBarButtonItem = rightNavBarBtn
	}
    func setup() {
        setupGenerateDeliveryPinBtn()
        setupUsernameLabel()
        setupMPINLable()
		setupHistoryNavigationItem()
    }
    func setupMPINLable() {
		var mPin = "????"
		guard let firUser = Auth.auth().currentUser else {
			self.mpinLabel.text = mPin
			return
		}
		viewModel?.getDeliveryOwner(for: firUser) { deliveryOwner in
			mPin = deliveryOwner?.pinAuthInfo?.mPin?.toString ?? "\(mPin)"
			self.mpinLabel.text = mPin
		}
        
    }
    func setupUsernameLabel() {
        if let userEmail = try? Auth.auth().getStoredUser(forAccessGroup: nil)?.email {
            self.usernameLabel.text = "Welcome \(userEmail)!"
        } else {
            self.usernameLabel.text = "Welcome!"
        }
    }

    @objc func setupGenerateDeliveryPinBtn() {
        self.generateDeliveryPinBtn.addTarget(self, action: #selector(didTapGenerateDeliveryPin), for: .touchUpInside)
    }
    @objc func didTapGenerateDeliveryPin(sender: UIButton) {
		let showDeliveryPinVC = ShowDeliveryOrderViewController.instantiate() as ShowDeliveryOrderViewController
		showDeliveryPinVC.viewModel = ShowDeliveryOrderViewModel(deliveryViewModel: DeliveryViewModel())
        self.viewModel.coordinator.pushView(showDeliveryPinVC)
    }
}
extension SetDeliveryPinViewController: SetDeliveryPinViewResponder {
	func showHistoryViewController(for deliveryOwner: DeliveryOwner) {
		let historyVC = self.viewModel.coordinator.getView(HistoryViewController.self) ?? HistoryViewController()
		historyVC.configure(historyViewModel: HistoryViewModel(deliveryOwner: deliveryOwner))
		self.viewModel.coordinator.pushView(historyVC)
	}
	
	func showError(title: String, message: String) {
		let alertVC = self.makeAlertVC(title: title, message: message)
		self.viewModel.coordinator.presentView(alertVC)
	}
	
	func showLaunchViewController() {
		let launchVC = self.viewModel.coordinator.getView(LaunchViewController.self)!
		self.viewModel.coordinator.popView(launchVC)
	}
}
