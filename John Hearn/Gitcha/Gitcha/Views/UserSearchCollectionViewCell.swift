//
//  UserSearchCollectionViewCell.swift
//  Gitcha
//
//  Created by John D Hearn on 11/3/16.
//  Copyright © 2016 Bastardized Productions. All rights reserved.
//

import UIKit

class UserSearchCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!

    var user : User? {
        didSet{
            self.imageView.image = user?.avatar.image
            self.usernameLabel.text = user?.login
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.imageView.image = nil
        self.usernameLabel.text = ""
    }
}
