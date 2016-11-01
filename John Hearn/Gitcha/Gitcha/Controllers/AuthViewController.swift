//
//  AuthViewController.swift
//  Gitcha
//
//  Created by John D Hearn on 11/1/16.
//  Copyright © 2016 Bastardized Productions. All rights reserved.
//

import UIKit

class AuthViewController: UIViewController {

    @IBAction func loginButtonPressed(_ sender: UIButton) {
        let parameters = ["scope": "user:email,repo"]
        GitHubService.shared.oAuth(parameters: parameters)
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }


}
