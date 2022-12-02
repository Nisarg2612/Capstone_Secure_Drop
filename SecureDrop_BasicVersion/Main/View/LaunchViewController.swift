//
//  launchViewController.swift
//  SecureDrop_BasicVersion
//
//  Created by Suman Chatla on 9/22/22.
//

import UIKit


protocol NavigationResponderDelegate: AnyObject {
    func dismissPresentedView(completion: (() -> Void)?)
    func dismiss(_ viewController: UIViewController, completion: (() -> Void)?)
    func popView(_ viewController: UIViewController)
    func presentView(_ viewController: UIViewController, completion: (() -> Void)?)
    func pushView(_ viewController: UIViewController)
    func navigationContains(_ viewController: UIViewController) -> Bool
    func navigationContains(_ viewControllerType: UIViewController.Type) -> Bool
    func popToView(_ viewController: UIViewController)
    func getView<VC: UIViewController>(_ type: VC.Type) -> VC?
}

extension NavigationResponderDelegate {
    func presentView(_ viewController: UIViewController, completion: (() -> Void)? = nil) {
		if let closure = completion {
			self.presentView(viewController, completion: closure)
		} else {
			self.presentView(viewController, completion: nil)
		}
	}
    func dismiss(_ viewController: UIViewController, completion: (() -> Void)? = nil) {
		self.dismiss(viewController, completion: nil)
	}
	func dismissPresentedView(completion: (() -> Void)? = nil) {
		self.dismissPresentedView(completion: nil)
	}
}

class LaunchViewController: UIViewController, Storyboarded {

    @IBOutlet var launchSignUpButton: UIButton!
    @IBOutlet var launchLoginButton: UIButton!
	var viewModel: LaunchViewBusinessLogic!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setUpElements()

        // Do any additional setup after loading the view.
    }
    
	func setupView() {
		self.viewModel = LaunchViewModel()
		(self.viewModel.coordinator as! Coordinator).updateNavigationController(with: self.navigationController!)
	}
    func setUpElements() {
        CustomUtilities.styleFilledButton(launchSignUpButton)
        //CustomUtilities.styleFilledButton(LoginButton)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
 
    @IBAction func signUpTapped(_ sender: Any) {
		let signUpVC = SignUpViewController.instantiate() as SignUpViewController
        signUpVC.definesPresentationContext = true
		let viewModel = SignUpViewModel(authBusinessLogic: AuthViewModel(), deliveryBusinessLogic: DeliveryViewModel())
		signUpVC.viewModel = viewModel
		self.viewModel.coordinator.pushView(signUpVC)
    }
    
    @IBAction func loginTapped(_ sender: Any) {
		let loginVC = LoginViewController.instantiate() as LoginViewController
        let viewModel = LoginViewModel(authViewModel: AuthViewModel(), deliveryViewModel: DeliveryViewModel())
		loginVC.viewModel = viewModel
        loginVC.definesPresentationContext = true
		self.viewModel.coordinator.pushView(loginVC)
    }
}


