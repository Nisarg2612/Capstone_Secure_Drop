//
//  MarginedLabel.swift
//  SecureDrop_BasicVersion
//
//  Created by Norris Wise Jr on 12/1/22.
//

import Foundation
import UIKit

class PaddedLabel: UILabel {
	private let insetValue: CGFloat = 10
	private var insets: UIEdgeInsets {
		let xOffSet: CGFloat = 5
		let xValue = (insetValue * 2) + xOffSet
		return UIEdgeInsets.init(top: insetValue, left: xValue, bottom: insetValue, right: xValue)
	}
	
	override var intrinsicContentSize: CGSize {
		var size = super.intrinsicContentSize
		size.width += insets.left + insets.right
		size.height += insets.top + insets.bottom
		return size
	}
	override func drawText(in rect: CGRect) {
		super.drawText(in: rect.inset(by: insets))
	}
}
