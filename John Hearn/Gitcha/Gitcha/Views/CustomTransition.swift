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


    init(duration: TimeInterval = 1.5,
         delay: TimeInterval? = 0.0,
         damping: CGFloat? = 0.8,
         springVelocity: CGFloat? = 0.6){

        self.duration = duration
        self.delay = delay!
        self.damping = damping!
        self.springVelocity = springVelocity!
    }

    func setupTransform(scaleX: CGFloat? = 1.0,
                        scaleY: CGFloat? = 1.0,
                        translateX: CGFloat? = 0.0,
                        translateY: CGFloat? = 0.0) -> CGAffineTransform {
        return CGAffineTransform(a: scaleX!, b: 0.0, c: 0.0, d: scaleY!, tx: translateX!, ty: translateY!)

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

        let transform = setupTransform(scaleX: 1.8, scaleY: 1.8, translateX: 0.0, translateY: -1000)
//        toViewController.view.transform = CGAffineTransform(translationX: 0.0, y: -500)
//        toViewController.view.transform = CGAffineTransform(scaleX: 2.0, y: 2.0)
        toViewController.view.transform = transform


        UIView.animate(withDuration: duration,
                       delay: delay,
                       usingSpringWithDamping: damping,
                       initialSpringVelocity: springVelocity,
                       options: .curveEaseOut, animations: {

            toViewController.view.alpha = 1.0
            //toViewController.view.backgroundColor = UIColor.green
            toViewController.view.transform = CGAffineTransform.identity
        }, completion: { (finished) in
            transitionContext.completeTransition(true)
        })
    }
}
