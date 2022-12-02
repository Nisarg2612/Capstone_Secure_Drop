//
//  SignupViewController.swift
//  SecureDrop_BasicVersion
//
//  Created by Suman Chatla on 9/22/22.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController, Storyboarded {
	
	var viewModel: SignUpViewModel!
    
    
	@IBOutlet var fullNameTextField: UITextField!
	
	@IBOutlet var emailTextField:UITextField!
	
	@IBOutlet var passwordTextField: UITextField!
	
	
	@IBOutlet var confirmPasswordTextField: UITextField!
	@IBOutlet var signUpButton: UIButton!
	@IBOutlet var errorLabel: UILabel!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setup()
	}
	func setup() {
		setUpElements()
		setupSignUpBtn()
		setupPasswordTextField()
	}
	
	func setUpElements() {
		errorLabel.isHidden = true
		
		CustomUtilities.styleTextField(fullNameTextField)
		CustomUtilities.styleTextField(emailTextField)
		CustomUtilities.styleTextField(passwordTextField)
		CustomUtilities.styleTextField(confirmPasswordTextField)
		CustomUtilities.styleFilledButton(signUpButton)
		
		
		
	}
	func clearFields() {
		self.fullNameTextField.text = ""
		self.emailTextField.text = ""
		self.passwordTextField.text = ""
		self.confirmPasswordTextField.text = ""
	}
	func setupPasswordTextField() {
		self.passwordTextField.isSecureTextEntry = true
		self.confirmPasswordTextField.isSecureTextEntry = true
	}
	func setupSignUpBtn() {
		self.signUpButton.setTitleColor(.white, for: .normal)
	}
	
	private func getEmailAndPassword() -> (String, String)? {
		guard let emailAddress = self.emailTextField.text else {
			print("Please enter email address")
			return nil }
		guard let password = self.passwordTextField.text,
			  let _ = self.confirmPasswordTextField.text else {
			print("Error: Please enter a password and a confirm password")
			return nil
		}
		return (emailAddress, password)
	}
	@IBAction func signUpTapped(_ sender: Any) {
			//proceed to signUp flow
		self.errorLabel.isHidden = true
		self.addLoadingIndicator()
		guard let (emailAddress, password) = getEmailAndPassword() else {
            self.removeLoadingIndicator()
            self.errorLabel.text = "Please enter an email and password"
            self.errorLabel.isHidden = false
            return
        }
		guard let confirmPassword = self.confirmPasswordTextField.text, password == confirmPassword else {
            self.removeLoadingIndicator()
			self.errorLabel.text = "Please make sure your password matches the confirm password field"
			print("Error: Please make sure your password matches the confirm password field")
			self.errorLabel.isHidden = false
			return
		}

		let authUser = AuthUser(fullName: self.fullNameTextField.text, emailAddress: emailAddress, password: password)

		self.viewModel.signUp(authUser: authUser, callback: { [weak self]
			result in
			guard let self = self else { return }
			self.removeLoadingIndicator()
			switch result {
				case .success(let didCreateUser):
					if didCreateUser {
						let msg =   """
									Created new user!
									username: \(authUser.emailAddress)
									"""
						let alertVC = self.makeAlertVC(title: "Success", message: msg) {
							//run on completion of showing alertVC
							self.clearFields()
							if let loginVC = self.viewModel.coordinator.getView(LoginViewController.self) {
								self.viewModel.coordinator.presentView(loginVC)
							} else {
								let loginVC = LoginViewController.instantiate() as LoginViewController
								loginVC.viewModel = LoginViewModel(authViewModel: AuthViewModel(), deliveryViewModel: DeliveryViewModel())
								self.viewModel.coordinator.presentView(loginVC)
							}
						}
						self.viewModel.coordinator.presentView(alertVC)
					} else {
						let alertVC = self.makeAlertVC(title: "Uh Oh", message: "It Looks like we cannot create your account right now. Please contact customer support.\nThanks!")
						self.viewModel.coordinator.presentView(alertVC)
					}

				case .failure(let err):
					let alertVC = self.makeAlertVC(title: "Error", message: "Could not create deliveryOwner.\n\(err.localizedDescription)")
					self.removeLoadingIndicator()
					self.viewModel.coordinator.presentView(alertVC)
					self.errorLabel.text = err.localizedDescription
					self.errorLabel.isHidden = false
			}
		})
	}
	@IBAction func loginTapped(_ sender: UIButton) {
		
		guard let (emailAddress, password) = self.getEmailAndPassword() else { return }
        self.viewModel.auth.signIn(user: AuthUser(emailAddress: emailAddress, password: password), completion: { [weak self] authResult in
			guard let self = self else { return }
			if self.definesPresentationContext {
				let loginVC = LoginViewController.instantiate() as LoginViewController
                loginVC.viewModel = LoginViewModel(authViewModel: AuthViewModel(), deliveryViewModel: DeliveryViewModel())
				loginVC.definesPresentationContext = false
				self.viewModel.coordinator.presentView(loginVC)
			} else {
				self.viewModel.coordinator.dismissPresentedView()
			}
		})
	}
}



