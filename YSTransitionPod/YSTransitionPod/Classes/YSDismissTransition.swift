//
//  YSDismissTransition.swift
//  YSSwiftTransitionDemo
//
//  Created by 葛燕生 on 2018/11/14.
//  Copyright © 2018 葛燕生. All rights reserved.
//

import UIKit

class YSDismissTransition: NSObject, UIViewControllerAnimatedTransitioning {
  var revers: Bool = false
  let animationDuration: TimeInterval?
  var context: YSGestureTransitionBackContext?
  var transitionContext: UIViewControllerContextTransitioning?
  override init() {
    animationDuration = 0.3
  }
  func gesturefinish() {
    if let transitionTemp = self.transitionContext {
      transitionTemp.completeTransition(transitionTemp.transitionWasCancelled)
    }
  }
  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return animationDuration!
  }
  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    guard let toViewController: UIViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to),
      let fromViewController: UIViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)  else {
        return
    }
    let containerView: UIView = transitionContext.containerView
    var fromView: UIView? = YSTransitionManager.instance.topSnapShotView
    if fromView == nil {
      fromView = fromViewController.view
    } else {
      containerView.addSubview(fromView!)
      fromViewController.view.removeFromSuperview()
    }
    let factor: CGFloat = revers ? -1 : 1
    let initFrame: CGRect = transitionContext.initialFrame(for: fromViewController)
    let screenBounds: CGRect = UIScreen.main.bounds
    let finalFrame: CGRect = initFrame.offsetBy(dx: factor * screenBounds.size.width, dy: 0)
    containerView.addSubview(toViewController.view)
    containerView.sendSubview(toBack: toViewController.view)
    var frame: CGRect = transitionContext.finalFrame(for: toViewController)
    frame.origin.x = -1 * frame.size.width / 3 * factor
    toViewController.view.frame = frame
    let duration: TimeInterval = self.transitionDuration(using: transitionContext)
    let opts: UIView.AnimationOptions = transitionContext.isInteractive ? UIView.AnimationOptions.curveLinear : UIView.AnimationOptions.curveEaseOut
    let animatedBlock: () -> Void = {
      fromView?.frame = finalFrame
      var frame: CGRect = toViewController.view.frame
      frame.origin.x = 0
      toViewController.view.frame = frame
    }
    let animationCompleteBlock: (Bool) -> Void = {
      (finished: Bool) in
      transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
    }
  
    if transitionContext.isInteractive && context?.gestueFinished ?? false {
      animatedBlock()
      animationCompleteBlock(true)
    } else {
      UIView.animate(withDuration: duration,
                     delay: 0.0,
                     options: [UIView.AnimationOptions.overrideInheritedOptions, opts],
                     animations: animatedBlock,
                     completion: animationCompleteBlock)
    }
  }

}
