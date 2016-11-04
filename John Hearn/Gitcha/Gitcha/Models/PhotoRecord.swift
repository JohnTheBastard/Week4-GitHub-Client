//
//  PhotoRecord.swift
//  Gitcha
//
//  Created by John D Hearn on 11/3/16.
//  Copyright © 2016 Bastardized Productions. All rights reserved.
//

import UIKit

enum PhotoRecordState {
    case New, Downloaded, Failed
}

class PhotoRecord {
    var name: String
    var url: URL
    var state = PhotoRecordState.New
    var image = UIImage(named: "Placeholder")

    init(){
        self.name = ""
        self.url = URL(string: "http://127.0.0.1")!
    }

    init(name: String, url: URL) {
        self.name = name
        self.url = url
    }
}

