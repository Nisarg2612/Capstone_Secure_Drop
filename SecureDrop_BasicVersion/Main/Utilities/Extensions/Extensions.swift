//
//  Extensions.swift
//  SecureDrop_BasicVersion
//
//  Created by Suman Chatla on 10/14/22.
//

import Foundation
import UIKit
extension Int {
	var toString: String {
		return "\(self)"
	}
}
extension String {
	var toInt: Int? {
		Int(self)
	}
}
extension UIViewController {
	public func makeAlertVC(title: String, message: String, completion: (() -> Void)? = nil) -> UIAlertController {
		let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
		let okAction = UIAlertAction(title: "Ok", style: .default) {
			_ in
			completion?()
		}
		alertVC.addAction(okAction)
		return alertVC
	}
}
extension UIView {
    
    func anchor(top: NSLayoutYAxisAnchor? = nil, right: NSLayoutXAxisAnchor? = nil, bottom: NSLayoutYAxisAnchor? = nil, left: NSLayoutXAxisAnchor? = nil, padding: UIEdgeInsets = .zero, size: CGSize = .zero) {
        
        self.translatesAutoresizingMaskIntoConstraints = false
        if let top = top {
            self.topAnchor.constraint(equalTo: top, constant: padding.top).isActive = true
        }
        if let right = right {
            self.trailingAnchor.constraint(equalTo: right, constant: padding.right).isActive = true
        }
        if let bottom = bottom {
            self.bottomAnchor.constraint(equalTo: bottom, constant: padding.bottom).isActive = true
        }
        if let left = left {
            self.leadingAnchor.constraint(equalTo: left, constant: padding.left).isActive = true
        }
        if size != .zero {
            if size.height != .zero {
                self.heightAnchor.constraint(equalToConstant: size.height).isActive = true
            }
            if size.width != .zero {
                self.widthAnchor.constraint(equalToConstant: size.width).isActive = true
            }
        }
        
    }
}


extension UIViewController {
	func addLoadingIndicator(toView view: UIView? = nil, color: UIColor = .black) {
		let thisView = (view ?? self.view)!
        let loadingIndicator = UIActivityIndicatorView(style: .large)
        loadingIndicator.color = color
        loadingIndicator.frame = thisView.bounds
        thisView.addSubview(loadingIndicator)
        loadingIndicator.anchor(top: thisView.topAnchor, right: thisView.trailingAnchor, bottom: thisView.bottomAnchor, left: thisView.leadingAnchor)
        loadingIndicator.isHidden = false
		loadingIndicator.startAnimating()
    }
	func removeLoadingIndicator(from view: UIView? = nil) {
		let thisView = (view ?? self.view)!
        let activityIndicatorView = thisView.subviews.first { $0 is UIActivityIndicatorView } as? UIActivityIndicatorView
		activityIndicatorView?.stopAnimating()
        activityIndicatorView?.isHidden = true
        activityIndicatorView?.removeFromSuperview()
    }
}
