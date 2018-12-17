//
//  YSViewControllerTransitionManager.swift
//  YSSwiftTransitionDemo
//
//  Created by 葛燕生 on 2018/11/9.
//  Copyright © 2018 葛燕生. All rights reserved.
//

import UIKit

class YSViewControllerTransitionManager: NSObject, UIViewControllerTransitioningDelegate, UINavigationControllerDelegate {
  
  var presentTransition: YSPresentTransition = YSPresentTransition()
  var dismissTransition: YSDismissTransition = YSDismissTransition()
  var interactionController: YSSwipeBackInteractionController = YSSwipeBackInteractionController()
  
  override init() {
    super.init()
    let context: YSGestureTransitionBackContext = YSGestureTransitionBackContext()
    dismissTransition.context = context
  }
  
  func wireToViewController(viewController: UIViewController) {
    interactionController.wireToViewController(viewController: viewController)
  }
  
  // MARK: UIViewControllerTransitioningDelegate
  
  func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return dismissTransition
  }
  
  func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return presentTransition
  }
  
  func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
    interactionController.forNavigationController = false
    return interactionController.interactionInProgress ? interactionController : nil
  }
  
  // MARK: UINavigationControllerDelegate
  
  func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    if operation == .push {
      interactionController.forNavigationController = true
      interactionController.wireToViewController(viewController: toVC)
    }
    if operation == .pop {
      return dismissTransition
    }
    return presentTransition
  }
  
  func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
    interactionController.forNavigationController = true
    return interactionController.interactionInProgress ? interactionController : nil
  }
  
}
