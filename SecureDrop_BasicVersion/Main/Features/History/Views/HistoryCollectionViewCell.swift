//
//  HisteryCellHeaderView.swift
//  SecureDrop_BasicVersion
//
//  Created by Norris Wise Jr on 11/11/22.
//

import Foundation
import UIKit

class HistoryCollectionViewCell: UIView {
	private let orderIDLabel = InsetUILabel(frame: .zero)
	private let venderLabel = InsetUILabel(frame: .zero)
	private let orderDetails = InsetUILabel(frame: .zero)
	private let deliverPin = InsetUILabel(frame: .zero)
	private var fontType: FontType!
	private var viewModel: HistoryCellBusinessLogic = HistoryCellViewModel(deliveryOrder: DeliveryOrder())
	
	//configure
	func configure(with viewModel: HistoryCellViewModel, fontType: FontType) {
		self.viewModel = viewModel
		self.fontType = fontType
		setup()
	}
	
	//setup
	func setupDeliverPinLabel() {
		self.deliverPin.font = self.fontType.font
		self.deliverPin.text = "\(self.viewModel.getDeliveryPin())"
		self.deliverPin.numberOfLines = 1
		self.deliverPin.lineBreakMode = .byWordWrapping
		self.deliverPin.textColor = UIColor.lightGray
		self.deliverPin.font = .systemFont(ofSize: 15, weight: .black)
		self.deliverPin.adjustsFontSizeToFitWidth = true
	}
	func setupOrderDetailsLabel() {
		self.orderDetails.font = self.fontType.font
		self.orderDetails.text = self.viewModel.getOrderDetails()
		self.orderDetails.textColor = UIColor(displayP3Red: 0.3, green: 0.3, blue: 0.3, alpha: 0.9)
		
		self.orderDetails.numberOfLines = 0
		self.orderDetails.lineBreakMode = .byWordWrapping
		self.orderDetails.layer.borderColor = UIColor.clear.cgColor
		self.orderDetails.layer.borderWidth = 0.1
		self.orderDetails.layer.cornerRadius = 0
		let color: CGFloat = (245/255)
		self.orderDetails.layer.backgroundColor = UIColor(displayP3Red: color, green: color, blue: color, alpha: 1).cgColor
		self.orderDetails.font = .systemFont(ofSize: 15, weight: .medium)
		self.orderDetails.adjustsFontSizeToFitWidth = true
	}
	func setupVenderLabel() {
		self.venderLabel.font = self.fontType.font
		self.venderLabel.text = self.viewModel.getVendorDetails()
		self.venderLabel.numberOfLines = 1
		self.venderLabel.lineBreakMode = .byWordWrapping
		self.venderLabel.font = .systemFont(ofSize: 15, weight: .regular)
		self.venderLabel.adjustsFontSizeToFitWidth = true
	}
	func setupOrderIDLabel() {
		self.orderIDLabel.font = self.fontType.font
		self.orderIDLabel.text = self.viewModel.getOrderID()
		self.orderIDLabel.numberOfLines = 1
		self.orderIDLabel.lineBreakMode = .byWordWrapping
		self.orderIDLabel.font = .systemFont(ofSize: 15, weight: .bold)
		self.orderIDLabel.adjustsFontSizeToFitWidth = true
	}
	func setup() {
		setupOrderIDLabel()
		setupVenderLabel()
		setupOrderDetailsLabel()
		setupDeliverPinLabel()
	}
	
	//buildView
	func buildView() {
		addSubviews()
		addConstraints()
	}
	func addConstraints() {
		self.layoutIfNeeded()
		let multiplier: CGFloat = (1/3)
		//orderIDLabel
		self.orderIDLabel.anchor(top: self.topAnchor, right: self.venderLabel.leadingAnchor, bottom: orderDetails.topAnchor, left: self.leadingAnchor, padding: UIEdgeInsets(top: 5, left: 10, bottom: -20, right: -10), size: .zero)
		self.orderIDLabel.setContentHuggingPriority(.required, for: .horizontal)
		self.orderIDLabel.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: multiplier).isActive = true
		
		//venderLabel
		self.venderLabel.anchor(top: self.topAnchor, right: self.deliverPin.leadingAnchor, bottom: orderDetails.topAnchor, left: self.orderIDLabel.trailingAnchor, padding: UIEdgeInsets(top: 5, left: 10, bottom: -20, right: -10), size: .zero)
		self.venderLabel.setContentHuggingPriority(.required, for: .horizontal)
		self.venderLabel.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: multiplier).isActive = true
		
		//deliverPin
		self.deliverPin.anchor(top: self.topAnchor, right: self.trailingAnchor, bottom: orderDetails.topAnchor, left: self.venderLabel.trailingAnchor, padding: UIEdgeInsets(top: 5, left: 10, bottom: -20, right: -10), size: .zero)
		self.deliverPin.setContentHuggingPriority(.required, for: .horizontal)
		self.deliverPin.widthAnchor.constraint(lessThanOrEqualTo: self.widthAnchor, multiplier: multiplier).isActive = true
		
		//orderDetails
		self.orderDetails.anchor(top: self.orderIDLabel.bottomAnchor, right: self.trailingAnchor, bottom: self.bottomAnchor, left: self.leadingAnchor, padding: UIEdgeInsets(top: 5, left: 0, bottom: -9, right: 0), size: .zero)
		
	}
	func addSubviews() {
		self.addSubview(orderIDLabel)
		self.addSubview(venderLabel)
		self.addSubview(orderDetails)
		self.addSubview(deliverPin)
	}
	
	override func didMoveToSuperview() {
		super.didMoveToSuperview()
		buildView()
	}
	
	init(viewModel: HistoryCellBusinessLogic) {
		self.viewModel = viewModel
		super.init(frame: .zero)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	enum FontType {
		case title, body
		
		var size: CGFloat {
			return 20
		}
		
		var font: UIFont {
			switch self {
				case .title: return UIFont.systemFont(ofSize: size, weight: .heavy)
				case .body: return UIFont.systemFont(ofSize: size, weight: .medium)
			}
		}
	}
}

class InsetUILabel: UILabel {
	
	func setup() {
		self.font = .systemFont(ofSize: 20, weight: .medium)
		self.layer.borderWidth = 0.25
		self.layer.borderColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.5).cgColor
		self.layer.cornerRadius = 5.0
		self.textAlignment = .center
		let color: CGFloat = (235/255)
		self.layer.backgroundColor = UIColor(displayP3Red: color, green: color, blue: color, alpha: 1).cgColor
	}
	let insets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
	
	override func drawText(in rect: CGRect) {
		super.drawText(in: rect.inset(by: insets))
	}
	
	override var intrinsicContentSize: CGSize {
		let size = super.intrinsicContentSize
		return CGSize(width: size.width + insets.left + insets.right, height: size.height + insets.top + insets.bottom)
	}
	override init(frame: CGRect) {
		super.init(frame: frame)
		setup()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
}
