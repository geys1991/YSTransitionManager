//
//  YSSwipeBackInteractionController.swift
//  YSSwiftTransitionDemo
//
//  Created by 葛燕生 on 2018/12/6.
//  Copyright © 2018 葛燕生. All rights reserved.
//

import UIKit

@objc protocol YSSwipeBackInteractionControllerDelegate: AnyObject {
  @objc optional func gestureBackBegin()
  @objc optional func gestureBackCancel()
  @objc optional func gestureBackFinished()
  @objc optional func disableBackGesture() -> Bool
  @objc optional func fireBackGesture() -> Bool
}

class YSSwipeBackInteractionController: UIPercentDrivenInteractiveTransition, UIGestureRecognizerDelegate {
  
  // MARK: perproty
  var context: YSGestureTransitionBackContext = YSGestureTransitionBackContext()
  var interactionInProgress: Bool = false
  var forNavigationController: Bool = false
  var shouldCompleteTransition: Bool = false
  var reverse: Bool = false
  var gestureChanged: Bool = false
  weak var gestureBackInteractionDelegate: YSSwipeBackInteractionControllerDelegate?
  
  override var completionSpeed: CGFloat {
    set {
      
    }
    get {
      return min(1, 1 - self.percentComplete)
    }
  }
  
  func setGestureBackInteractionDelegate(gestureDelegate: YSSwipeBackInteractionControllerDelegate) {
    gestureBackInteractionDelegate = gestureDelegate
  }
  
  func wireToViewController(viewController: UIViewController) {
    prepareGestureRecognizerInView(view: viewController.view)
  }
  
  func prepareGestureRecognizerInView(view: UIView) {
    let edgeGesture: UIScreenEdgePanGestureRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleScreenEdgeGesture(gesture:)))
    edgeGesture.edges = reverse ? .right : .left
    view.addGestureRecognizer(edgeGesture)
    edgeGesture.delegate = self
  }
  
  // MARK: UIGestureRecognizerDelegate
  
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }
  
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }
  
  func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    var viewController: UIViewController?
    if let targetVC = gestureRecognizer.view?.viewController {
      if let navi = targetVC.navigationController {
        viewController = navi
      } else {
        viewController = targetVC
      }
    }
    if let targetVC = viewController {
      if targetVC.isBeingDismissed || targetVC.isBeingPresented || targetVC.view.window == nil {
        interactionInProgress = false
        return false
      }
    }
    return true
  }
  
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
    if let target: YSSwipeBackInteractionControllerDelegate = getProperDelegate(gestureRecognizer: gestureRecognizer) as? YSSwipeBackInteractionControllerDelegate {
      if target.disableBackGesture?() == false {
        return false
      }
    }
    return true
  }
  
  // MARK: private method
  
  @objc func handleScreenEdgeGesture(gesture: UIScreenEdgePanGestureRecognizer) {
    let transitionPoint: CGPoint = gesture.translation(in: gesture.view?.superview)
    switch gesture.state {
    case .began:
      context.gestueFinished = false
      var parentVC: UIViewController?
      if let parentViewController: UIViewController = gesture.view?.viewController {
        parentVC = parentViewController
        if parentViewController.isBeingPresented || parentViewController.isBeingDismissed {
          interactionInProgress = false
          break
        }
      }
      interactionInProgress = true
      if let target: YSSwipeBackInteractionControllerDelegate = getProperDelegate(gestureRecognizer: gesture) as? YSSwipeBackInteractionControllerDelegate {
        if target.fireBackGesture?() == nil {
          let complete = {
            // TODO: config status bar
          }
          if parentVC?.navigationController != nil {
            parentVC?.navigationController?.dismiss(animated: true, completion: complete)
          } else {
            parentVC?.dismiss(animated: true, completion: nil)
          }
        }
      }
      gestureBackInteractionDelegate?.gestureBackBegin?()
    case .changed:
      gestureChanged = true
      let fractionFlag: Int = reverse ? -1 : 1
      var fraction: CGFloat = 0.0
      if reverse {
        fraction = CGFloat(fmaxf(fminf(Float(transitionPoint.x / UIScreen.main.bounds.size.width), 0.0), -1.0)) * CGFloat(fractionFlag)
      } else {
        fraction = CGFloat(fminf(fmaxf(Float(transitionPoint.x / UIScreen.main.bounds.size.width), 0.0), 1.0)) * CGFloat(fractionFlag)
      }
      shouldCompleteTransition = fraction > 0.5
      update(fraction)
    case .ended, .cancelled:
      context.gestueFinished = true
      interactionInProgress = false
      let velocityValue = gesture.velocity(in: gesture.view?.superview).x
      if abs(velocityValue) > 100 {
        if reverse && velocityValue < 0 {
          shouldCompleteTransition = true
        } else if !reverse && velocityValue > 0 {
          shouldCompleteTransition = true
        }
      }
      if !shouldCompleteTransition || gesture.state == .cancelled {
        cancel()
        gestureBackInteractionDelegate?.gestureBackCancel?()
        gestureChanged = false
      } else {
        let parentVC = gesture.view?.viewController
        if gestureBackInteractionDelegate?.gestureBackFinished?() == nil {
          var targetViewController: UIViewController?
          if let parentVCNaviTemp = parentVC as? UINavigationController {
            if let firstViewController = parentVCNaviTemp.viewControllers.first {
              targetViewController = firstViewController
            } else {
              if let parentVCTemp = parentVC {
                targetViewController = parentVCTemp
              }
            }
          }
          YSTransitionManager.instance.swipeBackSuccessFinishProcessing = true
          // 调用返回方法
          targetViewController?.backButtonOperation(backButton: nil)
          YSTransitionManager.instance.swipeBackSuccessFinishProcessing = false
          finish()
        }
      }
    default:
      return
    }
  }
  
  func getProperDelegate(gestureRecognizer: UIGestureRecognizer) -> AnyObject? {
    var target: AnyObject?
    if gestureBackInteractionDelegate != nil {
      target = gestureBackInteractionDelegate
    } else {
      if let parentVC: UIViewController = gestureRecognizer.view?.viewController {
        if parentVC.isKind(of: UINavigationController.self) {
          if let parentNavi = parentVC as? UINavigationController {
            if parentNavi.viewControllers.count > 0 {
              target = parentNavi.topViewController
            }
          }
        } else {
          target = parentVC
        }
      }
    }
    if target is YSSwipeBackInteractionControllerDelegate {
      return target
    }
    return nil
  }
}
