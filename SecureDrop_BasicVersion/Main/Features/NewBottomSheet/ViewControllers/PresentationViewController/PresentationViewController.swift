






import UIKit

class PresentationViewController: UIPresentationController {
    
    
    override var frameOfPresentedViewInContainerView: CGRect {
        
        return super.presentedView!.frame
    }
    
    override var presentedView: UIView? {
        guard let view = super.presentedView else {return nil}
        return view
    }
    
    override func presentationTransitionWillBegin() {
        guard let containerView = self.containerView else {return}
        let shadowView = UIView(frame: containerView.bounds)
        shadowView.backgroundColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 1)
        shadowView.layer.opacity = 0
        containerView.insertSubview(shadowView, at: 0)
        shadowView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        if let shadowView = self.containerView?.subviews.first, let transitionCoordinator = self.presentedViewController.transitionCoordinator {
            transitionCoordinator.animate { (transitionCoordContext) in
                shadowView.layer.opacity = 0.9
            }

        }
    }

    override func dismissalTransitionWillBegin() {
        if let shadowView = self.containerView?.subviews.first, let transitionCoordinator = self.presentedViewController.transitionCoordinator {
            transitionCoordinator.animate { (transitionCoordContext) in
                shadowView.alpha = 0
            }
        }
    }
    override func presentationTransitionDidEnd(_ completed: Bool) {

    }

    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
    
    }
}



