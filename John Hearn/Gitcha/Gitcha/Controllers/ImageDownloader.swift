//
//  ImageDownloader.swift
//  Gitcha
//
//  Created by John D Hearn on 11/3/16.
//  Copyright © 2016 Bastardized Productions. All rights reserved.
//

import UIKit


class ImageDownloader: Operation {
    let photoRecord: PhotoRecord

    init(photoRecord: PhotoRecord) {
        self.photoRecord = photoRecord
    }

    override func main() {
        if self.isCancelled { return }

        do{
            let imageData = try Data(contentsOf: self.photoRecord.url )
            if self.isCancelled { return }

            if imageData.count > 0 {
                self.photoRecord.image = UIImage(data:imageData)
                self.photoRecord.state = .Downloaded
            } else {
                self.photoRecord.state = .Failed
                self.photoRecord.image = UIImage(named: "Failed")
            }
        }catch{
            print(error)
        }
    }
}

