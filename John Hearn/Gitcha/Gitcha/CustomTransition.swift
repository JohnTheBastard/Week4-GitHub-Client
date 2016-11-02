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
    init(duration: TimeInterval = 1.0){
        self.duration = duration
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

        UIView.animate(withDuration: self.duration, animations: {
            toViewController.view.alpha = 1.0


        }, completion: { (finished) in
            transitionContext.completeTransition(true)
        })

    }
}
