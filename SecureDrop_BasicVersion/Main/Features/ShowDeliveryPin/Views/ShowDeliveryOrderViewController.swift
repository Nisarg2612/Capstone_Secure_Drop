//
//  ShowDeliveryPinViewController.swift
//  SecureDrop_BasicVersion
//
//  Created by Suman Chatla on 10/14/22.
//

import Foundation
import Firebase
import FirebaseAuth
import UIKit

protocol ShowDeliveryOrderResponder: UIViewController {
	func showError(title: String, message: String)
	func didAddDeliveryOrder(title: String, message: String)
}
class ShowDeliveryOrderViewController: UIViewController, Storyboarded {
	var viewModel: ShowDeliveryOrderBusinessLogic!
    @IBOutlet weak var deliveryPinTextField: UITextField!
    @IBOutlet weak var orderIDTextField: UITextField!
    @IBOutlet weak var orderDetailsTextView: UITextView!
    @IBOutlet weak var vendorDetailsTextField: UITextField!
    @IBOutlet weak var saveOrderBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
            setup()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.view.isUserInteractionEnabled = false
        self.addLoadingIndicator()
        autoGeneratePin { hasSuccess in
            DispatchQueue.main.async {
                self.deliveryPinTextField.text = self.generateDeliveryPin()
                self.removeLoadingIndicator()
                self.view.isUserInteractionEnabled = true
            }
        }
    }
    func autoGeneratePin(completion: @escaping (_ hasSuccess: Bool?) -> Void) {
        //fake example api call
        DispatchQueue.global(qos: .userInteractive).asyncAfter(deadline: .now() + 2.0) {
            completion(true)
        }
    }
	
	
	func makeDeliveryOrder() -> DeliveryOrder? {
		guard let deliveryPin = self.deliveryPinTextField.text?.toInt,
			  let orderID = self.orderIDTextField.text,
			  let orderDetails = self.orderDetailsTextView.text,
			  let vendorDetails = self.vendorDetailsTextField.text
		else {
			return nil
		}
		let deliveryOrder = viewModel.delivery
			.makeNewDeliveryOrder(deliveryPin: deliveryPin,
								  orderID: orderID,
								  orderDetails: orderDetails,
								  vendorDetails: vendorDetails)
		return deliveryOrder
	}
	func clearTextFields() {
		self.deliveryPinTextField.text = ""
		self.orderIDTextField.text = ""
		self.orderDetailsTextView.text = ""
		self.vendorDetailsTextField.text = ""
	}
	
    @objc func didTapSaveOrderBtn() {
        self.addLoadingIndicator()
		guard let deliveryOrder = makeDeliveryOrder() else { return }
		guard let firUser = Auth.auth().currentUser else { return }
		viewModel.addNewOrderToDatabase(deliveryOrder: deliveryOrder, for: firUser)
    }
    func setupDeliveryPinTextField() {
        deliveryPinTextField.isEnabled = false
        deliveryPinTextField.isUserInteractionEnabled = false
        deliveryPinTextField.backgroundColor = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1)
        deliveryPinTextField.layer.opacity = 1
        deliveryPinTextField.textAlignment = .center
        deliveryPinTextField.font = UIFont(name: "Courier New", size: 20)
        deliveryPinTextField.text = ""
    }
    func generateDeliveryPin() -> String {
        let result = Array(repeating: "", count: 4)
        return result.map { _ in "\(Int.random(in: 0...9))" }.joined()
    }
    func setupOrderDetailsTextView() {
		orderDetailsTextView.layer.masksToBounds = true
		orderDetailsTextView.layer.cornerRadius = 10
		orderDetailsTextView.layer.borderWidth = 0.7
        orderDetailsTextView.layer.borderColor = UIColor(red: 225/255, green: 225/255, blue: 225/255, alpha: 1).cgColor
		orderDetailsTextView.font = UIFont.systemFont(ofSize: 16.0)
		orderDetailsTextView.textColor = UIColor.black
		orderDetailsTextView.textAlignment = NSTextAlignment.center
		orderDetailsTextView.dataDetectorTypes = UIDataDetectorTypes.all
		orderDetailsTextView.layer.shadowOpacity = 0.5
		orderDetailsTextView.isEditable = true
    }
    func setupVendorDetailsTextField() {
//        orderIDTextField.numberOfLines = 1
    }
    func setupOrderDescriptionTextField() {
//        orderIDTextField.numberOfLines = 0
    }
    func setupOrderIDTextField() {
//        orderIDTextField.numberOfLines = 1
    }
    func setupSaveOrderBtn() {
        self.saveOrderBtn.addTarget(self, action: #selector(didTapSaveOrderBtn), for: .touchUpInside)
    }
	func setupView() {
		(self.viewModel as! ShowDeliveryOrderViewModel).delegate = self
	}
    func setup() {
		setupView()
        setupDeliveryPinTextField()
        setupOrderIDTextField()
        setupVendorDetailsTextField()
        setupOrderDescriptionTextField()
        setupOrderDetailsTextView()
        setupSaveOrderBtn()
    }
}

extension ShowDeliveryOrderViewController: ShowDeliveryOrderResponder {
	func showError(title: String, message: String) {
		let alertVC = self.makeAlertVC(title: title, message: message)
		self.removeLoadingIndicator()
		self.viewModel.coordinator.presentView(alertVC)
	}
	
	func didAddDeliveryOrder(title: String, message: String) {
		let alertVC = self.makeAlertVC(title: title, message: message) {
			//completion handler
			self.clearTextFields()
			if let setDeliveryPinVC = self.viewModel.coordinator.getView(SetDeliveryPinViewController.self) {
				self.viewModel.coordinator.popToView(setDeliveryPinVC)
			} else {
				self.viewModel.coordinator.popView(self)
			}
		}
		//remove loading indicator and present alertView with completion handler
		self.removeLoadingIndicator()
		self.viewModel.coordinator.presentView(alertVC) {
			if let deliveryVC = self.viewModel.coordinator.getView(SetDeliveryPinViewController.self) {
				self.viewModel.coordinator.popToView(deliveryVC)
			} else {
				let deliveryPinVC = SetDeliveryPinViewController.instantiate() as SetDeliveryPinViewController
				self.viewModel.coordinator.popToView(deliveryPinVC)
			}
		}
	}
}
