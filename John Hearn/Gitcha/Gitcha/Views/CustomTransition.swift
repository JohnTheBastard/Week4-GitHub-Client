//
//  CustomTransition.swift
//  Gitcha
//
//  Created by John D Hearn on 11/2/16.
//  Copyright © 2016 Bastardized Productions. All rights reserved.
//

import UIKit

class CustomTransition: NSObject {
    var duration: TimeInterval
    var delay: TimeInterval
    var damping: CGFloat
    var springVelocity: CGFloat


    init(duration: TimeInterval = 4.0,
         delay: TimeInterval? = 0.0,
         damping: CGFloat? = 0.5,
         springVelocity: CGFloat? = 1.0){

        self.duration = duration
        self.delay = delay!
        self.damping = damping!
        self.springVelocity = springVelocity!
    }
}

extension CustomTransition: UIViewControllerAnimatedTransitioning{
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toViewController = transitionContext.viewController(forKey: .to) else { return }
        transitionContext.containerView.addSubview(toViewController.view)

        toViewController.view.alpha = 0.0


        UIView.animate(withDuration: duration,
                       delay: delay,
                       usingSpringWithDamping: damping,
                       initialSpringVelocity: springVelocity,
                       options: .curveEaseInOut, animations: {

            toViewController.view.alpha = 1.0
            toViewController.view.backgroundColor = UIColor.green
            toViewController.view.transform.scaledBy(x: 0.5, y: 0.5)
            toViewController.view.transform.translatedBy(x: 0.5, y: 0.0)
        }, completion: { (finished) in
            transitionContext.completeTransition(true)
        })
    }
}
