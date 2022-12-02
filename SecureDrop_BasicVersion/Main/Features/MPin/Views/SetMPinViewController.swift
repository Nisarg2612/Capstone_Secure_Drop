//
//  HomepageViewController.swift
//  SecureDrop_BasicVersion
//
//  Created by Suman Chatla on 9/22/22.
//

import UIKit
import FirebaseAuth
import Firebase

protocol SetMPinViewResponder {
	func showError(title: String, message: String)
	func didSetMPin(update title: String, message: String)
}

class SetMPinViewController: UIViewController, Storyboarded {
	
	var viewModel: MPinBusinessLogic!
    @IBOutlet var pinTextField: UITextField!
    @IBOutlet var pinValidationTextField: UITextField!
    @IBOutlet var errorLabel: UILabel!
    @IBOutlet var setMasterPinBtn: UIButton!
    
	
	
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
	func setupView() {
		(self.viewModel as! MPinViewModel).delegate = self
	}
    func setup() {
        addGestureRecognizer()
        setupSetMasterPinBtn()
        setupPinTextField()
		setupView()
    }
    func isValidPasscode() -> String? {
        let errorMsg: String =             """
                                        Error: Invalid Passcode.
                                        Please enter a 4 Digit Passcode.
                                        Be sure to enter an exact match in both text fields.
                                        Thank you! :)
                                        """
        guard let pin = self.pinTextField.text,
                let validationPin = self.pinValidationTextField.text else {
			self.showError(title: "Error", message: "Missing MPIN")
            return nil
        }
        let isNotEmpty = !(pin.isEmpty && validationPin.isEmpty)
        let isSame = pin == validationPin
        if isNotEmpty && isSame {
            return pin
        } else {
			self.showError(title: "Error", message: errorMsg)
            return nil
        }
    }
	func getFirbaseUser() -> User? {
		guard let firUser = Auth.auth().currentUser else {
			self.removeLoadingIndicator()
			let errMsg = "Missing Firebase User"
			let alertVC = self.makeAlertVC(title: "Error", message: errMsg) { [unowned self] in
				self.viewModel.coordinator.popView(self)
			}
			self.viewModel.coordinator.presentView(alertVC)
			return nil
		}
		return firUser
	}
	func getValidMPin() -> Int? {
		guard let mPin = self.isValidPasscode()?.toInt else {
			self.removeLoadingIndicator()
			let errMsg = "Please enter matching MPIN's for your primary and validation fields"
			self.showError(title: "Error", message: errMsg)
			return nil
		}
		return mPin
	}
	
    @objc func didTapSetMasterPinBtn() {
		self.addLoadingIndicator()
		Log("didTap: \(#function)", .debug)
		guard let mPin = getValidMPin() else { return }
		guard let firUser = getFirbaseUser() else { return }
		self.viewModel.setMasterPin(firUser: firUser, mPin: mPin)
    }
	
    @objc func didTapScreen(_ sender: UITapGestureRecognizer) {
        print("didTap: \(#function)")
        self.pinTextField.resignFirstResponder()
        self.pinValidationTextField.resignFirstResponder()
    }
    func addGestureRecognizer() {
        let tapGesture = UITapGestureRecognizer()
        tapGesture.numberOfTapsRequired = 1
        tapGesture.addTarget(self, action: #selector(didTapScreen))
        self.view.addGestureRecognizer(tapGesture)
    }
    func setupSetMasterPinBtn() {
//        setMasterPinBtn.layer.borderWidth = setMasterPinBtn.bounds.height / 2
        setMasterPinBtn.addTarget(self, action: #selector(didTapSetMasterPinBtn), for: .touchUpInside)
    }
    func setupPinTextField() {
        self.pinTextField.delegate = self
        self.pinValidationTextField.delegate = self
        self.pinTextField.keyboardType = .numberPad
        self.pinValidationTextField.keyboardType = .numberPad
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

//MARK: textField+Delegate
extension SetMPinViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        //check if string can cast to Int
        guard let _ = Int(string) else {
            return string.isEmpty && range.length > 0
        }
        //If so, generate full text
        let replacementText = (textField.text ?? "") + string
        //check if text length is less than 4
        guard replacementText.count <= 4 else { return false }
        //If so, allow text to printed in field
        print("wholeText: \(replacementText)")
        print("replacement: \(string)")
        return true
    }
}

//MARK: MPIN enum for keys
enum MPIN {
    case masterKeyID
    var description: String {
        switch self {
        case .masterKeyID: return "masterKey"
        }
    }
}
 

//MARK: MPinViewResponder
extension SetMPinViewController: SetMPinViewResponder {
	
	func showError(title: String, message: String) {
		let alertVC = self.makeAlertVC(title: title, message: message)
		self.removeLoadingIndicator()
		self.viewModel.coordinator.presentView(alertVC)
	}
	
	func didSetMPin(update title: String, message: String) {
		let alertVC = self.makeAlertVC(title: title, message: message) {
			if let setDeliveryVC = self.viewModel.coordinator.getView(SetDeliveryPinViewController.self) {
				self.viewModel.coordinator.pushView(setDeliveryVC)
			} else {
				let setDeliveryVC = SetDeliveryPinViewController.instantiate() as SetDeliveryPinViewController
				setDeliveryVC.viewModel = DeliveryPinViewModel()
				self.viewModel.coordinator.pushView(setDeliveryVC)
			}
		}
		self.removeLoadingIndicator()
		self.viewModel.coordinator.presentView(alertVC)
	}
}
