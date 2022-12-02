







import UIKit

class PresentedViewController: UIViewController {

    var bottomSheetView: UIView
    var isTapDismissable: Bool
    let bottomMargin: CGFloat

    
    //test view - Do Not Remove
    static func getLabelView() -> UIView {
        let label = UILabel()
        label.text = "Hello There!"
        label.backgroundColor = .orange
        let heightConstr = NSLayoutConstraint(item: label, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 200)
        label.addConstraint(heightConstr)
        return label
    }
    
    func shouldDismiss(touches: Set<UITouch>) {
        guard isTapDismissable else {return}
        guard let point = touches.first?.location(in: self.view) else {return}
        let convertedPoint = self.bottomSheetView.convert(point, from: self.view)
        guard self.bottomSheetView.hitTest(convertedPoint, with: nil) == nil else {return}
        self.dismiss(animated: true, completion: nil)        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        shouldDismiss(touches: touches)
    }
    
    
    override func loadView() {
        super.loadView()
        self.view.backgroundColor = .clear
        let clearView = UIView()
        clearView.backgroundColor = self.bottomSheetView.backgroundColor
        clearView.layer.backgroundColor = self.bottomSheetView.layer.backgroundColor
        
        self.view.addSubview(self.bottomSheetView)
        self.view.addSubview(clearView)
        
        self.bottomSheetView.anchor(top:nil, right: self.view.trailingAnchor, bottom: nil, left: self.view.leadingAnchor, padding: .zero, size: CGSize(width: 0, height: 0))
        clearView.anchor(top: self.bottomSheetView.bottomAnchor, right: self.view.trailingAnchor, bottom: self.view.bottomAnchor, left: self.view.leadingAnchor, padding: .zero, size: CGSize(width: 0, height: self.bottomMargin))
    }
    
   
    
    
    
    init(bottomSheetView sheetView: UIView, shouldDismissWithTap isTapDismissable: Bool, bottomMargin: CGFloat) {
        self.bottomSheetView = sheetView
        self.bottomSheetView.isUserInteractionEnabled = true
        self.bottomMargin = bottomMargin
        self.isTapDismissable = isTapDismissable
        super.init(nibName: nil, bundle: nil)
        self.transitioningDelegate = self
        self.modalPresentationStyle = .custom
    }
    fileprivate init() {
        fatalError("Please use the custom initializer: init(bottomSheetView sheetView: UIView), for this ViewController to work")
    }
    required init?(coder: NSCoder) {
        fatalError("Please use the custom initializer: init(bottomSheetView sheetView: UIView), for this ViewController to work")
    }
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        fatalError("Please use the custom initializer: init(bottomSheetView sheetView: UIView), for this ViewController to work")
    }
}

extension PresentedViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return nil
    }
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return BottomSheetPresentationManager.getPresentationViewController(withPresented: presented, andPresenting: presenting)
    }
}




