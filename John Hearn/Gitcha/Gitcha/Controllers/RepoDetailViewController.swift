//
//  RepoViewController.swift
//  Gitcha
//
//  Created by John D Hearn on 11/2/16.
//  Copyright © 2016 Bastardized Productions. All rights reserved.
//

import UIKit

class RepoDetailViewController: UIViewController {

    @IBOutlet weak var repositoryLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var watchersLabel: UILabel!
    @IBOutlet weak var starsLabel: UILabel!
    @IBOutlet weak var forksLabel: UILabel!

    var repository: Repository!

    override func viewDidLoad(){
        super.viewDidLoad()
//        UIView.animate(withDuration: 0.1, animations: {
//            self.view.layoutIfNeeded()
//        })
        repositoryLabel.text = repository.name
        descriptionLabel.text = repository.description
        watchersLabel.text = String(repository.watchers!)
        starsLabel.text = String(repository.stars!)
        forksLabel.text = String(repository.forks!)
    }

    
}
