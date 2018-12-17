//
//  YSTransitionManager.swift
//  YSSwiftTransitionDemo
//
//  Created by 葛燕生 on 2018/11/6.
//  Copyright © 2018 葛燕生. All rights reserved.
//

import UIKit
import YYKit

private let kAnimatedKey = "animated"
private let kReverseKey = "reverse"
private let kCompletionKey = "completion"
private let kViewControllerKey = "viewController"
private var kTransition = "transition"

public class YSTransitionManager: NSObject {

  public static let instance: YSTransitionManager = YSTransitionManager ()
  var tabbarController: UIViewController?
  var topSnapShotView: UIView?
  var swipeBackSuccessFinishProcessing: Bool = false
  
  // MARK: public methods
  
  public func topViewController() -> UIViewController {
    var topViewController = self.tabbarController!
    while true {
      if topViewController.presentedViewController == nil {
        break
      }
      topViewController = topViewController.presentedViewController!
    }
    return topViewController
  }
  
  public func presentTargetVC(target targetVC: UIViewController!,
                       complete: (() -> Void)?) {
    self.presentTargetVC(target: targetVC,
                         animate: true,
                         reve: false,
                         complete: complete)
  }
  
  public func presentTargetVC(target targetVC: UIViewController!,
                       animate animated: Bool,
                       reve reverse: Bool,
                       complete: (() -> Void)?) {
    if targetVC == nil {
      return
    }
    let completeBlock = complete
    let transitionParams: [String: Any] = [kViewControllerKey: targetVC ,
                                           kReverseKey: reverse,
                                           kAnimatedKey: animated,
                                           kCompletionKey: completeBlock as Any]
    self.YS_InternalPresentTargetVC(params: transitionParams)
  }
  
  public func dismissModalViewController(animated: Bool, complete: (() -> Void)?) {
    self.dismissViewController(targetViewController: self.topViewController(), animated: animated, complete: complete)
  }
  
  public func dismissViewController(targetViewController: UIViewController, animated: Bool, complete: (() -> Void)?) {
    if swipeBackSuccessFinishProcessing {
      return
    }
    if !targetViewController.isBeingDismissed && !targetViewController.isBeingPresented {
      targetViewController.dismiss(animated: animated) {
        complete?()
      }
    }
  }
  
  public func dismissToClazz(clazzName: AnyClass, animated: Bool, complete: (() -> Void)?) {
    var topViewController: UIViewController? = self.topViewController()
    while topViewController != nil {
      if topViewController?.isMember(of: UINavigationController.self) == true {
        let targetNavi: UINavigationController = topViewController as! UINavigationController
        let targetRootVC: UIViewController? = targetNavi.topViewController
        if (targetRootVC?.isKind(of: clazzName.self)) == true {
          if animated {
            self.snapShotTopView(vcToDismiss: targetRootVC)
          }
          targetRootVC?.dismiss(animated: true
            , completion: {
              self.topSnapShotView = nil
              self.topSnapShotView?.removeFromSuperview()
              complete?()
          })
          break
        }
      }
      topViewController = topViewController?.presentingViewController
    }
  }
  
  // MARK: private methods
  
  private func YS_InternalPresentTargetVC(params: [String: Any]) {
    guard let targetViewController = params[kViewControllerKey] as? UIViewController else {
      return
    }
    var reverse: Bool = false
    if let reverseFlag = params[kReverseKey] as? Bool {
      reverse = reverseFlag
    }
    var animated: Bool = false
    if let animatedFlag = params[kAnimatedKey] as? Bool {
      animated = animatedFlag
    }
    var completeBlock: () -> Void = {
      
    }
    if let complete = params[kCompletionKey] as? () -> Void {
      completeBlock = complete
    }
    let topViewController = self.topViewController()
    let transitionManager: YSViewControllerTransitionManager = YSViewControllerTransitionManager()
    transitionManager.dismissTransition.revers = reverse
    transitionManager.presentTransition.revers = reverse
    transitionManager.interactionController.reverse = reverse
    
    targetViewController.transitioningDelegate = transitionManager
    objc_setAssociatedObject(targetViewController, &kTransition, transitionManager, .OBJC_ASSOCIATION_RETAIN)
    if !topViewController.isBeingDismissed && !topViewController.isBeingPresented {
      topViewController.present(targetViewController, animated: animated) {
        transitionManager.wireToViewController(viewController: targetViewController)
        completeBlock()
      }
    }
  }
  
  func snapShotTopView(vcToDismiss: UIViewController?) {
    guard vcToDismiss != nil else {
      return
    }
    var topViewController = self.topViewController()
    if let topVC = topViewController.navigationController {
      topViewController = topVC
    }
    let topView: UIView = UIImageView(image: topViewController.view.snapshotImage(afterScreenUpdates: true))
    self.topSnapShotView = topView
    if vcToDismiss?.navigationController != nil {
      vcToDismiss?.navigationController?.view.addSubview(topView)
    } else {
      vcToDismiss?.view.addSubview(topView)
    }
  }
  
}
