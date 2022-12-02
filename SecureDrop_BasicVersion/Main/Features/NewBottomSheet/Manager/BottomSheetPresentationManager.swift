






import Foundation
import UIKit
class BottomSheetPresentationManager {
    class func getPresentationViewController(withPresented presentedViewController: UIViewController, andPresenting presentingViewController: UIViewController?) -> PresentationViewController {
        return PresentationViewController(presentedViewController: presentedViewController, presenting: presentingViewController)
    }
    
    class func getTransitionAnimator() -> UIViewControllerAnimatedTransitioning {
        return TransitioningAnimator()
        
    }
}
