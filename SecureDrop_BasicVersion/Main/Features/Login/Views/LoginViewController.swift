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
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var errorLabel: UILabel!
	
	var viewModel: LoginBusinessLogic!

	
	override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
	func setup() {
		setUpElements()
		setupPasswordTextField()
		setupView()
		setupLoginBtn()
	}
	func setupLoginBtn() {
		self.loginButton.addTarget(self, action: #selector(didTapLoginButton), for: .touchUpInside)
	}
	func setupView() {
		(self.viewModel as! LoginViewModel).delegate = self
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
}
        
    

extension LoginViewController: LoginViewResponder {
	func showErrorLabel(with text: String) {
		self.removeLoadingIndicator()
		self.errorLabel.text = text
		self.errorLabel.isHidden = false
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
