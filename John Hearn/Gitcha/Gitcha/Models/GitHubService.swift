//
//  GitHubService.swift
//  Gitcha
//
//  Created by John D Hearn on 10/31/16.
//  Copyright © 2016 Bastardized Productions. All rights reserved.
//

import UIKit

let kBaseUrlString = "https://github.com/login/oauth"

typealias GitHubAuthCompletion = (Bool)->()
typealias RepoCompletion = ([Repository]?)->()
typealias UserSearchCompletion = ([User]?)->()
typealias PhotoRecordCompletion = (PhotoRecord?)->()

enum SaveOptions{
    case userDefaults
}

enum GitHubOAuthError: Error{
    case extractingCode(String)
}

class GitHubService {
    static let shared = GitHubService()
    private var session: URLSession
    private var urlComponents: URLComponents
    var allRepos = [Repository]()
    lazy var downloadsInProgress = [IndexPath:Operation]()
    lazy var downloadQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "Download queue"
        queue.maxConcurrentOperationCount = 5
        return queue
    }()

    private init() {
        self.session = URLSession(configuration: .ephemeral)
        self.urlComponents = URLComponents()
        self.configure()
    }

    private func configure() {
        self.urlComponents.scheme = "https"
        self.urlComponents.host = "api.github.com"
        if let token = UserDefaults.standard.getAccessToken() {
            let tokenQueryItem = URLQueryItem(name: "access_token",
                                              value: token)
            urlComponents.queryItems = [tokenQueryItem]
        }
    }

    func fetchUserAvatar(url: URL, completion: @escaping PhotoRecordCompletion) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true

        self.session.dataTask(with: url, completionHandler: {(data, response, error) in
            if error != nil { completion(nil); return }
            guard let data = data else { completion(nil); return }
            do{
                let datasourceDictionary = try
                    PropertyListSerialization.propertyList(from: data,
                                                           options: .mutableContainers,
                                                           format: nil) as? [String:Any]
                for(key, value) in datasourceDictionary! {
                    let name = key
                    if let url = URL(string: (value as? String)! ) {
                        let photoRecord = PhotoRecord(name: name, url: url)
//                        let download = ImageDownloader(photoRecord: photoRecord)
//                        self.downloadQueue.addOperation(download)
                        OperationQueue.main.addOperation {
                            completion(photoRecord)
                        }

                    }
                }
            }catch {
                print(error)
            }
        }).resume()
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }


    func searchUsersWith(searchTerm: String, completion: @escaping UserSearchCompletion) {
        self.urlComponents.path = "/search/users"
        let searchQueryItem = URLQueryItem(name: "q", value: searchTerm)
        self.urlComponents.queryItems?.append(searchQueryItem)

        guard let url = self.urlComponents.url else { completion(nil); return }

        self.session.dataTask(with: url, completionHandler: {(data, response, error) in
            if error != nil { completion(nil); return }
            guard let data = data else { completion(nil); return }

            do{
                if let json = try JSONSerialization.jsonObject(with: data,
                                                               options: .mutableContainers)
                as? [String: Any], let items = json["items"] as? [[String:Any]] {

                    var searchedUsers = [User]()

                    for userJSON in items{
                        if let user = User(json: userJSON),
                            let url = URL(string: user.avatarUrl!) {
                            self.fetchUserAvatar(url: url, completion: { (record) in
                                if record != nil{
                                    print("Avatar for \(user.login) found!")
                                    user.avatar.image = record?.image
                                }
                            })

                            searchedUsers.append(user)
                        }
                    }
                    OperationQueue.main.addOperation {
                        completion(searchedUsers)
                    }
                }
            }catch{
                print(error)
            }

        }).resume()
    }



//    func getAvatarFrom(url: URL) -> UIImage?{
//        let image = UIImage()
//
//        return image
//    }


    func fetchRepos(completion: @escaping RepoCompletion) {
        self.configure()
        self.urlComponents.path = "/user/repos"

        guard let url = self.urlComponents.url else { completion(nil); return }
        self.session.dataTask(with: url) { (data, response, error) in
            if error != nil { completion(nil); return }
            if let data = data {
                var repos = [Repository]()
                do {
                    if let json = try JSONSerialization.jsonObject(with: data,
                                                                   options: .mutableContainers)
                        as? [[String: Any]]{

                        for repoJSON in json{
                            if let repository = Repository(json: repoJSON){
                                repos.append(repository)
                            }
                        }
                        OperationQueue.main.addOperation { completion(repos) }
                    }
                } catch {
                    print(error)
                }
            }
        }.resume()
    }

    func oAuth(parameters: [String:String]) {
        var parameterString = String()

        for(key, value) in parameters{
            parameterString += "&\(key)=\(value)"
        }

        if let requestURL = URL(string: "\(kBaseUrlString)/authorize?client_id=\(kGitHubClientID)\(parameterString)" ) {
            print(requestURL.absoluteString)
            UIApplication.shared.open(requestURL)
        }
    }

    func codeFrom(url: URL) throws -> String{
        guard let code = url.absoluteString.components(separatedBy: "=").last else {
            throw GitHubOAuthError.extractingCode("Temporary code not found in string. See codeFrom(url:)")
        }
        return code
    }

    func accessTokenFrom(_ string: String) -> String? {
        if string.contains("access_token") {

            let components = string.components(separatedBy: "&")

            for component in components{
                if component.contains("access_token") {
                    let token = component.components(separatedBy: "=").last

                    return token
                }
            }
        }
        return nil
    }

    func tokenRequestFor(url: URL, options: SaveOptions, completion: @escaping GitHubAuthCompletion) {
        func returnToMainWith(success: Bool) {
            OperationQueue.main.addOperation { completion(success) }
        }

        do{
            let code = try codeFrom(url: url)
            let requestString = "\(kBaseUrlString)/access_token?client_id=\(kGitHubClientID)&client_secret=\(kGitHubClientSecret)&code=\(code)"

            if let requestURL = URL(string: requestString){
                let session = URLSession(configuration: .ephemeral)

                session.dataTask(with: requestURL, completionHandler: { (data, response, error) in
                    if error != nil { returnToMainWith(success: false) }
                    guard let data = data else { returnToMainWith(success: true); return }

                    if let dataString = String(data: data, encoding: .utf8) {    // better solution?
                        if let token = self.accessTokenFrom(dataString) {
                            print("Access Token: \(token)")
                            let success = UserDefaults.standard.save(accessToken: token)
                            returnToMainWith(success: success)
                        }

                    } else {
                        returnToMainWith(success: false)
                    }
                }).resume()
            }
        } catch {
            returnToMainWith(success: false)
        }

    }


}










