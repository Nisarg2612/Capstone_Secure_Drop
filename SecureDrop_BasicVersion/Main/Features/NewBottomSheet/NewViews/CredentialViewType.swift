//
//  PasswordChangeView.swift
//  SecureDrop_BasicVersion
//
//  Created by Norris Wise Jr on 11/30/22.
//

import Foundation
import UIKit

protocol CredentialViewDelegate: AnyObject {
	func didTapSubmitBtn(for viewType: CredentialViewType, newCredential: String)
}
enum CredentialViewType { case password, MPIN }
class ChangeCredentialView: UIView {
	weak var delegate: CredentialViewDelegate?
	var titleLabel = UILabel(frame: .zero)
	var descriptionLabel = UILabel(frame: .zero)
	var inputTextField = UITextField(frame: .zero)
	var submitBtnLabel = PaddedLabel(frame: .zero)
	var viewModel: BottomSheetViewProtocol
	let viewType: CredentialViewType
	
	func teardownKeyboardNotifications() {
		
	}
	@objc func setupKeyboard() {
		
	}
	func setupKeyboardNotifications() {
		NotificationCenter.default.addObserver(self, selector: #selector(setupKeyboard), name: .AuthStateDidChange, object: nil)
	}

	@objc func didTapSubmitBtn() {
		guard let newCredentialInput = self.inputTextField.text else { return }
		self.delegate?.didTapSubmitBtn(for: viewType, newCredential: newCredentialInput)
	}
	func addConstraints() {
		//titleLabel
		self.titleLabel.anchor(top: self.topAnchor, right: nil, bottom: nil, left: nil, padding: UIEdgeInsets(top: 10, left: 20, bottom: 0, right: -20), size: .zero)
		self.titleLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
		
		//descriptionLabel
		self.descriptionLabel.anchor(top: self.titleLabel.bottomAnchor, right: self.trailingAnchor, bottom: nil, left: self.leadingAnchor, padding: UIEdgeInsets(top: 10, left: 10, bottom: -10, right: -10), size: .zero)
		self.descriptionLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
		
		//inputTextField
		self.inputTextField.anchor(top: self.descriptionLabel.bottomAnchor, right: self.trailingAnchor, bottom: nil, left: self.leadingAnchor, padding: UIEdgeInsets(top: 30, left: 20, bottom: -10, right: -20), size:  .zero)
		self.inputTextField.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
		
		//submitBtnLabel
		self.submitBtnLabel.anchor(top: self.inputTextField.bottomAnchor, right: nil, bottom: self.bottomAnchor, left: nil, padding: UIEdgeInsets(top: 30, left: 20, bottom: -40, right: -20), size: .zero)
		self.submitBtnLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
		
	}
	func addSubviews() {
		self.addSubview(titleLabel)
		self.addSubview(descriptionLabel)
		self.addSubview(inputTextField)
		self.addSubview(submitBtnLabel)
	}
	func setupSubmitBtnLabel() {
		self.submitBtnLabel.text = viewModel.submitText
		self.submitBtnLabel.textColor = .black
		self.submitBtnLabel.layer.cornerRadius = 19
		self.submitBtnLabel.font = .systemFont(ofSize: 25, weight: .medium)
		self.submitBtnLabel.layer.backgroundColor = UIColor.clear.cgColor
		self.submitBtnLabel.layer.borderWidth = 0.5
		self.submitBtnLabel.layer.borderColor = UIColor.black.cgColor
		self.submitBtnLabel.numberOfLines = 1
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapSubmitBtn))
		tapGesture.numberOfTapsRequired = 1
		tapGesture.numberOfTouchesRequired = 1
		self.submitBtnLabel.addGestureRecognizer(tapGesture)
		self.submitBtnLabel.isUserInteractionEnabled = true
	}
	func setupInputTextField() {
		inputTextField.placeholder = viewModel.placeholder
		inputTextField.font = .systemFont(ofSize: 20, weight: .medium)
		inputTextField.borderStyle = .roundedRect
	}
	
	func setupDescriptionLabel() {
		descriptionLabel.text = viewModel.descriptionText
		descriptionLabel.numberOfLines = 0
		descriptionLabel.lineBreakMode = .byWordWrapping
		descriptionLabel.textAlignment = .center
		descriptionLabel.font = .systemFont(ofSize: 17, weight: .medium)
		descriptionLabel.textColor = .darkGray
	}
	func setupTitleLabel() {
		self.titleLabel.backgroundColor = .clear
		self.titleLabel.text = viewModel.title
		self.titleLabel.font = .systemFont(ofSize: 35, weight: .bold)
		self.titleLabel.textColor = .black
		self.titleLabel.numberOfLines = 1
	}
	func layoutView() {
		self.backgroundColor = .white
		self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
		self.layer.cornerRadius = 19
	}
	func setup() {
		setupTitleLabel()
		setupDescriptionLabel()
		setupInputTextField()
		setupSubmitBtnLabel()
		layoutView()
	}
	func buildView() {
		addSubviews()
		addConstraints()
	}
	
	override func didMoveToSuperview() {
		super.didMoveToSuperview()
		setup()
		buildView()
	}
	//specify keyboard type
	init(viewType: CredentialViewType) {
		self.viewType = viewType
		self.viewModel = self.viewType == .password ? PasswordViewModelBottomSheet() : MPINViewModelBottomSheet()
		super.init(frame: .zero)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

protocol BottomSheetViewProtocol {
	var title: String { set get }
	var descriptionText: String { set get }
	var placeholder: String { get }
	var submitText: String { get }
}

struct PasswordViewModelBottomSheet: BottomSheetViewProtocol {
	var title = "Change Password"
	var descriptionText: String = "Please enter a new password. Upon submitting, this will be your new password."
	var placeholder = "Enter Password"
	var submitText: String = "Update Password"
}
struct MPINViewModelBottomSheet: BottomSheetViewProtocol {
	var title = "Update MPIN"
	var descriptionText: String = "Please enter a new MPIN. Your new MPIN will go into effect immediately."
	var placeholder = "New #MPIN"
	var submitText: String = "Submit New MPIN"
}
