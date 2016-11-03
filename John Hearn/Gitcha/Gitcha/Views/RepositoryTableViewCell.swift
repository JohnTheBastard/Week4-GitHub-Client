//
//  RepositoryTableViewCell.swift
//  Gitcha
//
//  Created by John D Hearn on 11/2/16.
//  Copyright © 2016 Bastardized Productions. All rights reserved.
//

import UIKit

class RepositoryTableViewCell: UITableViewCell {

    @IBOutlet weak var repositoryLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    var repository: Repository!{
        didSet{
            self.repositoryLabel.text = repository.name
            if let description = repository.description {
                self.descriptionLabel.text = description
            } else {
                self.descriptionLabel.text = ""
            }
            return
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.repositoryLabel?.text = ""
        self.descriptionLabel?.text = ""
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
