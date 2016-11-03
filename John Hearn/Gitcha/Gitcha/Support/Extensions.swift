//
//  Extensions.swift
//  Gitcha
//
//  Created by John D Hearn on 10/31/16.
//  Copyright © 2016 Bastardized Productions. All rights reserved.
//

import UIKit

let tokenKey = "access_token"

extension UIResponder{
    static var identifier: String{
        return String(describing: self)
    }
}

extension UserDefaults{
    func getAccessToken() -> String?{
        return self.string(forKey: tokenKey)
    }

    func save(accessToken: String) -> Bool {
        self.set(accessToken, forKey: tokenKey)
        return synchronize()
    }
}

extension String{
    var isValid: Bool{
        let pattern = "[^0-9a-z]"

        do{
            let regex = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
            let range = NSRange(location: 0, length: self.characters.count)

            let matches = regex.numberOfMatches(in: self, options: .reportCompletion, range: range)

            if matches > 0 {
                return false
            }
        }catch{
            return false
        }

        return true
    }
}
