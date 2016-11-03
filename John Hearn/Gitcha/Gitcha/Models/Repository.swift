//
//  Repository.swift
//  Gitcha
//
//  Created by John D Hearn on 11/1/16.
//  Copyright © 2016 Bastardized Productions. All rights reserved.
//

import Foundation

class Repository {
    let name: String
    let description: String?
    let language: String?
    let forks: Int?
    let stars: Int?
    let watchers: Int?

    init?(json: [String: Any]){
        if let name = json["name"] as? String{
            self.name = name
            self.description = json["description"] as? String
            self.language = json["language"] as? String
            self.forks = json["forks_count"] as? Int
            self.stars = json["stargazers_count"] as? Int
            self.watchers = json["watchers_count"] as? Int

        } else {
            return nil
        }
    }

}
