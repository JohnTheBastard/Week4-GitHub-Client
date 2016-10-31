//
//  ViewController.swift
//  Gitcha
//
//  Created by John D Hearn on 10/31/16.
//  Copyright © 2016 Bastardized Productions. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBAction func requestTokenPressed(_ sender: Any) {
        let parameters = ["scope":"user:email,repo"]

        GitHubService.shared.oAuth(parameters: parameters)

    }
    @IBAction func printTokenPressed(_ sender: Any) {
        if let token = UserDefaults.standard.getAccessToken() {
            print("Token is: \(token)")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

