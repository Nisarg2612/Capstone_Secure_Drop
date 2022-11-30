//
//  Coordinator.swift
//  SecureDrop_BasicVersion
//
//  Created by Suman Chatla on 11/2/22.
//

import Foundation
import UIKit

class Coordinator: NavigationResponderDelegate {
	
	static let shared = Coordinator(navigationController: UINavigationController())
	private var navigationController: UINavigationController

	public func updateNavigationController(with navVC: UINavigationController) {
		self.navigationController = navVC
	}
    func navigationContains(_ viewController: UIViewController) -> Bool {
        return self.navigationController.viewControllers.contains(viewController)
        }
        
        func navigationContains(_ viewControllerType: UIViewController.Type) -> Bool {
            return self.navigationController.viewControllers.contains(where: { type(of: $0) == viewControllerType })
        }
        
        func popToView(_ viewController: UIViewController) {
            self.navigationController.popToViewController(viewController, animated: true)
        }
        
    func getView<VC: UIViewController>(_ type: VC.Type) -> VC? where VC : UIViewController {
        let vc = self.navigationController.viewControllers.first(where: { viewController in
            return Swift.type(of: viewController) == VC.self
        }) as? VC
        return vc
        
    }
        
        
    func dismiss(_ viewController: UIViewController, completion: (() -> Void)? = nil) {
           viewController.dismiss(animated: true) {
               completion?()
           }
       }
       
    func presentView(_ viewController: UIViewController, completion: (() -> Void)? = nil) {
		self.navigationController.visibleViewController?.present(viewController, animated: true, completion: {
               completion?()
           })
       }
       
       func pushView(_ viewController: UIViewController) {
           self.navigationController.pushViewController(viewController, animated: true)
       }
       
       func popView(_ viewController: UIViewController) {
		   if let navVC = viewController.navigationController {
			   navVC.popViewController(animated: true)
		   } else {
			   fatalError("\(#function) should not be called from caller without navigation controller")
		   }
       }
       
       func dismissPresentedView(completion: (() -> Void)?) {
           self.navigationController.dismiss(animated: true)
           self.navigationController.visibleViewController?.presentedViewController?.dismiss(animated: true)
		   completion?()
       }
    private init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
}
