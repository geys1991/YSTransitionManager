//
//  YSPresentTransition.swift
//  YSSwiftTransitionDemo
//
//  Created by 葛燕生 on 2018/11/14.
//  Copyright © 2018 葛燕生. All rights reserved.
//

import UIKit

class YSPresentTransition: NSObject, UIViewControllerAnimatedTransitioning {
  let animationDuration: TimeInterval?
  var revers: Bool = false
  override init() {
    animationDuration = 0.3
  }
  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return animationDuration!
  }
  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    let toViewController: UIViewController? = transitionContext.viewController(forKey: .to)
    let fromViewController: UIViewController? = transitionContext.viewController(forKey: .from)
    guard let toVC = toViewController, let fromVC = fromViewController else {
      return
    }
    let finalFrame: CGRect = transitionContext.finalFrame(for: toVC)
    let containerView: UIView = transitionContext.containerView
    let screenBounds: CGRect = UIScreen.main.bounds
    let captureView: UIView = toVC.view
    let factor: CGFloat = self.revers ? -1 : 1
    captureView.frame = finalFrame.offsetBy(dx: factor * screenBounds.size.width, dy: 0)
    containerView.addSubview(captureView)
    let durationTime: TimeInterval = self.transitionDuration(using: transitionContext)
    UIView.animate(withDuration: durationTime,
                   delay: 0.0,
                   options: [.curveEaseInOut, .overrideInheritedOptions],
                   animations: {
                    let fromeFrame: CGRect = fromVC.view.frame
                    fromVC.view.frame = fromeFrame.offsetBy(dx: -1 * fromeFrame.size.width / 3 * factor, dy: 0)
                    captureView.frame = finalFrame
    }, completion: { _ in
      transitionContext.completeTransition(true)
    })
  }
}
