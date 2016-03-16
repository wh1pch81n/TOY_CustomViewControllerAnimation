//
//  ViewController.swift
//  CustomTransitions
//
//  Created by Derrick  Ho on 3/15/16.
//  Copyright © 2016 Derrick  Ho. All rights reserved.
//

import UIKit

func subview(view: UIView, constrainedToSuperView superView: UIView) {
	view.translatesAutoresizingMaskIntoConstraints = false
	view.topAnchor.constraintEqualToAnchor(superView.topAnchor).active = true
	view.bottomAnchor.constraintEqualToAnchor(superView.bottomAnchor).active = true
	view.leadingAnchor.constraintEqualToAnchor(superView.leadingAnchor).active = true
	view.trailingAnchor.constraintEqualToAnchor(superView.trailingAnchor).active = true
}

// Parent ViewController
class ViewController: UIViewController {
	@IBOutlet weak var segmentedButtons: UISegmentedControl!
	
	@IBOutlet weak var containerChildViews: UIView!
	var currentChildViewController: UIViewController!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		let vcs = [
			storyboard!.instantiateViewControllerWithIdentifier("1"),
			storyboard!.instantiateViewControllerWithIdentifier("2"),
			storyboard!.instantiateViewControllerWithIdentifier("3"),
		]
		vcs.forEach(self.addChildViewController)
		currentChildViewController = vcs.first!
		containerChildViews.addSubview(currentChildViewController.view)
		subview(currentChildViewController.view, constrainedToSuperView: containerChildViews)
	}
	
	@IBAction func tappedNewSegment(sender: UISegmentedControl) {
		let nextChildVC = self.childViewControllers[sender.selectedSegmentIndex]
		let ct = ContextTransitioning(fromVC: currentChildViewController, toVC: nextChildVC, contentView: containerChildViews)
		currentChildViewController = nextChildVC
		let animator = EACCircleAnimator(isPresenting: true)
		ct.animatorDelegate = animator
		animator.centerPoint = CGPoint(x: containerChildViews.bounds.midX, y: containerChildViews.bounds.midY)
		animator.animateTransition(ct)
	}
	
}

class Dummyvc: UIViewController {
	
	override func viewDidLoad() {
		print("load")
	}
	
	override func viewDidAppear(animated: Bool) {
		print("Appear")
	}
}

// presenting and dismissing a viewcontroller creates a context for you but in the case of using child view controllers you need to create your own context.
class ContextTransitioning: NSObject, UIViewControllerContextTransitioning {
	
	var fromVC: UIViewController
	var toVC: UIViewController
	var contentView: UIView
	weak var animatorDelegate: UIViewControllerAnimatedTransitioning?
	
	init(fromVC: UIViewController, toVC: UIViewController, contentView: UIView) {
		self.fromVC = fromVC
		self.toVC = toVC
		self.contentView = contentView

		// temporarily disable autolayer while animation takes place
		fromVC.view.translatesAutoresizingMaskIntoConstraints = true
		toVC.view.translatesAutoresizingMaskIntoConstraints = true
		
		fromVC.view.frame = contentView.bounds
		fromVC.view.bounds = contentView.bounds
		
		toVC.view.frame = contentView.bounds
		toVC.view.bounds = contentView.bounds
	}
	
	func containerView() -> UIView? {
		return contentView
	}
	
	func isAnimated() -> Bool {
		return true
	}
	
	func isInteractive() -> Bool {
		return false
	}
	
	func transitionWasCancelled() -> Bool {
		return false
	}
	
	func presentationStyle() -> UIModalPresentationStyle {
		return UIModalPresentationStyle.FullScreen
	}
	
	func updateInteractiveTransition(percentComplete: CGFloat) {
		
	}
	
	func finishInteractiveTransition() {
		
	}
	
	func cancelInteractiveTransition() {
		
	}
	
	func completeTransition(didComplete: Bool) {
		contentView.subviews
			.filter({ $0 != toVC.view })
			.forEach({ $0.removeFromSuperview() })
		subview(toVC.view, constrainedToSuperView: contentView)
		animatorDelegate?.animationEnded?(true)
	}
	
	func viewControllerForKey(key: String) -> UIViewController? {
		switch key {
		case UITransitionContextToViewControllerKey:
			return toVC
		case UITransitionContextFromViewControllerKey:
			return fromVC
		default:
			return nil
		}
	}
	
	func viewForKey(key: String) -> UIView? {
		switch key {
		case UITransitionContextToViewKey:
			return toVC.view
		case UITransitionContextFromViewKey:
			return fromVC.view
		default:
			return nil
		}
	}
	
	func targetTransform() -> CGAffineTransform {
		return CGAffineTransform()
	}
	
	func initialFrameForViewController(vc: UIViewController) -> CGRect {
		return contentView.bounds
	}
	
	func finalFrameForViewController(vc: UIViewController) -> CGRect {
		return contentView.bounds
	}
	
}

class EACCircleAnimator: NSObject, UIViewControllerAnimatedTransitioning {
	
	var transitionContext: UIViewControllerContextTransitioning!
	var centerPoint = CGPoint.zero
	var centerRadius = CGFloat(0)
	var isPresenting: Bool
	var duration = NSTimeInterval(0.7)
	
	init(isPresenting: Bool) {
		self.isPresenting = isPresenting
	}
	
	func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
		return duration
	}
	
	func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
		self.transitionContext = transitionContext
		
		let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
		let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
		
		if isPresenting {
			transitionContext.containerView()!.addSubview(toVC.view)
		}
		
		let startMask: UIBezierPath
		let endMask: UIBezierPath
		
		if isPresenting {
			var startRect = CGRect(origin: centerPoint, size: CGSize.zero)
			startRect.size = CGSize(width: centerRadius * 2, height: centerRadius * 2)
			startRect.offsetInPlace(dx: -centerRadius, dy: -centerRadius)
			startMask = UIBezierPath(ovalInRect: startRect)
			
			var endRect = CGRect(origin: centerPoint, size: CGSize.zero)
			let endRadius = max(
				max(
					centerPoint.distance(CGPoint(x: toVC.view.frame.minX, y: toVC.view.frame.minY)),
					centerPoint.distance(CGPoint(x: toVC.view.frame.minX, y: toVC.view.frame.maxY))
				),
				max(
					centerPoint.distance(CGPoint(x: toVC.view.frame.maxX, y: toVC.view.frame.minY)),
					centerPoint.distance(CGPoint(x: toVC.view.frame.maxX, y: toVC.view.frame.maxY))
				)
			)
			endRect.size = CGSize(width: endRadius * 2, height: endRadius * 2)
			endRect.offsetInPlace(dx: -endRadius, dy: -endRadius)
			endMask = UIBezierPath(ovalInRect: endRect)
		} else {
			var startRect = CGRect(origin: centerPoint, size: CGSize.zero)
			let startRadius = max(
				max(
					centerPoint.distance(CGPoint(x: fromVC.view.frame.minX, y: fromVC.view.frame.minY)),
					centerPoint.distance(CGPoint(x: fromVC.view.frame.minX, y: fromVC.view.frame.maxY))
				),
				max(
					centerPoint.distance(CGPoint(x: fromVC.view.frame.maxX, y: fromVC.view.frame.minY)),
					centerPoint.distance(CGPoint(x: fromVC.view.frame.maxX, y: fromVC.view.frame.maxY))
				)
			)
			startRect.size = CGSize(width: startRadius * 2, height: startRadius * 2)
			startRect.offsetInPlace(dx: -startRadius, dy: -startRadius)
			startMask = UIBezierPath(ovalInRect: startRect)
			
			var endRect = CGRect(origin: centerPoint, size: CGSize.zero)
			endRect.size = CGSize(width: centerRadius * 2, height: centerRadius * 2)
			endRect.offsetInPlace(dx: -centerRadius, dy: -centerRadius)
			endMask = UIBezierPath(ovalInRect: endRect)
		}
		
		let maskLayer = CAShapeLayer()
		maskLayer.path = startMask.CGPath
		if isPresenting {
			toVC.view.layer.mask = maskLayer
		} else {
			fromVC.view.layer.mask = maskLayer
		}
		
		let maskLayerAnimation = CABasicAnimation(keyPath: "path")
		maskLayerAnimation.fromValue = startMask.CGPath
		maskLayerAnimation.toValue = endMask.CGPath
		maskLayerAnimation.duration = transitionDuration(transitionContext)
		maskLayerAnimation.delegate = self
		maskLayerAnimation.fillMode = kCAFillModeForwards // Prevents flickering
		maskLayerAnimation.removedOnCompletion = false // prevents flickering
		maskLayer.addAnimation(maskLayerAnimation, forKey: "path")
	}
	
	override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
		transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
	}
	
	func animationEnded(transitionCompleted: Bool) {
		let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
		let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
		if isPresenting {
			toVC.view.layer.mask = nil
		} else {
			fromVC.view.layer.mask = nil
		}
	}
	
}

extension CGPoint {
	func distance(p: CGPoint) -> CGFloat {
		return sqrt(pow(self.x - p.x, 2) + pow(self.y - p.y, 2))
	}
}