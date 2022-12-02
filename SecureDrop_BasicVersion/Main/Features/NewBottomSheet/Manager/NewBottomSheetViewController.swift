




import UIKit

class NewBottomSheetViewController: UIViewController {
    
    var implicitAnim: UIViewImplicitlyAnimating?
    var isTransitionInteracting = false
    var transitionContext: UIViewControllerContextTransitioning?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    func didSlideScreen(gesture: UIScreenEdgePanGestureRecognizer) {
        switch gesture.state {
        case .began: break
        case .changed:
            let view = gesture.view!
            let delta = gesture.translation(in: view)
            let percent = abs(delta.x/view.bounds.size.width)
            self.implicitAnim?.fractionComplete = percent
            self.transitionContext?.updateInteractiveTransition(percent)
            break
        case .ended:
            let anim = self.implicitAnim as! UIViewPropertyAnimator
            anim.pauseAnimation()
            anim.isReversed = anim.fractionComplete < 0.5 ? true : false
            //duration factor is 0.2, because original is 0.4. if 0.5, or half of animation has finished, we have 0.2 time left.
            anim.continueAnimation(withTimingParameters: UICubicTimingParameters(animationCurve: .linear), durationFactor: 0.2)
            break
        default: break
        }
    }
}


extension NewBottomSheetViewController: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.4
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let anim = self.interruptibleAnimator(using: transitionContext)
        anim.startAnimation()
    }
    
    func interruptibleAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
        
        if let anim = self.implicitAnim {
            return anim
        }
        if let fromVC = transitionContext.viewController(forKey: .from) {
            let containerView = transitionContext.containerView
            let vc2FinalFrame = transitionContext.finalFrame(for: fromVC)
            let toVCview = transitionContext.view(forKey: .to)!
            
            toVCview.frame = vc2FinalFrame
            toVCview.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            toVCview.alpha = 0
            containerView.addSubview(toVCview)
            
            let anim = UIViewPropertyAnimator(duration: 0.4, curve: .linear) {
                toVCview.alpha = 1
                toVCview.transform = CGAffineTransform.identity
            }
            
            anim.addCompletion { animPos in
                transitionContext.completeTransition(true)
            }
            self.implicitAnim = anim
            return anim
        }
        if let toVC = transitionContext.viewController(forKey: .to) {
            return UIViewPropertyAnimator()
        }
        
        
        
        
        
        
        
        
        /* -- CODE FOR TabViewController Example --
        if let anim = self.implicitAnim {
            return anim
        }
        let vc1 = transitionContext.viewController(forKey: .from)!
        let vc2 = transitionContext.viewController(forKey: .to)!
        let containerView = transitionContext.containerView
        
        let vc1InitialFrame = transitionContext.initialFrame(for: vc1)
        let vc2EndFrame = transitionContext.finalFrame(for: vc2)
        
        let fromView = transitionContext.view(forKey: .from)
        let toView = transitionContext.view(forKey: .to)
        
        let propAnim = UIViewPropertyAnimator(duration: 0.4, curve: .linear) {
            
        }
        
        propAnim.addCompletion { (animPosition) in
            
            if animPosition == .end {
                transitionContext.finishInteractiveTransition()
                transitionContext.completeTransition(true)
            }else {
                transitionContext.cancelInteractiveTransition()
                transitionContext.completeTransition(false)
            }
        }
        
        self.implicitAnim = propAnim
        return propAnim
 
        */
        return UIViewPropertyAnimator()
    }
    func animationEnded(_ transitionCompleted: Bool) {
        self.implicitAnim = nil
        self.isTransitionInteracting = false
        self.transitionContext = nil 
    }
    
    
}


extension NewBottomSheetViewController: UIViewControllerInteractiveTransitioning {
    func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        self.implicitAnim = interruptibleAnimator(using: transitionContext)
        self.transitionContext = transitionContext
    }
    
    
    
    
}




