//
//  WebViewController.swift
//  Gitcha
//
//  Created by John D Hearn on 11/3/16.
//  Copyright © 2016 Bastardized Productions. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController {

    let webView = WKWebView()

    var webUrl: String!

    override func viewDidLoad() {
        super.viewDidLoad()

        webView.frame = self.view.frame
        self.view.addSubview(webView)
        if let url = URL(string: webUrl) {
            let request = URLRequest(url: url)
            self.webView.load(request)
        }
    }
}
