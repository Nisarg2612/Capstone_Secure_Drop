







import UIKit

class TransitioningAnimator: NSObject, UIViewControllerAnimatedTransitioning {
   
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 4.0
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        // standby for future transition...
    }
}



