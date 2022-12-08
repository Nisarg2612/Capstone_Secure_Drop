//
//  LoginViewController.swift
//  SecureDrop_BasicVersion
//
//  Created by Suman Chatla on 9/22/22.
//

import UIKit
import Firebase

protocol LoginViewResponder {
	func showErrorLabel(with text: String)
	func showSetMPinViewController()
	func showSetDeliveryPinViewController()
}

class LoginViewController: UIViewController, Storyboarded {
	@IBOutlet var fieldStackView: UIStackView!
	@IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var errorLabel: UILabel!
	var resetPasswordLabel: UILabel!
	
	var viewModel: LoginBusinessLogic!
	var bottomSheetVC: PresentedViewController!

	
	override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
	func addKeyboardNotifications() {
		NotificationCenter.default.addObserver(self, selector: #selector(showKeyboard), name: UIResponder.keyboardWillShowNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(hideKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
	}
	func setup() {
		setUpElements()
		setupPasswordTextField()
		setupView()
		setupLoginBtn()
		setupResetPasswordLabel()
		addKeyboardNotifications()
	}
	func setupLoginBtn() {
		self.loginButton.addTarget(self, action: #selector(didTapLoginButton), for: .touchUpInside)
	}
	func setupView() {
		(self.viewModel as! LoginViewModel).delegate = self
	}
	func setupResetPasswordLabel() {
		resetPasswordLabel = UILabel(frame: .zero)
		fieldStackView.addArrangedSubview(resetPasswordLabel)
		
		let resetText = "Reset Password"
//		resetPasswordLabel.text = resetText
		var attrs: [NSAttributedString.Key: Any] = [:]
		attrs[NSAttributedString.Key.underlineStyle] = NSUnderlineStyle.single
		attrs[NSAttributedString.Key.underlineColor] = UIColor.black
		attrs[NSAttributedString.Key.underlineStyle] = NSUnderlineStyle.single
		attrs[NSAttributedString.Key.foregroundColor] = UIColor.systemBlue
		let attrString = NSMutableAttributedString(string: resetText)
		attrString.setAttributes(attrs, range: (resetText as NSString).range(of: resetText))
		resetPasswordLabel.attributedText = attrString
		let tapGesture = UITapGestureRecognizer()
		tapGesture.numberOfTapsRequired = 1
		tapGesture.numberOfTouchesRequired = 1
		tapGesture.addTarget(self, action: #selector(didTapResetPassword))
		resetPasswordLabel.addGestureRecognizer(tapGesture)
		resetPasswordLabel.textAlignment = .right
		resetPasswordLabel.isUserInteractionEnabled = true
	}
    func setupPasswordTextField() {
        self.passwordTextField.isSecureTextEntry = true
    }
    func setUpElements() {
        errorLabel.isHidden = true
        errorLabel.textAlignment = .center
        CustomUtilities.styleTextField(emailTextField)
        CustomUtilities.styleTextField(passwordTextField)
        CustomUtilities.styleFilledButton(loginButton)
    }
	func addSubviews() {
		
	}

	func showViewControllerHelper(_ vc: UIViewController) {
		if self.definesPresentationContext, self.navigationController != nil {
			self.viewModel.coordinator.pushView(vc)
		} else {
			self.viewModel.coordinator.dismissPresentedView {
				self.viewModel.coordinator.pushView(vc)
			}
		}
	}
     
    @IBAction func didTapCreateAccount(_ sender: UIButton) {
        if self.definesPresentationContext {
			let signUpVC = SignUpViewController.instantiate() as SignUpViewController
			signUpVC.viewModel = SignUpViewModel(authBusinessLogic: AuthViewModel(), deliveryBusinessLogic: DeliveryViewModel())
            self.viewModel.coordinator.presentView(signUpVC)
        } else {
			self.viewModel.coordinator.dismiss(self)
        }
        
    }
    
    @objc func didTapLoginButton(_ sender: UIButton) {
		
        self.errorLabel.isHidden = true
        guard let emailAddress = self.emailTextField.text, emailAddress != "",
              let password = self.passwordTextField.text, password != "" else {
			self.showErrorLabel(with: "Please enter email and password")
			Log("Please enter email and password", .error)
            return
        }
        self.addLoadingIndicator()
		self.viewModel?.signIn(authUser: AuthUser(emailAddress: emailAddress, password: password))
    }
	@objc func didTapResetPassword() {
		let passwordResetBottomSheet = ChangeCredentialView(viewType: .resetPasswordViaEmail)
		passwordResetBottomSheet.delegate = self
		
		let resetPasswordVC = PresentedViewController(bottomSheetView: passwordResetBottomSheet, shouldDismissWithTap: true, bottomMargin: 0)
		self.bottomSheetVC = resetPasswordVC
		self.viewModel.coordinator.presentView(resetPasswordVC)
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
        
    

extension LoginViewController: LoginViewResponder {
	func showErrorLabel(with text: String) {
		self.removeLoadingIndicator()
		self.errorLabel.text = text
		self.errorLabel.isHidden = false
		self.bottomSheetVC.dismiss(animated: true)
	}
	
	func showSetMPinViewController() {
		self.removeLoadingIndicator()
		let mPinVC = SetMPinViewController.instantiate() as SetMPinViewController
			mPinVC.viewModel = MPinViewModel(deliveryViewModel: DeliveryViewModel())
			self.showViewControllerHelper(mPinVC)
	}
	
	func showSetDeliveryPinViewController() {
		self.removeLoadingIndicator()
		let setDeliveryPinVC = SetDeliveryPinViewController.instantiate() as SetDeliveryPinViewController
			setDeliveryPinVC.viewModel = DeliveryPinViewModel()
		self.showViewControllerHelper(setDeliveryPinVC)
	}
}

extension LoginViewController: CredentialViewDelegate {
	func didTapSubmitBtn(for viewType: CredentialViewType, newCredential: String) {
		self.view.isUserInteractionEnabled = false
		self.addLoadingIndicator(toView: self.bottomSheetVC.view, color: .white)
		switch viewType {
			case .resetPasswordViaEmail:
				self.viewModel.resetPassword(for: newCredential) { err in
					if let err = err {
						self.bottomSheetVC.dismiss(animated: true) {
							self.showErrorLabel(with: err.localizedDescription)
							self.view.isUserInteractionEnabled = true
							self.removeLoadingIndicator(from: self.bottomSheetVC.view)
						}
					} else {
						let confirmPasswordResetAlertVC = self.makeAlertVC(title: "Sent!", message: "Please check your email account for a reset password email.") {
							self.bottomSheetVC.dismiss(animated: true)
						}
						self.viewModel.coordinator.presentView(confirmPasswordResetAlertVC) {
							self.view.isUserInteractionEnabled = true
							self.removeLoadingIndicator(from: self.bottomSheetVC.view)
						}
					}
				}
				break
			default:
				Log("Should not exec from: \(#function). Please review.", .error)
				self.showErrorLabel(with: "Please contact administrator.")
				self.view.isUserInteractionEnabled = true
				self.removeLoadingIndicator(from: self.bottomSheetVC.view)
				self.bottomSheetVC.dismiss(animated: true)
				return
		}
	}
	
	
}
