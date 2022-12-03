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
	func showChangeMPINViewController()
	func showChangePasswordViewController()
}
class SetDeliveryPinViewController: UIViewController, Storyboarded {
	var viewModel: DeliveryPinViewModelProtocol!
	var bottomSheetVC: PresentedViewController?
	
    @IBOutlet weak var generateDeliveryPinBtn: UIButton!
    @IBOutlet weak var mpinLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
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
		self.viewModel.delivery.getDeliveryOwner(for: firUser) { [weak self] deliveryOwner in
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
	
	func setupMenuNavigationItem() {
		let customProfileBtn = UIButton()
		customProfileBtn.setTitle("Profile", for: .normal)
		customProfileBtn.setImage(UIImage(systemName: "menucard"), for: .normal)
		customProfileBtn.setTitleColor(.systemBlue, for: .normal)
		let contextMenuInteraction = UIContextMenuInteraction(delegate: self)
		customProfileBtn.addInteraction(contextMenuInteraction)
		let customBarBtnView = UIView(frame: .zero)
		customBarBtnView.addSubview(customProfileBtn)
		customProfileBtn.semanticContentAttribute = .forceLeftToRight
		customProfileBtn.anchor(top: customBarBtnView.topAnchor, right: customBarBtnView.trailingAnchor, bottom: customBarBtnView.bottomAnchor, left: customBarBtnView.leadingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -10), size: .zero)
		let rightNavBarBtn =  UIBarButtonItem()
		rightNavBarBtn.customView = customBarBtnView
		
		self.navigationItem.rightBarButtonItem = rightNavBarBtn
	}
	func layoutView() {
		self.navigationItem.setHidesBackButton(true, animated: true)
	}
    func setup() {
		addKeyboardNotifications()
        setupGenerateDeliveryPinBtn()
        setupUsernameLabel()
        setupMPINLable()
		setupMenuNavigationItem()
		layoutView()
    }
    func setupMPINLable() {
		var mPin = "????"
		guard let firUser = Auth.auth().currentUser else {
			self.mpinLabel.text = mPin
			return
		}
		viewModel?.delivery.getDeliveryOwner(for: firUser) { deliveryOwner in
			mPin = deliveryOwner?.pinAuthInfo?.mPin ?? "\(mPin)"
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

	func addKeyboardNotifications() {
		NotificationCenter.default.addObserver(self, selector: #selector(showKeyboard), name: UIResponder.keyboardWillShowNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(hideKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
	}
	
	
    @objc func setupGenerateDeliveryPinBtn() {
        self.generateDeliveryPinBtn.addTarget(self, action: #selector(didTapGenerateDeliveryPin), for: .touchUpInside)
    }
    @objc func didTapGenerateDeliveryPin(sender: UIButton) {
		let showDeliveryPinVC = ShowDeliveryOrderViewController.instantiate() as ShowDeliveryOrderViewController
		showDeliveryPinVC.viewModel = ShowDeliveryOrderViewModel(deliveryViewModel: DeliveryViewModel())
        self.viewModel.coordinator.pushView(showDeliveryPinVC)
    }
	@objc func showKeyboard(notificaiton: Notification) {
		guard let bottomSheetVC = bottomSheetVC else { return }
		let endFrame = (notificaiton.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
		UIView.animate(withDuration: 1.0) {
			bottomSheetVC.view.bounds.origin.y += endFrame.height
		}
	}
	@objc func hideKeyboard(notificaiton: Notification) {
		guard let bottomSheetVC = bottomSheetVC else { return }
		UIView.animate(withDuration: 1.0) {
			bottomSheetVC.view.bounds.origin.y = 0
		}
	}
}
extension SetDeliveryPinViewController: SetDeliveryPinViewResponder {
	func showChangeMPINViewController() {
		Log("\(#function)", .debug)
		//TODO: - Create & Launch MPINChangeViewController()
		let mPINChangeView = ChangeCredentialView(viewType: .MPIN)
		mPINChangeView.delegate = self
		let mPINChangeBottomSheetVC = PresentedViewController(bottomSheetView: mPINChangeView, shouldDismissWithTap: true, bottomMargin: 0)
		self.bottomSheetVC = mPINChangeBottomSheetVC
		self.viewModel.coordinator.presentView(mPINChangeBottomSheetVC, completion: nil)
	}
	
	func showChangePasswordViewController() {
			//TODO: - Create & Launch ChangePasswordViewController()
			let mChangePasswordView = ChangeCredentialView(viewType: .password)
		mChangePasswordView.delegate = self
			let passwordChangeBottomSheetVC = PresentedViewController(bottomSheetView: mChangePasswordView, shouldDismissWithTap: true, bottomMargin: 0)
			self.bottomSheetVC = passwordChangeBottomSheetVC
			self.viewModel.coordinator.presentView(passwordChangeBottomSheetVC, completion: nil)
	}
	
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

extension SetDeliveryPinViewController: CredentialViewDelegate {
	
	func didTapSubmitBtn(for viewType: CredentialViewType, newCredential: String) {
		self.view.isUserInteractionEnabled = false
		guard let bottomSheetVC = bottomSheetVC else {
			Log("SILENT FAILURE, NO bottomSheetView present", .error)
			return
		}
		self.addLoadingIndicator(toView: bottomSheetVC.view, color: .white)
		switch viewType {
			case .password:
				self.viewModel.updatePassword(with: newCredential) { didUpdate in
					if didUpdate {
						let alertView = self.makeAlertVC(title: "Success", message: "Updated Password to: \(newCredential)") {
							self.bottomSheetVC?.dismiss(animated: true)
						}
						self.removeLoadingIndicator()
						self.view.isUserInteractionEnabled = true
						self.viewModel.coordinator.presentView(alertView)
					} else {
						self.removeLoadingIndicator()
						self.view.isUserInteractionEnabled = true
						self.showError(title: "Uh Oh", message: "Sorry, we could not update your Password at this time")
						  }
				}
				break
				
			case .MPIN:
				guard let firUser = Auth.auth().currentUser else {
					self.removeLoadingIndicator()
					self.view.isUserInteractionEnabled = true
					self.showError(title: "Error", message: "Missing Firebase User. Please log out & log back in. Thanks!")
					return
				}
				
				self.viewModel.updateMPin(firUser: firUser, newMPIN: newCredential) { [unowned self] result in
					switch result {
						case .success(let didUpdate):
							if didUpdate {
								
								let alertView = self.makeAlertVC(title: "Success", message: "Updated MPIN to: \(newCredential)") {
									self.bottomSheetVC?.dismiss(animated: true)
									self.setupMPINLable()
								}
								self.removeLoadingIndicator()
								self.view.isUserInteractionEnabled = true
								self.viewModel.coordinator.presentView(alertView)
							} else {
								self.removeLoadingIndicator()
								self.view.isUserInteractionEnabled = true
								self.showError(title: "Uh Oh", message: "Sorry, we could not update your MPIN at this time")
							}
							
							break
						case .failure(let err):
							self.removeLoadingIndicator()
							self.view.isUserInteractionEnabled = true
							self.showError(title: "Error", message: err.localizedDescription)
							break
					}
				}
				break
		}
	}
	
	
}
extension SetDeliveryPinViewController: UIContextMenuInteractionDelegate {
	func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
		return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { suggestedActions in
			
				let historyAction = UIAction(
					title: NSLocalizedString("History", comment:""),
					image: UIImage(systemName:"list.bullet")) { historyAction in
					//TODO: Launch history view controller
						print("Launch history view controller")
						//get delivery owner
						self.viewModel.delivery.getDeliveryOwner(for: Auth.auth().currentUser!) { [weak self] deliveryOwner in
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
				let mpinChangeAction = UIAction(
					title: NSLocalizedString("MPIN Change", comment:""),
					image: UIImage(systemName: "pencil")) { [unowned self] historyAction in
					//TODO: Launch MPINChange ViewController
						print("Launch MPINChange ViewController")
						self.showChangeMPINViewController()
				}
				let passwordChangeAction = UIAction(
					title: NSLocalizedString("Password Change", comment:""),
					image: UIImage(systemName: "key")) {[unowned self] historyAction in
					//TODO: Launch Password Change View Controller
						print("Launch Password Change View Controller")
						self.showChangePasswordViewController()
				}
				let logoutAction = UIAction(
					title: NSLocalizedString("Log Out", comment:""),
					image: UIImage(systemName: "door.right.hand.open")) { historyAction in
					//TODO: Launch LogOut View Controller
						print("Launch LogOut View Controller")
						if let launchVC = self.viewModel.coordinator.getView(LaunchViewController.self) {
							self.viewModel.coordinator.popToView(launchVC)
						} else {
							_ = try? Auth.auth().signOut()
							let launchVC = LaunchViewController.instantiate() as LaunchViewController
							self.viewModel.coordinator.popToView(launchVC)
						}
				}
				let contextMenu = UIMenu(title: "Profile Menu", children: [historyAction, mpinChangeAction, passwordChangeAction, logoutAction])
			return contextMenu
		}
	}
}
